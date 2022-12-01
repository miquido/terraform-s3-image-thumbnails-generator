const s3ACL = process.env.S3_ACL;
const s3Region = process.env.S3_REGION;
const s3Encryption = process.env.S3_ENCRYPTION;
const widths = process.env.THUMBNAIL_WIDTHS.split(',').map(Number);
const snsTopicARN = process.env.SNS_TOPIC_ARN;

const sharp = require('sharp');
const S3 = require('aws-sdk/clients/s3');
const s3 = new S3({ region: s3Region });
const SNS = require('aws-sdk/clients/sns');
const sns = new SNS();

Array.prototype.flatMap = function (lambda) {
  return Array.prototype.concat.apply([], this.map(lambda));
};

const getOriginalImage = async (bucket, key) => s3.getObject({ Bucket: bucket, Key: key }).promise();

const putImageToS3 = async (s3Object, imageBody, width, metadata) => {
  return s3.putObject({
    Bucket: s3Object.bucketId,
    Body: imageBody,
    Key: `thumbnails/${width}/${s3Object.key.replace('original/', '')}`,
    ACL: s3ACL,
    ContentType: `image/${metadata.format}`,
    ServerSideEncryption: s3Encryption
  }
  ).promise();
};

const resizeOriginalImage = async records => Promise.all(records
  .map(async s3Object => {
    const originalImage = (await getOriginalImage(s3Object.bucketId, s3Object.key)).Body;
    const originalImageMetadata = await sharp(originalImage).metadata();
    const filteredWidthsSmaller = widths.filter(width => width < originalImageMetadata.width);
    const filteredWidthsBigger = widths.filter(width => width >= originalImageMetadata.width);
    const putBigger = filteredWidthsBigger.map(async width => {
      return putImageToS3(s3Object, originalImage, width, originalImageMetadata);
    });
    const putSmaller = filteredWidthsSmaller.map(async width => {
      const image = await sharp(originalImage)
        .heif({ compression: 'hevc' })
        .resize({ width })
        .rotate()
        .toBuffer();
      return putImageToS3(s3Object, image, width, originalImageMetadata);
    });

    return Promise.all(putBigger.concat(putSmaller));
  })
);

exports.lambda_handler = async event => {
  try {
    const parsedRecords = event.Records
      .map(r => JSON.parse(r.body))
      .flatMap(b => b.Records)
      .map(r => ({ bucketId: r.s3.bucket.name, key: r.s3.object.key }));

    await resizeOriginalImage(parsedRecords);

    for (const record of parsedRecords) {
      await sns.publish({
        Message: JSON.stringify(record),
        TopicArn: snsTopicARN,
      }).promise();
    }

    return {
      statusCode: 200
    };
  } catch (err) {
    console.log(err);
    return {
      statusCode: 400,
      code: err.code,
      message: err.message
    }
  }
};
