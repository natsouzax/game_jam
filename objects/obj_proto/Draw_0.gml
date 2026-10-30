draw_clear(make_color_rgb(24, 37, 53));
draw_set_color(make_color_rgb(88, 166, 112));
draw_rectangle(0, ground_y, room_width, room_height, false);
// Formas temporárias para testar controles, sem texto no jogo.
draw_set_color(make_color_rgb(255, 202, 83));
draw_rectangle(p1_x - 16, p1_y - 42, p1_x + 16, p1_y, false);
draw_set_color(make_color_rgb(117, 205, 255));
draw_rectangle(p2_x - 16, p2_y - 42, p2_x + 16, p2_y, false);
draw_set_color(c_white);
