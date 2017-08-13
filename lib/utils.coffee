exports.capitalize = (word) ->
	word = "#{word[0].toUpperCase()}#{word[1..]}"

exports.copy = (obj) -> JSON.parse JSON.stringify obj
