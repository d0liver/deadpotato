_             = require 'underscore'
co            = require 'co'
gqlQuery      = require './gqlQuery'
$             = require 'jquery'
VariantImages = require './VariantImages'

{S3_BUCKET} = require '../lib/config'
template      = require '../views/games-list.pug'

{GAMES_Q, IS_AUTHED_Q, JOIN_GAME_Q} = require './gqlQueries'

GamesListController = ($el) ->
	self = {}
	authed = false

	co ->
		{games} = yield gqlQuery GAMES_Q
		players = []
		# We go through and attach the available countries to each game.
		# This feels somewhat hacky - like maybe it should be in the view
		# but this is much easier.
		# for game in games
		for game in games
			pcountries = (player.country for player in players)
			gcountries = (country.name for country in game.countries)
			game.available_countries = _.difference gcountries, pcountries
			game.countries = gcountries
			game.map_src = "#{S3_BUCKET}#{game.variant.slug}/map.bmp"

		$el.html template {games}

	.catch (err) ->
		console.log "Failed to fetch games list: ", err

	join = ->
		$this = $(this)
		country = $this.siblings('#select-country').val()
		_id = $this.siblings('#_id').val()

		co ->
			yield gqlQuery JOIN_GAME_Q, {game: _id, country}
		.catch (err) ->
			throw err

		# window.location.replace "/game/#{_id}"

	return self

module.exports = GamesListController
