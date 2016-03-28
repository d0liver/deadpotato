window.onload = function () {
    fixData();
    var map_img = document.getElementById("map-image");
    var canvas = document.getElementById("map");
    canvas.width = map_img.offsetWidth;
    canvas.height = map_img.offsetHeight;

    var ctx = document.getElementById("map").getContext('2d');
    var select_ctx = document.getElementById("map_select").getContext('2d');
    var texture_builder = TextureBuilder();
    var gam_info = GameInfo(rgns, cnt, gam, map_data);
    var texture_builder = TextureBuilder(); 
    var region_textures = RegionTexture(gam_info, texture_builder);
    region_textures.build();
    var map = Map(ctx, select_ctx, gam_info, region_textures);
    map.showRegions();
    /* Test arrow drawing functionality */
    map.arrow("brown lands", "wilderness");

    window.onclick = function (e) {
        map.selectRegion(e);
    };
};

/* We have to iterate a bunch of the data that we received and change the
 * naming conventions because they're inconsistent (we make everything lower
 * case) */
var fixData = function () {
    cnt.countries = _.map(cnt.countries, function (country) {
        country.color = country.color.toLowerCase();

        return country;
    });

    map_data.spaces = _.map(map_data.spaces, function (space) {
        space.abbreviations = _.map(space.abbreviations, function (abbr) {
            return abbr.toLowerCase();
        });
        space.name = space.name.toLowerCase();

        return space;
    });

    rgns = _.object(_.map(rgns, function (rgn, rgn_name) {
        return [rgn_name.toLowerCase(), rgn]
    }));

    gam.country_infos = _.map(gam.country_infos, function (country_info) {
        country_info.units = _.map(country_info.units, function (unit) {
            return unit.toLowerCase();
        });
        country_info.supply_centers =
            _.map(country_info.supply_centers, function (supply_center) {
            return supply_center.toLowerCase();
        });

        return country_info;
    });

    console.log("Regions: ", rgns);
    console.log("Map: ", map_data);
    console.log("Gam: ", gam);
    console.log("Cnt: ", cnt);
};
