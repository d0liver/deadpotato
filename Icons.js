/* We use the scanlines provided to draw a box around each of the countries and
 * get a little icon for their area */

var Icons = function (ctx, gam_info) {
    var self = {};
    /* An array of canvases with the icons drawn on them */
    var icons = [];

    self.init = function () {
        var supply_centers = gam_info.countrySupplyCenters();
        var rgns = gam_info.rgns();

        for (country in supply_centers) {
            var bounding_box = {
                x_min: Infinity,
                y_min: Infinity,
                x_max: -1,
                y_max: -1
            };

            for (var i = 0; i < supply_centers[country].length; ++i) {
                var region = supply_centers[country][i];
                var scanlines = gam_info.regionScanLines(region, true);
                for (var j = 0; j < scanlines.length; ++j) {
                    if (scanlines[j].x < bounding_box.x_min)
                        bounding_box.x_min = scanlines[j].x;
                    else if (
                        scanlines[j].x + scanlines[j].len >
                        bounding_box.x_max
                    )
                        bounding_box.x_max = scanlines[j].x + scanlines[j].len;

                    if (scanlines[j].y < bounding_box.y_min)
                        bounding_box.y_min = scanlines[j].y;
                    else if (scanlines[j].y > bounding_box.y_max)
                        bounding_box.y_max = scanlines[j].y;
                }
            }

            var bbox_width = bounding_box.x_max - bounding_box.x_min;
            var bbox_height = bounding_box.y_max - bounding_box.y_min;
            var ratio = bbox_width/bbox_height;

            var icon_canvas = document.createElement("canvas");
            var icon_ctx = icon_canvas.getContext('2d');
            icon_canvas.height = 150;
            icon_canvas.width = 150;

            var dest_width, dest_height;
            /* Force the canvas to fit in a 150 by 150 icon */
            if (bbox_width > bbox_height) {
                dest_width = 150;
                dest_height = 150/ratio;
            }
            else {
                dest_height = 150;
                dest_width = 150*ratio;
            }

            icon_ctx.drawImage(
                ctx.canvas,
                bounding_box.x_min,
                bounding_box.y_min,
                bbox_width,
                bbox_height,
                0,
                0,
                dest_width,
                dest_height
            );
            icons.push({canvas: icon_canvas, country: country});
        }
    };

    self.icons = function () {
        return icons;
    };

    return self;
};
