# Makes dealing with keystrokes a little easier

class KeyboardInputHandler
	# Some useful keycodes
	SHIFT = 16; CTRL = 17; ESC = 27

	constructor: ->
		keys_pressed = {}

		$(document).on 'keydown', (e) ->
			keys_pressed[e.which] = true if e.which in [SHIFT, CTRL, ESC]

		Object.defineProperties @,
			ctrlIsDown:  get: -> keys_pressed[CTRL]  ? false
			shiftIsDown: get: -> keys_pressed[SHIFT] ? false
			escIsDown:   get: -> keys_pressed[ESC]   ? false

module.exports = KeyboardInputHandler
