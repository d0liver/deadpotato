# This abstracts away all of the data that we get from the server about the
# game. A lot of the info references other info and that's not something we
# want to have to deal with at this level.
# cnt = The info from the .cnt file
# gam = The info from the .gam file
# map = The info from the .map file

GameInfo = (rgns, cnt, gam, map) -> 

	self = 
		rgns: () -> rgns
		countries: () -> cnt.countries
		country: (region_name) ->
			cnt_idx = _.findIndex gam.country_infos, (country_info) ->
				# If we find this region as one of the units for a country then we
				# know that unit belongs to this country so we return true
				found = !!_.find country_info.units, (unit) ->
					self.regionName(unit) is region_name.toLowerCase()

			cnt.countries[cnt_idx]

		regionColor: (region_name) ->
			supply_centers = self.countrySupplyCenters()
			country_idx = 0

			for country of supply_centers
				for center in country
					if center is region_name
						return cnt.countries[country_idx].color

			# Use red as the default
			"red"

		regions: () -> space.name for space in map.spaces

		countrySupplyCenters: () ->
			supply_centers = {}

			for country, i in cnt.countries
				supply_center_abbrs = gam.country_infos[i].supply_centers
				supply_centers[country.name] = []
				supply_centers[country.name] = \
					(self.regionName(abbr) for abbr in supply_center_abbrs)

			supply_centers

		# Iterate the info from the .var file and get the region name
		# corresponding to the given abbreviation. We resolve all abbreviations
		# before using them since they are not unique.
		regionName: (region_abbr) ->
			for space in map.spaces
				return space.name if region_abbr in space.abbreviations

		regionScanLines: (region, not_abbr) -> 
			region = region.toLowerCase()
			key = if not_abbr then region else self.regionName region
			rgns[key].scanlines

		unitPos: (region_name) -> rgns[region_name].unit_pos

		namePos: (region_name) -> rgns[region_name].name_pos

	self

module.exports = GameInfo
