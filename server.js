var passport = require("passport");
var LocalStrategy = require("passport-local").Strategy;
var bodyParser = require('body-parser');
var express = require("express");
var session = require('express-session')
var app = express();
var db_uri = "mongodb://localhost:27017/deadpotato";
var MongoClient = require('mongodb').MongoClient;

// app.set('view engine', 'jade');
app.use(session({secret: 'lumbering jack'}));
app.use(passport.initialize());
app.use(passport.session());
app.use(bodyParser.urlencoded());
app.use(bodyParser.json());


MongoClient.connect(
	db_uri,
	(err, db) =>
	{
		app.post('/login', passport.authenticate('local',
			{
				successRedirect: '/loginSuccess',
				failureRedirect: '/loginFailure'
			}
		));

		app.get('/',
			(req, res, next) =>
			{
				console.log("User: ", JSON.stringify(req.user));
			}
		);
		app.get(
			'/login',
			(req, res, next) => res.sendFile(__dirname + "/view/login.html")
		);

		app.get(
			'/loginFailure',
			(req, res, next) => res.send('Failed to authenticate')
		);

		app.get(
			'/loginSuccess',
			(req, res, next) => res.send('Successfully authenticated')
		);

		passport.use(
			new LocalStrategy(
				(username, password, done) =>
				{
					process.nextTick(() =>
					{
						console.log("Username: ", username);
						console.log("Password: ", password);
						db.collection('users').findOne(
							{username: username, password: password},
							() => (err, doc) {
								console.log("Err: ", err);
								console.log("Doc: ", doc);
							}
						);
						return done(null, {username: username, password: password});
					});
				}
			)
		);
	}
);

var ser_deser = (user, done) => done(null, user);
passport.serializeUser(ser_deser);
passport.deserializeUser(ser_deser);

var server = app.listen(3000, () =>
	{
		var host = server.address().address;
		var port = server.address().port;

		console.log("Listening...");
	}
);
