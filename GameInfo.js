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

    self.regions = function () {
        var i;
        var regions = [];

        for (i = 0; i < varr.spaces.length; ++i)
            regions.push(varr.spaces[i].name);

        return regions;
    };

    self.countryRegions = function () {
        var i, j;
        var regions = {};

        for (i = 0; i < cnt.countries.length; ++i) {
            var country_regions = map.country_infos[i];
            var country = cnt.countries[i].name;
            for (j = 0; j < country_regions.length; ++j)
                showRegion(self.regionName(country_regions[j]));
        }

        return regions;
    };

    /* Iterate the info from the .var file and get the region name
     * corresponding to the given abbreviation. We resolve all abbreviations
     * before using them since they are not unique. */
    self.regionName = function (region_abbr) {
        var i, j;

        for (i = 0; i < varr.spaces.length; ++i)
            for (j = 0; j < varr.spaces[i].abbreviations[j].length; ++j)
                if (varr.spaces[i].abbreviations[j] == region_abbr)
                    return varr.spaces[i].name;
    };

    self.regionScanLines = function (region_abbr) {
        return scanlines[self.regionName(region_abbr)];
    };

    init();
    return self;
};
