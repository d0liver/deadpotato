$ = require "jquery"

gqlQuery = (query, variables) ->

	$.ajax
		url: '/graphql'
		type: 'POST'
		data: JSON.stringify
			query: query
			variables: variables
		contentType: 'application/json; charset=utf-8'
		dataType: 'json'

module.exports = gqlQuery
