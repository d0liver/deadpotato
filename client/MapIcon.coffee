Q = require 'q'

MapIcon = (slug, color, type) ->
	self = {}

	self.uri = ->
		S3_BUCKET = "https://s3.us-east-2.amazonaws.com/deadpotato/"
		"#{S3_BUCKET}#{slug}/#{capitalize color.name()}#{type}.ico"

	self.img = ->
		img = new Image()
		img.src = self.uri()
		d = Q.defer()
		img.addEventListener 'load', -> d.resolve img

		return d.promise

	# TODO: This should really be somewhere else
	capitalize = (word) ->
		word = "#{word[0].toUpperCase()}#{word[1..]}"

	return self

module.exports = MapIcon
