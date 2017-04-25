fs                               = require 'fs'
{OAuth2Strategy: GoogleStrategy} = require 'passport-google-oauth'

module.exports = (app, passport) ->
	if process.env.NODE_ENV is 'development'
		json = fs.readFileSync "#{process.env.HOME}/.auth_credentials.json"
		{clientID, clientSecret} = JSON.parse json
		opts = {
			clientID
			clientSecret
			callbackURL: 'http://localhost:8080/auth/google/callback'
		}

	# Just to make things a little less verbose further down
	auth = passport.authenticate.bind passport, 'google'

	google_verify = (accessToken, refreshToken, profile, done) ->
		done null, profile

	passport.use new GoogleStrategy opts, google_verify

	scope = ['https://www.googleapis.com/auth/plus.login']
	app.get '/auth/google', auth {scope}

	failureRedirect = '/'
	app.get '/auth/google/callback', auth({failureRedirect}), (req, res) ->
		# Authentication was successful
		res.redirect '/'

	# We're not using these but passport js expects to serialize and deserialize a
	# user with each request. We just pass the user through.
	passport.serializeUser (user, done) ->
		done null, user

	passport.deserializeUser (user, done) ->
		done null, user
