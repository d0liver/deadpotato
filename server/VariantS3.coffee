VariantS3 = ->
	self = {}
	console.log "Uploading #{name} to S3..."
	params =
		Bucket: 'deadpotato'
		Key: name
		Body: buff
		ContentDisposition: 'inline'
		ContentType: 'image/bmp'
		ACL: 'public-read'

	s3 = new AWS.S3
	put = Q.denodeify s3.putObject.bind s3
	try
		yield put params
		console.log "Uploaded variant image successfully."
	catch err
		console.log "An error occurred while uploading the variant image: ", err

	return self

module.exports = VariantS3
