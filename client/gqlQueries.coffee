exports.GAMES_Q = """
	{
		games {
			_id
			title
			players {
				country
			}
			countries {
				name
			}
			variant {
				slug
			}
		}
	}
"""

exports.IS_AUTHED_Q	= "
	{
		isAuthed
	}
"

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

exports.GAME_Q = """
	query games($_id: ObjectID!) {
		games(_id: $_id) {
			_id
			title
			player_country
			season_year
			players {
				pid
				country
			}
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
			variant {
				map_data
				name
				slug
				assets
			}
		}
	}
"""
