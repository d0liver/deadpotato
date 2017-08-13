gqlQuery = require './gqlQuery'

h  = require 'virtual-dom/h'
Q  = require 'q'
co = require 'co'

# Handles the workflow for uploading a variant. Kicks off parsers, persists
# everything to the db, etc. Arguments are the parsers.
UploadVariant = (view) ->
	self = {}
	files = []

	self.display = ({status = 'Select a file'} = {}) ->
		console.log "Display kickoff"
		view.display h '.root', [
			h '.status', status
			h 'input', type: 'file', onchange: (e) ->
				reader = new FileReader()

				reader.addEventListener 'load', ->
					self.display status: 'Uploading variant files...'
					gqlQuery """
						mutation createVariant($variant: String!) {
							createVariant(variant: $variant)
						}
					""", variant: reader.result.replace 'data:application/zip;base64,', ''
					.done (result) ->
						self.display status:
							if result.errors
								"Error: #{result.errors[0].message}"
							else
								'Variant was uploaded successfully and is ready to use.'
					.fail (result) ->
						self.display
							status: 'Failed to connect to the server for the upload.'

				self.display status: 'Processing variant files...'

				if this.files.length isnt 0
					reader.readAsDataURL this.files[0]
		]

	return self

module.exports = UploadVariant
