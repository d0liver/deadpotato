window.RouteHandler = (upload_variant) ->
	err = console.log
	[$container, $body] = [$(".container"), $("body")]

	self =
	board: -> $.get "board.html", (contents) -> $(".container").html contents

	# Create a game
	create: ->
		$.get "create-game.html"
		.done (contents)->
			$container.addClass "text-content"
			$container.html contents
			$(".create-game").one "submit", (e) ->
				e.preventDefault()
				$.post "/save-game", $(".create-game").serialize()
			$(".new-variant").click (e) ->
				e.preventDefault()
				upload_variant.trigger()
		.fail err

	games: ->
		$.get "games.html"
		.done (contents) ->
			$container.html contents
			$container.addClass "text-content"
			$body.css 'background-color': "white"
			$(".game .title").text "This is a Test Game"
			$(".game .variant").text "LOTR"
			$(".game .map").attr src: "midearth.bmp"
			country = $(".game .country").remove()
			for val in ["one", "two", "three"]
				$(".game .countries").append country.clone().text val
		.fail err

	reset = (cb) ->
		->
			$container.attr class: "container"
			$body.attr class: ""

	# Wrap each of our routes in the reset decorator. This will take care of
	# making sure the container is in a default state before the next route is
	# called
	self[name] = reset route for route,name of self

	self
