{ObjectID}             = require 'mongodb'
{GraphQLScalarType}    = require 'graphql'
{makeExecutableSchema} = require 'graphql-tools'
co                     = require 'co'
_                      = require 'underscore'

# Just hardcoding this for now. It's probably not necessary to give the query
# control over the page size.
PAGE_SIZE=5

SchemaBuilder = ({db, user}) ->

	snippets = db.collection 'snippets'
	MongoObjectID = new GraphQLScalarType
		name: 'ObjectID',
		description: 'Mongo ObjectID',
		serialize: (value) -> value.toString()
		parseValue: (value) ->
			try
				return ObjectID value
		parseLiteral: (ast) -> ast.value

	schema = """
		scalar ObjectID
		type Snippet {
			_id: ObjectID
			text: String
			title: String
			username: String
		}

		type Query {
			snippet(_id: ObjectID!): Snippet
			snippets(text: String!, page: Int): [Snippet]
			snippetsCount(text: String!): Int
			username: String
			tags: [String!]
		}

		input SnippetPartial {
			title: String
			text: String
			tags: [String]
		}

		type Mutation {
			updateSnippet(update: SnippetPartial!, _id: ObjectID!): Boolean
			forkSnippet(_id: ObjectID!): ObjectID
			removeSnippet(_id: ObjectID!): Boolean
		}
	"""

	search = (text, page) ->
		if text is 'all'
			search = {}
		else
			exprs = []
			tags = []
			pieces = text.split /\s+/
			# Special search have the form key: value.
			while (piece = pieces.shift())?
				if piece is 'username:'
					next_piece = pieces.shift().trim()
					if next_piece isnt ''
						exprs.push username: next_piece
				else
					tags.push piece

			for piece in tags
				exprs.push tags: $regex: new RegExp piece, 'i'
			search = $and: exprs

		snippets.find(search)

	resolvers =
		ObjectID: MongoObjectID
		Query:
			username: -> user?.username 
			snippet: (obj, {_id}) -> snippets.findOne {_id}
			tags: (obj) ->
				pipeline = [
					{$project: tags: 1, _id: 0}
					{$unwind: '$tags'}
					{$group: _id: '$tags'}
				]
				snippets.aggregate(pipeline).sort(_id: 1).toArray().then (results) ->
					for result in results
						result._id

			# Page is zero indexed. When count is true we return the page count
			# only. This way we don't query for the page count with each search
			# request - it's just stored by the client.
			snippets: (obj, {text, page = 0}) ->
				search(text, page).skip(page*PAGE_SIZE).limit(PAGE_SIZE).toArray()

			snippetsCount: (obj, {text}) ->
				search(text).count()

		Mutation:
			# Fork an existing snippet by copying it under the current user.
			# TODO: Make sure the user is logged in here.
			forkSnippet: (obj, {_id}) ->
				return null unless user?
				snippets.findOne {_id}, _id: 0
				.then (template) ->
					template.user = user.username
					snippets.insertOne template
				.then ({insertedId}) -> insertedId

			updateSnippet: (obj, {_id, update}) ->
				return null unless user?
				mongo_update = $set: {}
				for key, value of update
					mongo_update.$set[key] = value

				snippets.updateOne({_id, username: user.username}, mongo_update)
				.then (r) ->
					true

			removeSnippet: (obj, {_id}) ->
				return null unless user?
				snippets.remove({_id, username: user.username})

	return makeExecutableSchema {typeDefs: schema, resolvers}

module.exports = SchemaBuilder
