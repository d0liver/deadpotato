var passport = require("passport");
var LocalStrategy = require("passport-local").Strategy;
var bodyParser = require('body-parser');
var express = require("express");
var session = require('express-session')
var jwt = require('jsonwebtoken');
var socketioJwt = require('socketio-jwt');
var app = express();
var http = require("http").Server(app);
var io = require('socket.io')(http);
var db_uri = "mongodb://localhost:27017/deadpotato";
var MongoClient = require('mongodb').MongoClient;
var jwtSecret = "flabber";

// app.set('view engine', 'jade');
app.use(session({
	secret: 'lumbering jack',
    resave: true,
    saveUninitialized: true
}));
app.use(passport.initialize());
app.use(passport.session());
app.use(bodyParser.urlencoded({extended: true}));
app.use(bodyParser.json());
app.use(express.static("public"));
app.use(express.static("variants"));

MongoClient.connect(
	db_uri,
	(err, db) =>
	{
		io.use(socketioJwt.authorize({
			secret: jwtSecret,
			handshake: true
		}));

		io.on('connection', function (socket) {
			socket.on('chat', function (msg) {
				console.log("Chat message: ", msg);
				io.emit('chat', msg);
			});
			// in socket.io 1.0
			console.log('hello! ', socket.decoded_token.name);
		});

		app.get("/", fetchRoot);
		app.post("/login", postLogin);

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
							(err, doc) => {
								console.log("Err: ", err);
								console.log("Doc: ", doc);
							}
						);
						return done(null, {username: username, password: password});
					});
				}
			)
		);

		http.listen(3000, function () {
		  console.log('listening on http://localhost:3000');
		});
	}
);

var fetchRoot = (err, res) => {
	res.sendFile(__dirname + "/public/index.html");
};

var postLogin = (err, res) => {
  // TODO: validate the actual user user
	var profile = {
		name: 'David Oliver',
		email: 'david@doliver.org',
		id: 123
	};

  // we are sending the profile in the token
  var token = jwt.sign(profile, jwtSecret, { expiresIn: 60*60*5 });

  res.json({token: token});
};

var ser_deser = (user, done) => done(null, user);
passport.serializeUser(ser_deser);
passport.deserializeUser(ser_deser);
