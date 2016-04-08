$(document).ready(function () {
    fixData();
    var dims = {width: 1150, height: 847};
    var map_img = $("#map-image")[0];
    var canvas = $("#map")[0];
    canvas.width = dims.width;
    canvas.height = dims.height;

    canvas = $("#map_select")[0];
    canvas.width = dims.width;
    canvas.height = dims.height;

    var ctx = $("#map")[0].getContext('2d');
    var color_map = ColorMap();
    var select_ctx = $("#map_select")[0].getContext('2d');
    var texture_builder = TextureBuilder();
    var gam_info = GameInfo(rgns, cnt, gam, map_data);
    var texture_builder = TextureBuilder(color_map); 
    var region_textures = RegionTexture(gam_info, texture_builder);
    region_textures.build();
    var map = Map(ctx, select_ctx, gam_info, region_textures);
    var icons = Icons(ctx, gam_info);
    /* Set our country. The map will use this to limit our selects, etc. */
    map.setCountry("Elves");
    map.showRegions();
    // icons.init();
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

    showInteractions(gam_info, color_map);
});

var darken = function (css_hex, pct_amount) {
   if (pct_amount < 0)
      console.log("Color in: ", css_hex);
   var colors = colorsToArray(css_hex);

   /* Darken the colors */
   colors = _.map(colors, function (color) {
      var amount = color*pct_amount/100 & ~0;
      /* The Math.min is because we can accept negative values */
      return Math.min(255, Math.max(color - amount, 0));
   });

   if (pct_amount < 0)
      console.log("Color out: ", arrayToColors(colors));
   return arrayToColors(colors);
};

var colorsToArray = function (css_hex) {
   var colors = [];
   /* Remove the leading '#' */
   css_hex = css_hex.slice(1);

   for (var i = 1; i <= 3; ++i) {
      /* Grab this color */
      colors.push(parseInt(css_hex.slice(0, 2), 16));
      /* Shrink the string for the next iteration */
      css_hex = css_hex.slice(2);
   }

   return colors;
};

var arrayToColors = function (colors) {
   var result = "";

   for (var i = 0; i < 3; ++i) {
      var hex = colors[i].toString(16);
      result += (hex.length == 1)? "0"+hex:hex;
   }

   return "#"+result;
};

var rgbaCssFromHex = function (css_hex, alpha) {
   var colors = colorsToArray(css_hex);

   return "rgba("+colors.join(",")+","+alpha+")";
};

var showInteractions = function (gam_info, color_map) {
   var countries = gam_info.countries();

   for (var i = 0; i < countries.length; ++i) {
      var hex_color = color_map.map(countries[i].color.toLowerCase());
      var color = darken(hex_color, 50);
      var gradient_dark = darken(hex_color, 70);
      var text_color = darken(hex_color, -20);
      $(".interactions ul").append(
         "<li style='border-color: "+color+
         "; border-bottom: solid black 1px; background: linear-gradient(90deg, "+
         rgbaCssFromHex(gradient_dark, 1)+","+
         rgbaCssFromHex(color, 0.7)+
         ");'>"+
         "<span style='color: white;' class='label'>"+
            countries[i].name+
         "</span>"
         // "<img class='icon' src='"+icons[i].canvas.toDataURL()+"'/></li>"
         // "<img class='chat' src='chat-empty.svg'/></li>"
      );
   }
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
