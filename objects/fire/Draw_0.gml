// Cada pose da fogueira é um sprite independente dentro da pasta scene/fire.
var fire_frames = [
    fire_frame_01,
    fire_frame_02,
    fire_frame_03,
    fire_frame_04
];
var frame = floor(current_time / 480) mod array_length(fire_frames);

// Os quadros têm bastante margem transparente; a origem fica no topo central.
// Escala 0.2 mantém a fogueira dentro da sala e alinha a base ao chão (y = 672).
draw_sprite_ext(fire_frames[frame], 0, x, y - 60, 0.05, 0.05, 0, c_white, 1);
