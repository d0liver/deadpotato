exports.GAMES_Q = """
	{
		games {
			_id
			title
			players {
				country
			}
			variant {
				slug
			}
			phase {
				countries {
					name
				}
			}
		}
	}
"""

exports.GAME_Q = """
	query games($_id: ObjectID!) {
		games(_id: $_id) {
			_id
			title
			player_country
			players {
				pid
				country
			}
			phase {
				countries {
					adjective
					color
					name
					pattern
					supply_centers
					units {
						type
						region
						coast
					}
				}
				season_year
			}
			variant {
				map_data
				name
				slug
				assets
			}
		}
	}
"""

exports.CREATE_GAME_Q = """
	mutation game($game: GameInput!) {
		game {
			create(game: $game)
		}
	}
"""

exports.JOIN_GAME_Q = """
	mutation join($country: String!, $game: ObjectID!) {
		game {
			join(country: $country, game: $game)
		}
	}
"""

exports.CREATE_VARIANT_Q = """
	mutation create($variant: String!) {
		variant {
			create(variant: $variant)
		}
	}
"""

exports.VARIANTS_Q = """
	{
		variants {
			_id
			name
		}
	}
"""

exports.IS_AUTHED_Q	= "
	{
		isAuthed
	}
"
