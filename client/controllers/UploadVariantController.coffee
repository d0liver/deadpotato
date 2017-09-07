gqlQuery = require '../gqlQuery'

template = require '../../views/upload-variant.pug'

{CREATE_VARIANT_Q} = require '../gqlQueries'

# Handles the workflow for uploading a variant. Kicks off parsers, persists
# everything to the db, etc. Arguments are the parsers.
UploadVariantController = ($el) ->
	self = {}
	files = []

	$el.html template()
	$input = $el.find 'input[type=file]'
	$status = $el.find '.status'
	$status.html 'Select a variant .zip to upload.'

	$input.on 'change', (e) ->
		reader = new FileReader()
		reader.addEventListener 'load', ->
			$status.html 'Uploading variant files...'
			b64 = reader.result.replace /data\:[^,]+,/, ''
			result = await gqlQuery CREATE_VARIANT_Q, variant: b64
			$status.html \
				if result.errors
					"Error: #{result.errors[0].message}"
				else
					'Variant was uploaded successfully and is ready to use.'

		if this.files.length isnt 0
			reader.readAsDataURL this.files[0]

		$status.html 'Processing variant files...'

	return self

module.exports = UploadVariantController
