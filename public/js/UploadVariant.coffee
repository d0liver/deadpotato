# Handles the workflow for uploading a variant. Kicks off parsers, persists
# everything to the db, etc. Arguments are the parsers.
window.UploadVariant = (cnt, gam, rgn) ->
	self = {}
	files = []

	$(".choose-file").click (e) -> e.preventDefault(); self.trigger()

	onerror = (err) -> console.log "Err: ", err

	getEntries = (file, cb) ->
		zip.createReader new zip.TextReader(file), (zipReader) ->
			zipReader.getEntries cb
		, onerror
	# Get the contents of a particular file object
	getEntryFile = (entry, cb) -> entry.getData new zip.TextWriter(), cb

	self.parseFiles = (zip_file) ->
		getEntries zip_file, (entries) ->
			entries.forEach (entry) ->
				console.log "Name: ", entry.filename

	self.trigger = ->
		zip.useWebWorkers = false
		zip.workerScriptsPath = "/js/"
		input = $ "<input type='file'>"
		input.css "visibility", "hidden"
		$("body").append input
		input.on 'change', ->
			self.parseFiles input[0].files[0]
			$(".file-display").html input[0].files[0].name
			$("body").remove input
		input.click()

	self
