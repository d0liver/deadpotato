window.onload = function () {
    console.log("Window loaded");
    var map_img = document.getElementById("map-image");
    var canvas = document.getElementById("map");
    canvas.width = map_img.offsetWidth;
    canvas.height = map_img.offsetHeight;

    var ctx = document.getElementById("map").getContext('2d');
    var diagonal_lines_texture =
        diagonalLinesTexture(map_img.offsetWidth, map_img.offsetHeight, 20);
    var map = Map(ctx, scanlines, diagonal_lines_texture);

    window.onmousemove = function (e) {
        map.showRegion(e);
    };
};
