const s3ACL = process.env.S3_ACL;
const s3Region = process.env.S3_REGION;
const widths = process.env.THUMBNAIL_WIDTHS.split(',').map(Number);

const sharp = require('sharp');
const S3 = require('aws-sdk/clients/s3');
const s3 = new S3({region: s3Region});

Array.prototype.flatMap = function(lambda) {
  return Array.prototype.concat.apply([], this.map(lambda));
};

const getOriginalImage = async (bucket, key) => s3.getObject({ Bucket: bucket, Key: key }).promise();

const putImageToS3 = async (s3Object, imageBody, width, metadata) => {
  return s3.putObject({Bucket: s3Object.bucketId,
    Body: imageBody,
    Key: `thumbnails/${width}/${s3Object.key.replace('original/', '')}`,
    ACL: s3ACL,
    ContentType: `image/${metadata.format}`}
  ).promise();
};

const resizeOriginalImage = async records => Promise.all(records
  .map(r => JSON.parse(r.body))
  .flatMap(b => b.Records)
  .map(r => ({bucketId: r.s3.bucket.name, key: r.s3.object.key}))
  .map(async s3Object => {
    const originalImage = (await getOriginalImage(s3Object.bucketId, s3Object.key)).Body;
    const originalImageMetadata = await sharp(originalImage).metadata();
    const filteredWidthsSmaller = widths.filter(width => width < originalImageMetadata.width);
    const filteredWidthsBigger = widths.filter(width => width >= originalImageMetadata.width);
    const putBigger = filteredWidthsBigger.map(async width => {
      return putImageToS3(s3Object, originalImage, width, originalImageMetadata);
    });
    const putSmaller = filteredWidthsSmaller.map(async width => {
      const image = await sharp(originalImage).resize( {width: width} ).toBuffer();
      return putImageToS3(s3Object, image, width, originalImageMetadata);
    });

    return Promise.all(putBigger.concat(putSmaller));
  })
);

exports.lambda_handler = async event => {
  try {
    await resizeOriginalImage(event.Records);
    return {
      statusCode: 200
    };
  } catch(err) {
    console.log(err);
    return {
      statusCode: 400,
      code: err.code,
      message: err.message
    }
  }
};
