# Pulls together some data from the variant_data to make things a bit easier.
VariantUtils = (variant_data) ->
	self = {}
	{countries} = variant_data

	self.country = (cname) ->
		for country in countries when country.name is cname
			return country

	self.colors = -> country.color for country in countries

	self.regionColor = (rname) ->
		for country in variant_data.countries
			for center in country.supply_centers when center is rname
				return country.color
		return

	return self

module.exports = VariantUtils
