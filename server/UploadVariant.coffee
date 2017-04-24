AWS = require 'aws-sdk'
AWS.config.loadFromPath('.deadpotato_s3.json');

s3 = new AWS.S3

params = Bucket: 'deadpotato', Key: 'foose'
s3.deleteObject params, (err, data) ->
	if err
		console.log err
	else
		console.log "Successfully deleted data 'foose'"
