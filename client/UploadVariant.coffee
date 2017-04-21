# Handles the workflow for uploading a variant. Kicks off parsers, persists
# everything to the db, etc. Arguments are the parsers.
UploadVariant = (cnt, gam, map, rgn) ->
	self = {}
	files = []

	onerror = (err) -> console.log "Err: ", err

	getEntries = (file, cb) ->
		zip.createReader new zip.TextReader(file), (zipReader) ->
			zipReader.getEntries cb
		, onerror

	# Get the contents of a particular file object
	getEntryFile = (entry) ->
		def = Q.defer()
		entry.getData new zip.TextWriter(), (text) ->
			def.resolve text.split /[\r\n]+/

		def.promise

	self.parseFiles = (zip_file) ->
		def = Q.defer()
		# This will be our final data structure that holds all of the resulting
		# parsed data
		getEntries zip_file, (entries) ->
			ext_pat = /\.([a-zA-Z0-9]+)$/
			for entry in entries when ext_pat.test entry.filename
				ext = (entry.filename.match ext_pat)[1]
				if ext in ["cnt", "rgn", "gam", "var", "map"]
					handles = $.extend handles, "#{ext}": entry
			self.parseFromHandles handles
			.then (res) ->
				console.log "Full result: ", res
			.done()

		def.promise


	self.parseFromHandles = (handles) ->
		# Get all of these vars in the correct scope
		season_year = variant = countries = abbr_map = regions = null
		# We have indexed all of our needed files, now we can actually
		# start to parse.
		getEntryFile handles["map"]
		.then (lines) ->
			# Parse .map
			{abbr_map, regions} = map lines
			getEntryFile handles["cnt"]
		.then (lines) ->
			# Parse .cnt
			countries = cnt lines
			getEntryFile handles["gam"], 
		.then (lines) ->
			#Parse .gam
			{regions: gam_rgns, variant, season_year} =
				gam lines, abbr_map, countries
			$.extend regions[name], region for name,region of gam_rgns
			getEntryFile handles["rgn"]
		.then (lines) ->
			# Parse .rgn
			rgn_regions = rgn lines, _.keys regions
			regions[name].scanlines = region for name,region of rgn_regions

			variant: variant
			season_year: season_year
			countries: countries
			regions: regions

	self.trigger = () ->
		zip.useWebWorkers = false
		zip.workerScriptsPath = "/js/"
		input = $ "<input type='file'>"
		input.css "visibility", "hidden"
		$("body").append input
		input.on 'change', ->
			self.parseFiles input[0].files[0]
			.then (res) ->
				console.log "Full parse result: ", res
			$("body").remove input
		input.click()

	self

module.exports = UploadVariant
