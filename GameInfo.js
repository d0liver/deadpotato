/* This abstracts away all of the data that we get from the server about the
 * game. A lot of the info references other info and that's not something we
 * want to have to deal with at this level.
 * cnt = The info from the .cnt file
 * map = The info from the .map file
 * varr = The info from the .var file
 */
var GameInfo = function (scanlines, cnt, map, varr) {
    var regions_info = [];
    var self = {};

    var init = function () {
        var i;

        for (i = 0; i < cnt.countries.length; ++i) {
            regions_info[i] = {
                name: cnt.countries[i].name,
                adjective: cnt.countries[i].adjective,
                capital_initial: cnt.countries[i].capital_initial,
                pattern: cnt.countries[i].pattern,
                color: cnt.countries[i].color
            };
        }
    };

    self.scanlines = function () {
        return scanlines;
    };

    self.regionColor = function (region_name) {
        var supply_centers = self.countrySupplyCenters();
        var country_idx = 0;

        for (country in supply_centers) {
            for (var i = 0; i < supply_centers[country].length; ++i)
                if (
                    supply_centers[country][i].toLowerCase() ==
                    region_name.toLowerCase()
                )
                    return cnt.countries[country_idx].color.toLowerCase();

            ++country_idx;
        }

        /* Use red as the default */
        return "red";
    };

    self.regions = function () {
        var i;
        var regions = [];

        for (i = 0; i < varr.spaces.length; ++i)
            regions.push(varr.spaces[i].name);

        return regions;
    };

    self.countrySupplyCenters = function () {
        var i, j;
        var supply_centers = {}, supply_center_abbrs, country;

        for (i = 0; i < cnt.countries.length; ++i) {
            supply_center_abbrs = map.country_infos[i].supply_centers;
            country = cnt.countries[i].name;
            supply_centers[country] = [];
            for (j = 0; j < supply_center_abbrs.length; ++j) {
                var region_name = self.regionName(supply_center_abbrs[j]);
                supply_centers[country].push(region_name);
            }
        }

        return supply_centers;
    };

    /* Iterate the info from the .var file and get the region name
     * corresponding to the given abbreviation. We resolve all abbreviations
     * before using them since they are not unique. */
    self.regionName = function (region_abbr) {
        var i, j;

        for (i = 0; i < varr.spaces.length; ++i)
            for (j = 0; j < varr.spaces[i].abbreviations.length; ++j)
                if (
                    varr.spaces[i].abbreviations[j].toLowerCase() ==
                    region_abbr.toLowerCase()
                )
                    return varr.spaces[i].name;
    };

    self.regionScanLines = function (region_abbr) {
        return scanlines[self.regionName(region_abbr)];
    };

    init();
    return self;
};
