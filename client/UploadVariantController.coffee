gqlQuery = require './gqlQuery'

Q  = require 'q'
co = require 'co'

template = require '../views/upload-variant.pug'

{CREATE_VARIANT_Q} = require './gqlQueries'

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
			b64 = reader.result.replace 'data:application/zip;base64,', ''
			co ->
				result = yield gqlQuery CREATE_VARIANT_Q, variant: b64
				$status.html \
					if result.errors
						"Error: #{result.errors[0].message}"
					else
						'Variant was uploaded successfully and is ready to use.'

			.catch (err) ->
				console.log 'An error occurred while attempting to upload the variant: ', err

		if this.files.length isnt 0
			reader.readAsDataURL this.files[0]

		$status.html 'Processing variant files...'

	return self

module.exports = UploadVariantController
