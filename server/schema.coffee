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
		countries: [Country]
		name: String!
		map_data: String!
		season_year: String!
		slug: String!
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
	}

	type Query {
		findVariant(slug: String!): Variant
		listVariants: [Variant]
		findGame(_id: ObjectID!): Game
		listGames: [Game]
	}

	type Mutation {
		createVariant(variant: String!): ObjectID
		createGame(game: GameArg): ObjectID
		joinGame(country: String!, game: ObjectID!): String
	}
"""
