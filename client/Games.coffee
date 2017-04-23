h = require 'virtual-dom/h'

module.exports = ({title, variant, img, countries}) ->
	h '.game', [
		h 'h1.title', title
		h 'ul.info', [
			h 'h3.variant', variant
			h 'ul.countries', [
				# One of these is generated for each country
				h 'li.country', country for country in countries
			]
		]
		h 'img.map', src: img
	]
