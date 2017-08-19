module.exports = """
	scalar ObjectID

	type Unit {
		type: String
		region: String
		coast: String
	}

	type Country {
		adjective: String
		capital_initial: String
		color: String
		name: String
		pattern: String
		supply_centers: [String]
		units: [Unit]
	}

	type Variant {
		_id: ObjectID!
		name: String!
		map_data: String!
		slug: String!
		assets: [String]!
	}

	type Player {
		pid: ID
		country: String
	}

	input GameArg {
		title: String!
		variant: ObjectID!
	}

	type Game {
		_id: ObjectID!
		title: String!
		variant: Variant
		player_country: String
		players: [Player]
		season_year: String!
		countries: [Country]
	}

	type Query {
		findVariant(slug: String!): Variant
		listVariants: [Variant]
		findGame(_id: ObjectID!): Game
		listGames: [Game]
		isAuthed: Boolean
	}

	type Mutation {
		createVariant(variant: String!): ObjectID
		createGame(game: GameArg): ObjectID
		joinGame(country: String!, game: ObjectID!): String
		submitOrders(_id: ObjectID, orders: [String]): ObjectID
	}
"""
