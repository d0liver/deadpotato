$ = require "jquery"

{GraphQLException} = require '../lib/Exceptions'

gqlQuery = (query, variables) ->

	new Promise (resolve, reject) ->
		$.ajax
			url: '/graphql'
			type: 'POST'
			data: JSON.stringify
				query: query
				variables: variables
			contentType: 'application/json; charset=utf-8'
			dataType: 'json'
		.done (result) -> resolve result.data
		.fail (..., err) -> throw err 

module.exports = gqlQuery
