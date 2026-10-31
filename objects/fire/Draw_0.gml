// Cada pose da fogueira é um sprite independente dentro da pasta scene/fire.
var fire_frames = [
    fire_frame_01, fire_frame_02, fire_frame_03,
    fire_frame_04, fire_frame_05, fire_frame_06,
    fire_frame_07, fire_frame_08, fire_frame_09
];
var frame = floor(current_time / 180) mod array_length(fire_frames);
draw_sprite_ext(fire_frames[frame], 0, x - 205, y - 136, 0.8, 0.8, 0, c_white, 1);
