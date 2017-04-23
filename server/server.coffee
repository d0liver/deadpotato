bodyParser                = require 'body-parser'
express                   = require 'express'
passport                  = require "passport"
session                   = require 'express-session'
{MongoClient}             = require 'mongodb'
{Server}                  = require 'http'
{Strategy: LocalStrategy} = require "passport-local"

jwtSecret = "flabber"
DB_URI    = "mongodb://localhost:27017/deadpotato"
app       = express()
http      = Server app

app.set 'view engine', 'pug'

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

MongoClient.connect DB_URI, (err, db) ->
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

	app.get '/', (req, res, next) ->
		res.render 'index'

	app.get '/create', (req, res, next) ->
		res.render 'index'

	app.get '/games', (req, res, next) ->
		res.render 'index'

	app.post "/save-game", save.bind null, db
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

save = (db, req, res) ->
	{title, variant} = req.body
	db.collection("games").insertOne
		title: title
		variant: variant

postLogin = (req, res) ->
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
