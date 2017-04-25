diff          = require 'virtual-dom/diff'
patch         = require 'virtual-dom/patch'
createElement = require 'virtual-dom/create-element'

View = ($container) ->
	self = {}
	root = null; tree = null

	self.display = (new_tree) ->
		unless root?
			# If we haven't created the base element then do that now.
			root = createElement new_tree
			$container.append root
		else
			# Otherwise, we have the root node created already so we just need
			# to patch it.
			patches = diff tree, new_tree
			root = patch root, patches

		tree = new_tree

	# Force a new root to be created from the tree. This is probably faster in
	# cases where we know that all of the container contents will be replaced
	# because we don't have to generate and apply a bunch of patches to the
	# root node (TODO: investigate this).
	self.flush = (new_tree) ->
		root = createElement new_tree
		$container.append root
		tree = new_tree

	return self

module.exports = View
