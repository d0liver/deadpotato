{capitalize} = require '../lib/utils'

MapIcon = (slug, assets, color, type) ->
	self = {}

	self.uri = ->
		S3_BUCKET = "https://s3.us-east-2.amazonaws.com/deadpotato/"
		"#{S3_BUCKET}#{self.relativeUri()}"

	self.relativeUri = ->
		uri = "#{slug}/#{self.name()}.ico"
		if uri in assets
			return uri
		else
			return "icon files/#{self.name()}.ico"

	self.img = ->
		img = new Image()
		img.src = self.uri()

		new Promise (resolve, reject) ->
			img.addEventListener 'load', -> resolve img

	self.name = -> "#{capitalize(color.name())}#{type}"

	return self

module.exports = MapIcon
