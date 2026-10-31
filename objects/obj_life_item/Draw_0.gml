// heart
draw_set_color(make_color_rgb(255, 80, 120));
draw_circle(x - 6, y - 4, 7, false);
draw_circle(x + 6, y - 4, 7, false);
draw_triangle(x - 12, y, x + 12, y, x, y + 12, false);
draw_set_color(c_white);