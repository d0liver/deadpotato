window.RouteHandler = ->

	self =
	board: -> $.get "board.html", (contents) -> $(".container").html contents
	uploadVariant: ->
		$.get "variant-upload.html"
		.done (contents) ->
			template = Handlebars.compile contents
			$(".container").html template()
			uv = UploadVariant()
		.fail ->
			alert "Failed to fetch resource."
