_ = require 'underscore'
$ = require 'jquery'

Router = ->
	formats = {}
	self = {}

	self.get = (fmt) -> _.assign formats, fmt

	# See if we can match our
	self.route = ->
		for format, handler of formats
			if results = formatsMatch format, location.pathname
				handler results; return
		return

	formatsMatch = (format, uri) ->
		results = {}
		for [fcomp, wcomp] in _.zip(
			components format
			components location.pathname
		)
			if isParam(fcomp) and wcomp?
				# If this is a param then we use this component as the
				# value for the label.
				results[fcomp[1..]] = wcomp
			else if fcomp isnt wcomp
				# This wasn't a param and these components don't match.
				# Therefore, this path isn't a match.
				return

		# If we didn't bail out by this point then that means that the
		# path matched completely.
		return results

	components = (s) ->
		res = s.split '/'
		# Filter out any empty entries. Most likely these will be at
		# the beginning and end but they could be somewhere in the
		# middle in case of duplicate slashes.
		res = res.filter (c) -> c isnt ''
		return res

	isParam = (p) -> p?.charAt(0) is ':'

	return self

module.exports = Router
