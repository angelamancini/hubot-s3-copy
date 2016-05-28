# Description:
#   This script lets hubot-s3-copy list objects in a preprod S3 bucket,
#   copy objects from the preprod bucket to a production bucket and list objects
#   in the production bucket.
#
# Commands:
#  QA passed on <codeTag>
#  qa passed on <codeTag>

module.exports = (robot) ->
  bucket = "bucketName/projectFolder"
  origin_folder = "#{bucket}/preprod"
  destination_folder = "#{bucket}/prod"

  # Copy file from preprod bucket to prod bucket
  robot.hear /(qa|QA) passed on (.*)/i, (msg) ->
    codeTag = msg.match[2]
    # require aws resources
    aws = require('../aws.coffee').aws()
    # lock API version
    s3  = new aws.S3({apiVersion: '2006-03-01'})

    # Does the file already exist in the prod bucket?
    s3.getObject { Bucket: destination_folder, Key: codeTag }, (err, res) ->
      if err
        # file is not in prod, proceed
        # Does the file exist in the preprod bucket?
        s3.getObject { Bucket: origin_folder, Key: codeTag }, (err, res) ->
          if err
            # file is not in preprod bucket, error
            msg.send "I'm sorry, I can't find #{codeTag}, has it been packaged?"
          else
            msg.send "Copying #{codeTag} to production..."
            # CopySource is the source bucket and file separated by a '/'
            # Key is the destination bucket and file
            s3.copyObject { Bucket: destination_folder, CopySource: "#{origin_folder}/#{codeTag}", Key: "#{codeTag}"}, (err, res) ->
              if err
                msg.send "Error: #{err}"
              else
                msg.send "#{codeTag} is ready for production!"

      else
        msg.send "#{codeTag} has already passed QA."
