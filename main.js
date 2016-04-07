$(document).ready(function () {
    fixData();
    var map_img = $("#map-image")[0];
    var canvas = $("#map")[0];
    canvas.width = map_img.offsetWidth;
    canvas.height = map_img.offsetHeight;

    canvas = $("#map_select")[0];
    canvas.width = map_img.offsetWidth;
    canvas.height = map_img.offsetHeight;

    var ctx = $("#map")[0].getContext('2d');
    var select_ctx = $("#map_select")[0].getContext('2d');
    var texture_builder = TextureBuilder();
    var gam_info = GameInfo(rgns, cnt, gam, map_data);
    var texture_builder = TextureBuilder(); 
    var region_textures = RegionTexture(gam_info, texture_builder);
    region_textures.build();
    var map = Map(ctx, select_ctx, gam_info, region_textures);
    var icons = Icons(ctx, gam_info);
    /* Set our country. The map will use this to limit our selects, etc. */
    map.setCountry("Elves");
    map.showRegions();
    icons.init();
    $("#say_hello").submit(function (e) {
        e.preventDefault();
        var lstatus = $("#login_status");
        lstatus.text('Logging in...');
        $.post('/login',
            {
                username: $("#say_hello input[name=username]").value(),
                password: $("#say_hello input[name=password]").value()
            },
            function () {
            }
        );
    });

    showIcons(icons.icons());
});

var showIcons = function (icons) {
   for (var i = 0; i < icons.length; ++i)
      $(".interactions ul").append(
         "<li><span class='label'>"+
            icons[i].country+
         "</span>"+
         "<img class='icon' src='"+icons[i].canvas.toDataURL()+"'/></li>"
      );
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
};

var relCoords = function (done) {
   return function (e) {
       var offset = $(this).offset(); 
       e.pageX = e.pageX - offset.left;
       e.pageY = e.pageY - offset.top;

       done(e);
   };
};
