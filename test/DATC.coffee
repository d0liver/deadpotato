{MongoClient} = require 'mongodb'
co            = require 'co'

DB_URI              = "mongodb://localhost:27017/deadpotato"
Engine              = require '../lib/Engine'
Resolver            = require '../lib/Resolver'
{UserException, ResolverException} = require '../lib/Exceptions'

parseOrder = (order) ->
	move_re = /^(A|F)\s+((?:\w+\s+)?(?:\w+))\s+\-\s+((?:\w+\s+)?(?:\w+))$/
	if move_re.test(order)
		matches = order.match(move_re)
		type: 'MOVE'
		from: matches[2]
		to: matches[3]
		country: 'England'

MongoClient.connect DB_URI, (err, db) ->
	co ->
		console.log "Fetching variant data for Standard map.."
		variant_data = yield db.collection('variants').findOne(slug: 'standard')
		console.log "Decoding the map data"
		variant_data.map_data = JSON.parse(variant_data.map_data)
		engine = Engine(variant_data, "England", Resolver)

		console.log "Running DATC tests...."
		db.close()

		console.log "Checking for illegal move failure"
		engine.addOrder parseOrder 'F North Sea - Picardy'

		failed = false
		try
			engine.checkMapConstraints()
		catch err
			if err instanceof ResolverException
				failed = true

		unless failed
			console.log "FAILED: Illegal move was successful"
		else
			console.log "SUCCEEDED: Illegal move failed"

		console.log "Checking for illegal move failure (2)"
		engine.addOrder parseOrder 'A Liverpool - Irish Sea'

		failed = false
		try
			engine.checkMapConstraints()
		catch err
			if err instanceof ResolverException
				failed = true

		unless failed
			console.log "FAILED: Illegal move was successful (2)"
		else
			console.log "SUCCEEDED: Illegal move failed (2)"

		console.log "Checking for illegal move failure (3)"
		engine.addOrder parseOrder 'F Kiel - Munich'

		failed = false
		try
			engine.checkMapConstraints()
		catch err
			if err instanceof ResolverException
				failed = true

		unless failed
			console.log "FAILED: Illegal move was successful (3)"
		else
			console.log "SUCCEEDED: Illegal move failed (3)"

		console.log "Checking for illegal move failure (4)"
		engine.addOrder parseOrder 'F Kiel - Kiel'

		failed = false
		try
			engine.checkMapConstraints()
		catch err
			if err instanceof ResolverException
				failed = true

		unless failed
			console.log "FAILED: Illegal move was successful (4)"
		else
			console.log "SUCCEEDED: Illegal move failed (4)"
