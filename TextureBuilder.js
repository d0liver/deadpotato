var TextureBuilder = function () {
    var self = {};

    var colors = {
        forest: "#228b22",
        charcoal: "#36454f",
        red: "red",
        brown: "brown",
        teal: "teal",
        blue: "blue",
        orange: "orange",
        navy: "#000080"
    };

    self.texture = function (width, height, color) {
        var i;
        var canvas = document.createElement("canvas");
        canvas.width = width;
        canvas.height = height;
        var ctx = canvas.getContext("2d");
        ctx.strokeStyle = colors[color];

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
