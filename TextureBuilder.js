var TextureBuilder = function (color_map) {
    var self = {};

    self.texture = function (width, height, color) {
        var i;
        var canvas = document.createElement("canvas");
        canvas.width = width;
        canvas.height = height;
        var ctx = canvas.getContext("2d");
        ctx.strokeStyle = color_map.map(color);

        for (i = 0; i < height; i += 4) {
            ctx.beginPath();
            ctx.moveTo(0, i);
            ctx.lineTo(width, i);
            ctx.stroke();
        }

        return canvas;
    };

    return self;
};
