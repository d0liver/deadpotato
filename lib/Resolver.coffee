cycleGuard = require './cycleGuard'

orders = [
		type: 'MOVE'
		from: 'A'
		to: 'B'
	,
		type: 'MOVE'
		from: 'C'
		to: 'B'
]

# Adapted from "The Math of Adjudication" by Lucas Kruijswijk
Resolver = ->
	self = {}
	return self

module.exports = Resolver
# Possible resolutions of an order.
[FAILS, SUCCEEDS] = [1, 2]
orders = []

# The resolution of an order can be in three states:
# UNRESOLVED - Order is not yet resolved (no resolution).
# GUESSING   - The resolution contains a value, but it is only a guess.
# RESOLVED   - The resolution contains a value, and is final.
[UNRESOLVED, GUESSING, RESOLVED] = [1, 2, 3]

# nr - The number of the order to be resolved.
# Returns the resolution for that order.
adjudicate = (order) ->
	switch order.type
		when 'MOVE'
			# Find all move orders attempting to move to the same region as this order.
			destined = [order..., (order2 for order2 in orders when order2.to is order.to)...]

			# Figure out who has the most moveStrength (or if a bounce should
			# occur)
			winning = {}; bounce = false
			for order in destined
				strength = moveStrength order
				if winning.strength is strength then bounce = true
				else if not winning.strength? or strength > winning.strength
					winning.order = order
					bounce = false

			winning.order.resolution = unless bounce then SUCCEEDS else FAILS
			order.resolution = FAILS for order in orders when dest is order.to

moveStrength = (order) ->
	strength = 1

	# Check for successful support orders
	for o in orders when \
	o.type is 'SUPPORT' and
	o.from is order.from and
	o.to is order.to and
	adjudicate(o) is SUCCEEDS
		strength += 1

	return strength

handleCycle = ->
	# If order is already resolved, just return the resolution.
	switch order.state
		when RESOLVED then return order.resolution
		when GUESSING
			# Order is in guess state. Add the order to the dependencies list,
			# if it isn't there yet and return the guess.
			if order not in dependencies then dependencies.push order
			return order.resolution

		if order not in order.dependencies
			# The order is dependent on a guess, but not our own guess. Add to
			# dependency list, update result, but state remains guessing.
			dependencies.push order
			return order.resolution
		else
			# Result is dependent on our own guess. Set all orders in dependency list
			# to UNRESOLVED and reset dependency list.
			for dependency in order.dependencies
				dependency.state = UNRESOLVED

		# Do the other guess.
		order.resolution = SUCCEEDS; order.state = GUESSING

		# Adjudicate with the other guess.
		if order.resolution is adjudicate order
			# Although there is a cycle, there is only one resolution. Cleanup
			# dependency list first.
			for dependency in order.dependencies
				dependency.state = UNRESOLVED

			# Now set the final result and return.
			order.state = RESOLVED
			return order.resolution

		# There are two or no resolutions for the cycle. Pass dependencies to the
		# backup rule. These are dependencies with index in range [old_nr_of_dep,
		# nr_of_dep - 1]. The backup_rule, should clean up the dependency list
		# (setting nr_of_dep to old_nr_of_dep). Any order in the dependency list
		# that is not set to RESOLVED should be set to UNRESOLVED.
		backup_rule old_nr_of_dep

	# Set order in guess state.
	order.resolution = FAILS; order.state = GUESSING
	console.log "Handling cycle..."

	# The backup_rule may not have resolved all orders in the cycle. For
	# instance, the Szykman rule, will not resolve the orders of the moves
	# attacking the convoys. To deal with this, we start all over again.
	return resolve nr

# resolve = cycleGuard resolve, handleCycle

adjudicate test_orders
console.log "Test orders: ", test_orders
