var Map = function (ctx, gam_info, region_textures) {
    var self = {};
    var selected_region = null;

    var init = function () {
    };

    /* Get the region that the event is over or null if it's not over a region */
    self.evtRegion = function (e) {
        var i, j;
        var x = e.pageX;
        var y = e.pageY;
        var rgn = gam_info.rgns();

        /* Search through the scanlines and figure out if we're on one of
         * them. If so, return the name of that region. */
        for (region in scanlines) {
            for (j = 0; j < scanlines[region].length; ++j) {
                var scanlines = rgns[region].scanlines[j];
                if (
                    y == scanlines[j].y &&
                    x > scanlines[j].x &&
                    x < scanlines[j].x +scanlines[j].len
                )
                    return region;
            }
        }
    };

    /* Draw all of the regions from all of the countries on the map */
    self.showRegions = function () {
        var j;
        var supply_centers = gam_info.countrySupplyCenters();

        j = 0;
        for (country in supply_centers) {
            for (var i = 0; i < supply_centers[country].length; ++i)
                region_textures.draw(ctx, supply_centers[country][i]);
            ++j;
        }
    };

    /* Draw an arrow from one region1 to region2 */
    self.arrow = function (region1, region2) {
        var r1_coords = gam_info.unitPos(region1);
        var r2_coords = gam_info.unitPos(region2);

        ctx.beginPath();
        ctx.moveTo(r1_coords.x, r1_coords.y);
        ctx.lineTo(r2_coords.x, r2_coords.y);
        ctx.stroke();
    };

    self.select = function (e) {
        if (!selected_region)
            selected_region = self.evtRegion(e);
        showRegion(selected_region);
    };

    self.clearRegions = function (e) {
    };

    init();
    return self;
};
