exports.coastName = (abbr) ->
	map = 
		nc: 'North'
		sc: 'South'
		ec: 'East'
		wc: 'West'
	return map[abbr]
