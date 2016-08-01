passport = require "passport"
LocalStrategy = require("passport-local").Strategy
bodyParser = require 'body-parser'
express = require "express"
session = require 'express-session'
jwt = require 'jsonwebtoken'
socketioJwt = require 'socketio-jwt'
app = express()
http = require("http").Server app
io = require('socket.io') http
db_uri = "mongodb://localhost:27017/deadpotato"
MongoClient = require('mongodb').MongoClient
jwtSecret = "flabber"

# app.set 'view engine', 'jade'
app.use session
	secret: 'lumbering jack'
	resave: true
	saveUninitialized: true
app.use passport.initialize()
app.use passport.session()
app.use bodyParser.urlencoded extended: true
app.use bodyParser.json()
app.use express.static "public"
app.use express.static "variants"

MongoClient.connect db_uri, (err, db) ->
	io.use socketioJwt.authorize
		secret: jwtSecret,
		handshake: true

	io.on 'connection', (socket) ->
		socket.on 'chat', (msg, alt_msg) ->
			console.log "Chat message: ", msg
			console.log "Alt message: ", alt_msg
			io.emit 'chat', msg
		# in socket.io 1.0
		console.log 'hello! ', socket.decoded_token.name

	app.get "/*", fetchRoot
	app.post "/login", postLogin

	passport.use \
		new LocalStrategy (username, password, done) ->
			process.nextTick ->
				console.log "Username: ", username
				console.log "Password: ", password
				db.collection('users').findOne
					username: username, password: password,
					(err, doc) ->
						console.log "Err: ", err
						console.log "Doc: ", doc
				done null, username: username, password: password

	http.listen 3000, () -> console.log 'listening on http://localhost:3000'

fetchRoot = (err, res) ->
	res.sendFile __dirname + "/public/index.html"

postLogin = (err, res) ->
	# TODO: validate the actual user user
	profile =
		name: 'David Oliver',
		email: 'david@doliver.org',
		id: 123

	# We are sending the profile in the token
	token = jwt.sign profile, jwtSecret,  expiresIn: 60*60*5

	res.json token: token

ser_deser = (user, done) -> done null, user
passport.serializeUser ser_deser
passport.deserializeUser ser_deser
