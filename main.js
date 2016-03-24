window.onload = function () {
    var map_img = document.getElementById("map-image");
    var canvas = document.getElementById("map");
    canvas.width = map_img.offsetWidth;
    canvas.height = map_img.offsetHeight;

    var ctx = document.getElementById("map").getContext('2d');
    var texture_builder = TextureBuilder();
    var gam_info = GameInfo(scanlines, cnt, map_data, varr);
    var texture_builder = TextureBuilder(); 
    var region_textures = RegionTexture(gam_info, texture_builder);
    region_textures.build();
    var map = Map(ctx, gam_info, region_textures);
    map.showRegions();

    // window.onmousemove = function (e) {
    //     map.showRegion(e);
    // };
};
