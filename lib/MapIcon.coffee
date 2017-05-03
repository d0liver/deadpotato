Q = require 'q'
{capitalize} = require '../lib/utils'

MapIcon = (slug, color, type) ->
	self = {}

	self.uri = ->
		S3_BUCKET = "https://s3.us-east-2.amazonaws.com/deadpotato/"
		"#{S3_BUCKET}#{self.relativeUri()}"

	self.relativeUri = -> "#{slug}/#{self.name()}.ico"

	self.img = ->
		img = new Image()
		img.src = self.uri()
		d = Q.defer()
		img.addEventListener 'load', -> d.resolve img

		return d.promise

	self.name = -> "#{capitalize(color.name())}#{type}"

	return self

module.exports = MapIcon
