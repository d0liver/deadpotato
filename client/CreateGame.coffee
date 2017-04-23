h = require 'virtual-dom/h'

# CreateGame template
module.exports = ->
	h 'form.create-game',
		onsubmit: (e) ->
			e.preventDefault()
			$.post "/save-game", $(".create-game").serialize()
		, [

			h '.row', [
				h '.six.columns', [
					h 'label', htmlFor: 'title', 'Game Title'
					h 'input#title.u-full-width', type: 'text', name: 'title'
				]
				h '.five.columns', [
					h 'label', htmlFor: 'which-variant', 'Variant'
					h 'select#which-variant.u-full-width', name: 'variant'
				]
				h '.one.columns', h 'label'  
			]
			h 'input.button-primary', type: 'submit', value: 'Post'
		]
