draw_sprite_stretched(image_4f96e963, 0, 0, 0, room_width, room_height);
var frame = floor(current_time / 220) mod 4;
draw_sprite_part_ext(spr_tower_energy_sheet, 0, frame * 543, 0, 543, 724, 1000, 430, 0.48, 0.30, c_white, 1);
draw_sprite_part_ext(spr_campfire_survivors_sheet, 0, frame * 543, 170, 543, 340, 24, 545, 0.55, 0.38, c_white, 1);
