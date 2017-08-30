_ = require 'underscore'

# Async
co = require 'co'
q  = require 'q'

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
Gavel           = require '/home/david/gavel'

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
		obj = schema: SchemaBuilder db, req.user

		return obj

	app.use '/graphiql', graphiqlExpress
	  endpointURL: '/graphql'

	# Fallback is the index
	app.get '/*', (req, res, next) ->
		res.render 'index'

	ser_deser = (user, done) -> done null, user
	passport.serializeUser ser_deser
	passport.deserializeUser ser_deser

http.listen 3000, () -> console.log 'listening on http://localhost:3000'
