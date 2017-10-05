$ = require 'jquery'

class NavMenuController
	constructor: ->
		DELAY = 200
		$drop = $ '.dropdown'

		$drop.click (e) ->
			$menu = $(e.target).parent().children '.menu'
			console.log "FOO"
			# Do not preventDefault() on menu items
			if $(e.target).parent().hasClass 'dropdown'
				e.preventDefault()
				$menu.slideToggle DELAY

module.exports = NavMenuController
