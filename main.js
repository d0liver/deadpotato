window.onload = function () {
    console.log("Window loaded");
    var map_img = document.getElementById("map-image");
    var canvas = document.getElementById("map");
    canvas.width = map_img.offsetWidth;
    canvas.height = map_img.offsetHeight;

    var ctx = document.getElementById("map").getContext('2d');
    var texture_builder = TextureBuilder();
    var diagonal_lines_texture =
        texture_builder.diagonalLines(
            map_img.offsetWidth,
            map_img.offsetHeight
        );
    console.log("Map: ", map_data);
    var gam_info = GameInfo(scanlines, cnt, map_data, varr);
    var texture_builder = TextureBuilder(); 
    var region_textures = RegionTexture(gam_info, texture_builder);
    var map = Map(ctx, gam_info, region_textures);
    map.showRegions();

    // window.onmousemove = function (e) {
    //     map.showRegion(e);
    // };
};
