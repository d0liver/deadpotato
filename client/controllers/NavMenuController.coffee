$ = require 'jquery'

class NavMenuController
	constructor: ->
		DELAY = 200
		$drop = $ '.dropdown'; $menu = $drop.children '.menu'
		console.log "Drop: ", $drop[0]
		console.log "Menu: ", $menu[0]

		$drop.click (e) ->
			e.preventDefault()
			$menu.slideToggle DELAY

module.exports = NavMenuController
