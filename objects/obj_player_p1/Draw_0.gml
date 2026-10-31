var frame_w = 1774 / 6;
var frame_h = 435;
var draw_x = x - 40 * facing;
var draw_scale_x = 0.27 * facing;
var moving = keyboard_check(ord("A")) || keyboard_check(ord("D"));
if (y < ground_y - 1) {
    draw_sprite_part_ext(spr_player1_sheet, 0, 590, 440, 330, 440, draw_x, y - 88, draw_scale_x, 0.27, c_white, 1);
} else if (moving) {
    var frame = floor(current_time / 110) mod 6;
    draw_sprite_part_ext(spr_player1_sheet, 0, frame * frame_w, 0, frame_w, frame_h, draw_x, y - 88, draw_scale_x, 0.27, c_white, 1);
} else {
    draw_sprite_part_ext(spr_player1_sheet, 0, 0, 0, frame_w, frame_h, draw_x, y - 88, draw_scale_x, 0.27, c_white, 1);
}
