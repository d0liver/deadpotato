var Map = function (
        ctx, select_ctx,
        gam_info, region_textures
) {
    var self = {};
    var selected_region = null;

    var init = function () {
    };

    /* Get the region that the event is over or null if it's not over a region */
    self.evtRegion = function (e) {
        var i, j;
        var x = e.pageX;
        var y = e.pageY;
        var rgns = gam_info.rgns();

        /* Search through the scanlines and figure out if we're on one of
         * them. If so, return the name of that region. */
        for (region in regions) {
            var scanlines = region.scanlines;
            for (j = 0; j < scanlines[region].length; ++j) {
                var scanlines = scanlines[j];
                if (
                    y == scanlines[j].y &&
                    x > scanlines[j].x &&
                    x < scanlines[j].x +scanlines[j].len
                )
                    return region.name;
            }
        }
    };

    self.selectRegion = function (e) {
        var sel_canvas = select_ctx.canvas;
        var selected_region = self.evtRegion(e);

        /* We will blacken the selected region */
        if (selected_region) {
            select_ctx.clearRect(0, 0, sel_canvas.width, sel_canvas.height);
            var scanlines = gam_info.regionScanLines(selected_region);
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
        var triangle_side = 10;
        var r1_coords = gam_info.unitPos(region1);
        var r2_coords = gam_info.unitPos(region2);
        var scale = 6;

        /* First draw the line connecting the regions */
        ctx.beginPath();
        ctx.moveTo(r1_coords.x, r1_coords.y);
        ctx.lineTo(r2_coords.x, r2_coords.y);
        ctx.stroke();

        /* Then draw the arrow at the tip of the line. We want to draw an
         * isosceles triangle whose bottom edge is centered on r2_coords. */
        ctx.translate(r2_coords.x, r2_coords.y);
        var angle = Math.PI - Math.atan2(
            r2_coords.x - r1_coords.x,
            r2_coords.y - r1_coords.y
        );
        ctx.rotate(angle);
        ctx.beginPath();
        /* Bottom left corner */
        ctx.moveTo(-scale, 0);
        /* Bottom right corner */
        ctx.lineTo(scale, 0);
        /* Top corner */
        ctx.lineTo(0, 2*-scale);
        ctx.closePath();
        ctx.fill();
        ctx.setTransform(1, 0, 0, 1, 0, 0);

        /* Now, draw the circle from the origin */
        ctx.arc(r1_coords.x, r1_coords.y, scale, 0, Math.PI*2, true);
        ctx.fill();
    };

    var selectRegion = function (region) {
        console.log("Selected region: ", region);
    };

    self.select = function (e) {
        selected_region = self.evtRegion(e);
        selectRegion(selected_region);
    };

    self.clearRegions = function (e) {
    };

    init();
    return self;
};
