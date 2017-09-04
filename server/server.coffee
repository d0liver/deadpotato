_ = require 'underscore'

# Express
bodyParser = require 'body-parser'
express    = require 'express'
passport   = require "passport"
session    = require 'express-session'
{Server}   = require 'http'

# Mongo
{MongoClient, ObjectID} = require 'mongodb'

# Passport
GoogleAuth = require './GoogleAuth'

# GraphQL
{graphqlExpress, graphiqlExpress} = require 'apollo-server-express'
SchemaBuilder    = require './SchemaBuilder'

{UserException} = require '../lib/Exceptions'
Gavel           = require 'gavel.js'

NODE_ENV = process.env.NODE_ENV
DB_URI = "mongodb://localhost:27017/deadpotato"
app    = express()
http   = Server app

app.set 'view engine', 'pug'

app.use session
	secret: 'lumbering jack'
	resave: true
	saveUninitialized: true

app.use passport.initialize()
app.use passport.session()
app.use bodyParser.urlencoded extended: true
app.use bodyParser.json limit: '2mb'
app.use express.static "public"

app.use (req, res, next) ->
	if req.isAuthenticated()
		res.locals.user = req.user

	next()

GoogleAuth app, passport

MongoClient.connect DB_URI, (err, db) ->

	if err
		console.log "Unable to connect to the database. Is it running?"
		throw err

	app.use '/graphql', graphqlExpress (req) ->
		schema: SchemaBuilder db, req.user
		# formatError: (err) ->
		# 	console.log "Err: ", err
		# 	err.butts = true
		# 	return err

	app.use '/graphiql', graphiqlExpress
		endpointURL: '/graphql'

	# Fallback is the index
	app.get '/game/:id', (req, res, next) ->
		if process.env.NODE_ENV is 'development'
			res.render 'index', gid: req.params.id
		else
			next()

	app.get '/remove-game/:id', (req, res, next) ->
		unless process.env.NODE_ENV is 'development'
			res.redirect '/'
			return

		try
			_id = ObjectID req.params.id
		catch err
			console.log "
				Failed to create mongo object id from the given id string: 
			", req.params.id
			# If we couldn't create the ObjectID then bail. We're doing it this
			# way rather than having all of the logic be in ONE catch block
			# because it seems to be the case that mongo will just throw a
			# generic error when id creation fails and thus we cannot deal with
			# that scenario specifically without suppressing or dealing with
			# every other exception case.
			return

		if _id?
			# Remove the game and the phases attached to the game
			# We don't have to wait on this one because we don't need the result.
			db.collection('games').remove {_id}
			phases = await db.collection('phases').find({game: _id}).toArray()
			# Same thing as above - we don't care when these removals complete, so no `await`
			for phase in phases
				# Remove all of the orders attached to this phase
				db.collection('orders').remove {phase: phase._id}
				db.collection('phases').remove {_id: phase._id}

			res.redirect '/'
			return

	app.get '/*', (req, res, next) ->
		res.render 'index'

	ser_deser = (user, done) -> done null, user
	passport.serializeUser ser_deser
	passport.deserializeUser ser_deser

http.listen 3000, () -> console.log 'listening on http://localhost:3000'
