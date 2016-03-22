var Map = function (ctx, scanlines, gam_info, texture) {
    var self = {};
    var selected_region = null;

    var init = function () {
    };

    /* Get the region that the event is over or null if it's not over a region */
    self.evtRegion = function (e) {
        var i, j;
        var x = e.pageX;
        var y = e.pageY;

        /* Search through the scanlines and figure out if we're on one of
         * them. If so, return the name of that region. */
        for (region in scanlines) {
            for (j = 0; j < scanlines[region].length; ++j)
                if (
                    y == scanlines[region][j].y &&
                    x > scanlines[region][j].x &&
                    x < scanlines[region][j].x + scanlines[region][j].len
                )
                    return region;
        }
    };

    /* Draw all of the regions from all of the countries on the map */
    self.showRegions = function () {
        var i, j;
        var supply_centers = gam_info.countrySupplyCenters();
        console.log("Supply centers: ", supply_centers);

        j = 0;
        for (country in supply_centers) {
            for (i = 0; i < supply_centers[country].length; ++i)
                showRegion(
                    supply_centers[country][i],
                    cnt.countries[j].color
                );
            ++j;
        }

        textureRegions();
    };

    self.select = function (e) {
        if (!selected_region)
            selected_region = self.evtRegion(e);
        showRegion(selected_region);
    };

    self.clearRegions = function (e) {
    };

    /* After we have drawn all of our regions, we will fill them in with the
     * correct texture */
    var textureRegions = function () {
        ctx.globalCompositeOperation = 'source-in';
        ctx.drawImage(texture, 0, 0);
    };

    /* Show a particular region */
    var showRegion = function (region_name, color) {
        var i;

        console.log("Color: ", color);
        ctx.save();
        // ctx.strokeStyle="#107c1c";
        ctx.strokeStyle="#000000";
        /* Go through and draw all of the scanlines */
        var region_scanlines = scanlines[region_name];

        /* TODO: Is this efficient? */
        /* We draw out a solid shape for our texture. Using this, we can then draw
         * our texture over the top of it */
        for (i = 0; i < region_scanlines.length; i++) {
            ctx.beginPath();
            ctx.moveTo(region_scanlines[i].x, region_scanlines[i].y);
            ctx.lineTo(
                region_scanlines[i].x + region_scanlines[i].len,
                region_scanlines[i].y
            );
            ctx.stroke();
        }

        ctx.restore();
    };

    init();
    return self;
};
