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

	type VariantMutations {
		create(variant: String!): ObjectID
	}

	type Player {
		pid: ID
		country: String
	}

	input GameInput {
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

	type GameMutations {
		create(variant: String!): ObjectID
		join(country: String!, game: ObjectID!): ObjectID
	}

	type OrdersMutations {
		submit(_id: ObjectID, orders: [String]): String
	}

	type Query {
		variants(slug: String!): [Variant]
		games(_id: ObjectID): [Game]
		isAuthed: Boolean
		s3Bucket: String
	}

	type Mutation {
		game: GameMutations
		variant(variant: String!): VariantMutations
	}
"""
