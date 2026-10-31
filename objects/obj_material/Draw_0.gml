// Brilho externo e losango violeta com centro claro.
draw_set_color(make_color_rgb(236, 190, 255));
draw_triangle(x, y - 18, x + 18, y, x - 18, y, false);
draw_triangle(x - 18, y, x, y + 18, x + 18, y, false);
draw_set_color(make_color_rgb(173, 65, 238));
draw_triangle(x, y - 14, x + 14, y, x - 14, y, false);
draw_triangle(x - 14, y, x, y + 14, x + 14, y, false);
draw_set_color(make_color_rgb(255, 231, 255));
draw_triangle(x, y - 7, x + 7, y, x - 7, y, false);
draw_triangle(x - 7, y, x, y + 7, x + 7, y, false);
draw_set_color(c_white);
