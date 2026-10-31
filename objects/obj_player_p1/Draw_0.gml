var run_frame_w = 1774 / 6;
var run_frame_h = 430;
var draw_x = x - 40 * facing;
var draw_scale_x = 0.29 * facing;
var moving = keyboard_check(ord("A")) || keyboard_check(ord("D"));

if (y < ground_y - 1) {
    draw_sprite_part_ext(spr_player1_sheet, 0, 590, 440, 330, 440, draw_x, y - 116, draw_scale_x, 0.27, c_white, 1);
} else if (moving) {
    var run_frame = floor(current_time / 110) mod 6;
    draw_sprite_part_ext(spr_player1_sheet, 0, run_frame * run_frame_w, 0, run_frame_w, run_frame_h, draw_x, y - 116, draw_scale_x, 0.27, c_white, 1);
} else {
    // A sprite idle tem quatro poses numa folha 2x2.
    var idle_frame_w = 1235 / 2;
    var idle_frame_h = 1274 / 2;
    var idle_frame = floor(current_time / 450) mod 4;
    var idle_src_x = (idle_frame mod 2) * idle_frame_w;
    var idle_src_y = floor(idle_frame / 2) * idle_frame_h;
    draw_sprite_part_ext(spr_player1_idle, 0, idle_src_x, idle_src_y, idle_frame_w, idle_frame_h, x - 58 * facing, y - 116, draw_scale_x, 0.19, c_white, 1);
}

draw_set_color(make_color_rgb(173, 65, 238));
for (var i = 0; i < material_count; i++) {
    var icon_x = x + (i - (material_count - 1) * 0.5) * 14;
    var icon_y = y - 126;
    draw_triangle(icon_x, icon_y - 5, icon_x + 5, icon_y, icon_x - 5, icon_y, false);
    draw_triangle(icon_x, icon_y + 5, icon_x + 5, icon_y, icon_x - 5, icon_y, false);
}
draw_set_color(c_white);
