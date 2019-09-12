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
    if(!isNaN(s3Object.key.match(/([^/]+)/))) {
      widths.filter( width => width < Number(s3Object.key.match(/([^/]+)/)))
      return widths;
    }
    const originalImage = (await getOriginalImage(s3Object.bucketId, s3Object.key)).Body;
    return Promise.all(widths.map(async width => {
      const image = await sharp(originalImage).resize( {width: width} ).toBuffer();
      const destKey = `thumbnails/${width}/${s3Object.key.replace('original/', '')}`;

      return s3.putObject({Bucket: s3Object.bucketId, Body: image, Key: destKey, ACL: 'public-read'}).promise();
    }))
  })
);

exports.lambda_handler = async event => {
  try {
    await resizeOriginalImage(event.Records);
    return {
      "statusCode": 200
    };
  } catch(err) {
    console.log(err);
    return {
      status: 406,
      code: err.code,
      message: err.message
    }
  }
};
