/* Given a TextureBuilder (builds a texture with given dimensions, we will
 * generate textures that nicely correspond to the regions given from the
 * GameInfo . This way, we can accommodate regions which are different colors
 * and which have different patterns. This wouldn't be possible otherwise with
 * compositing because we would have to make multiple calls to draw to get the
 * different colors/patterns which would result in bad things happening after
 * the first call (It would apply the compositing to everything on the canvas
 * including the stuff that had already been composited in).*/
var RegionTexture = function (gam_info, texture_builder) {
    var self = {};
    var textures = null;

    /* This must be called before the caller actually tries to get any textures
     * from us */
    self.build = function () {
        var rgns = gam_info.rgns();
        textures = {};

        for (region in rgns) {
            var bnds = bounds(rgns[region].scanlines);
            textures[region] =  {
                img: buildRegionTexture(
                    rgns[region].scanlines,
                    bnds,
                    gam_info.regionColor(region)
                ),
                bounds: bnds
            };
        }
    };

    /* Draw the texture for the region on the given canvas context */
    self.draw = function(ctx, region_name) {
        if (!textures)
            throw new Error("Textures were referenced before being built.");
        var texture = textures[region_name];

        ctx.drawImage(
            texture.img,
            texture.bounds.x.min,
            texture.bounds.y.min
        );
    };

    var buildRegionTexture = function (scanlines, bnds, color) {
        var canvas = document.createElement("canvas");
        var ctx = canvas.getContext('2d');
        canvas.width = bnds.x.max - bnds.x.min;
        canvas.height = bnds.y.max - bnds.y.min;

        ctx.strokeStyle = "#000000";
        /* First, draw the region onto the canvas in black. This is so that
         * we can source-in the texture next */
        fillRegion(ctx, scanlines, bnds);

        ctx.globalCompositeOperation = 'source-in';
        /* Next, draw the texture into the canvas */
        ctx.drawImage(
            texture_builder.texture(
                ctx.canvas.width,
                ctx.canvas.height,
                color
            ), 0, 0
        );

        return canvas;
    };

    /* Given the scanlines for a region and the bounds of the scanlines, just
     * draw them on the canvas. We don't change any of the settings on the
     * context here, we let the caller set them. */
    var fillRegion = function (ctx, scanlines, bnds) {
        var i;

        for (var i = 0; i < scanlines.length; ++i) {
            /* Translate the scanline to one that's relative to the canvas */
            var rel_scanline = {
                x1: scanlines[i].x - bnds.x.min,
                x2: scanlines[i].x - bnds.x.min + scanlines[i].len,
                y: scanlines[i].y - bnds.y.min,
                len: scanlines[i].len
            };
            ctx.beginPath();
            ctx.moveTo(rel_scanline.x1, rel_scanline.y);
            ctx.lineTo(rel_scanline.x2, rel_scanline.y);
            ctx.stroke();
        }
    };

    /* Given a set of scanlines for a region, figure out what the dimensions
     * are of the smallest rectangle that encloses them */
    var bounds = function (scanlines) {
        var i;
        /* We will use these to store the min and max for x and y */
        var x = {min: Infinity, max: -1}, y = {min: Infinity, max: -1};

        for (i = 0; i < scanlines.length; ++i) {
            if (scanlines[i].x < x.min)
                x.min = scanlines[i].x;
            else if (scanlines[i].x + scanlines[i].len > x.max)
                x.max = scanlines[i].x + scanlines[i].len;

            if (scanlines[i].y < y.min)
                y.min = scanlines[i].y;
            else if (scanlines[i].y > y.max)
                y.max = scanlines[i].y;
        }

        return {
            x: x,
            y: y
        };
    };

    return self;
};
