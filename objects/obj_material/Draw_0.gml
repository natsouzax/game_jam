// Brilho externo e losango violeta com centro claro.
// Blink during the last 2 s on the ground so the player sees it is about to disappear.
if(landed && age>300 && (age div 6) mod 2==0) draw_set_alpha(0.35);
draw_set_color(make_color_rgb(236, 190, 255));
draw_triangle(x, y - 18, x + 18, y, x - 18, y, false);
draw_triangle(x - 18, y, x, y + 18, x + 18, y, false);
draw_set_color(make_color_rgb(173, 65, 238));
draw_triangle(x, y - 14, x + 14, y, x - 14, y, false);
draw_triangle(x - 14, y, x, y + 14, x + 14, y, false);
draw_set_color(make_color_rgb(255, 231, 255));
draw_triangle(x, y - 7, x + 7, y, x - 7, y, false);
draw_triangle(x - 7, y, x, y + 7, x + 7, y, false);
draw_set_alpha(1);
draw_set_color(c_white);
