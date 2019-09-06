const sharp = require('sharp');
const S3 = require('aws-sdk/clients/s3');
const s3 = new S3({region: 'us-east-2'});

Array.prototype.flatMap = function(lambda) {
    return Array.prototype.concat.apply([], this.map(lambda));
};

getOriginalImage = async (bucket, key) => {
  const imageLocation = { Bucket: bucket, Key: key };
  const request = s3.getObject(imageLocation).promise();
  try {
    const originalImage = await request;
    return Promise.resolve(originalImage.Body);
  }
  catch(err) {
    console.log(err);
    return Promise.reject({
      status: 500,
      code: err.code,
      message: err.message
    })
  }
};

exports.lambda_handler = async (event) => {
  //console.log(JSON.stringify(event));
  let promises = event.Records
    .map(r => JSON.parse(r.body))
    .flatMap(b => b.Records)
    .map(r => ({bucketId: r.s3.bucket.name, key: r.s3.object.key}))
    .map(async s3Object => {
      const originalImage = await getOriginalImage(s3Object.bucketId, s3Object.key)
      const image = await sharp(originalImage).resize(320, 240).toBuffer();
      const destKey = 'thumbnails/320-' + s3Object.key.replace('original/', '');
      return s3.putObject({Bucket: s3Object.bucketId, Body: image, Key: destKey}).promise();
    });

  const images = await Promise.all(promises);
  return {
    "statusCode": 200,
    "body": images
  };
};
