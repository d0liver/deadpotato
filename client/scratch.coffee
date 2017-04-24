# TODO: This is all a bunch of stuff that worked at one point but is currently
# borken for one reason or another. It needs to be reintegrated.
$("nav .nav-link").each ->
	fade_in = 0
	$menu = $(this).parent().find ".menu"
	$(@).click (e) ->
		e.preventDefault()
		# method = ["fadeIn", "fadeOut"][fade_in++ & 1]
		$menu.fadeIn 300
	$(@).parent().find(".menu").mouseleave -> $menu.fadeOut 300

	# TODO:
	# io.use socketioJwt.authorize
	# 	secret: jwtSecret,
	# 	handshake: true

	# jwt                       = require 'jsonwebtoken'
	# socketioJwt               = require 'socketio-jwt'
	# io = require('socket.io') http
	# io.on 'connection', (socket) ->
	# 	socket.on 'chat', (msg, alt_msg) ->
	# 		console.log "Chat message: ", msg
	# 		console.log "Alt message: ", alt_msg
	# 		io.emit 'chat', msg
	# 	# in socket.io 1.0
	# 	console.log 'hello! ', socket.decoded_token.name
