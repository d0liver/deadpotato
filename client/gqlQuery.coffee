$ = require "jquery"

{GraphQLException} = require '../lib/Exceptions'

gqlQuery = (query, variables) ->

	result = yield $.ajax
		url: '/graphql'
		type: 'POST'
		data: JSON.stringify
			query: query
			variables: variables
		contentType: 'application/json; charset=utf-8'
		dataType: 'json'

	if result.data?
		return result.data
	else
		throw new GraphQLException data.errors

module.exports = gqlQuery
