var diagonalLinesTexture = function (width, height) {
    /* TODO: Make this use an angle rather than a fixed offset */
    var i;
    var diagonal_lines = document.createElement("canvas");
    diagonal_lines.width = width;
    diagonal_lines.height = height;
    var ctx = diagonal_lines.getContext("2d");
    ctx.strokeStyle="#ff0000";

    for (i = -400; i < width; i += 4) {
        ctx.beginPath();
        ctx.moveTo(i, 0);
        ctx.lineTo(i + 400, height);
        ctx.stroke();
    }

    return diagonal_lines;
};
