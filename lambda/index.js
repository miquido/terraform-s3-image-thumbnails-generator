const sharp = require('sharp');
const S3 = require('aws-sdk/clients/s3');
const s3 = new S3({region: 'us-east-2'});
const widths = process.env.THUMBNAIL_WIDTHS.split(',').map(Number);

Array.prototype.flatMap = function(lambda) {
  return Array.prototype.concat.apply([], this.map(lambda));
};

const getOriginalImage = async (bucket, key) => await s3.getObject({ Bucket: bucket, Key: key }).promise();

const resizeOriginalImage = async records => Promise.all(records
  .map(r => JSON.parse(r.body))
  .flatMap(b => b.Records)
  .map(r => ({bucketId: r.s3.bucket.name, key: r.s3.object.key}))
  .map(async s3Object => {
    const originalImage = (await getOriginalImage(s3Object.bucketId, s3Object.key)).Body;
    const originalImageMetadata = await sharp(originalImage).metadata();
    const filteredWidthsSmaller = widths.filter(width => width < originalImageMetadata.width);
    const filteredWidthsBigger = widths.filter(width => width >= originalImageMetadata.width);
    await Promise.all(filteredWidthsBigger.map(async width => {
      const destKey = `thumbnails/${width}/${s3Object.key.replace('original/', '')}`;
      return s3.putObject({Bucket: s3Object.bucketId,
        Body: originalImage,
        Key: destKey,
        ACL: 'public-read',
          ContentType: `image/${originalImageMetadata.format}`}
        ).promise();
    }));
    return Promise.all(filteredWidthsSmaller.map(async width => {
      const image = await sharp(originalImage).resize( {width: width} ).toBuffer();
      const destKey = `thumbnails/${width}/${s3Object.key.replace('original/', '')}`;
      return s3.putObject({Bucket: s3Object.bucketId,
        Body: image,
        Key: destKey,
        ACL: 'public-read',
        ContentType: `image/${originalImageMetadata.format}`}
        ).promise();
    }));
  })
);

exports.lambda_handler = async event => {
  try {
    await resizeOriginalImage(event.Records);
    return {
      status: 200
    };
  } catch(err) {
    console.log(err);
    return {
      status: 400,
      code: err.code,
      message: err.message
    }
  }
};
