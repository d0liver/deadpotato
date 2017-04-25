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
		console.log "Rerender: ", status
		view.display h '.root', [
			h '.status', status
			h 'input', type: 'file', onchange: (e) ->
				console.log "This: ", this
				reader = new FileReader()

				reader.addEventListener 'load', ->
					self.display status: 'Uploading variant files...'
					gqlQuery """
						mutation createVariant($variant: String!) {
							createVariant(variant: $variant)
						}
					""", variant: reader.result.replace 'data:application/zip;base64,', ''
					.done (result) ->
						self.display
							status: 'Variant was uploaded successfully and is ready to use.'

				self.display status: 'Processing variant files...'

				reader.readAsDataURL this.files[0]
		]

	return self

module.exports = UploadVariant
