// The city follows the camera, but slower the higher the climb, so altitude opens gradually.
var _view_h = 768;
var _start = room_height - _view_h;
var _climbed = max(0, _start - camera_y);
var _altitude = clamp(_climbed / max(1, _start), 0, 1);
altitude = _altitude;
var _follow = lerp(0.12, 0.04, _altitude);
// Background moves slowly downward as the player climbs (opposite to the camera).
var _target = _start + _climbed * 0.16;
bg_y = lerp(bg_y, _target, lerp(0.01, 0.004, _altitude));

var _top = camera_y - 48;
var _bottom = camera_y + _view_h + 48;
var _sky = make_color_rgb(lerp(28, 78, _altitude), lerp(24, 112, _altitude), lerp(36, 162, _altitude));
draw_set_color(_sky);
draw_rectangle(0, _top, room_width, _bottom, false);
// A sun that is left behind even more slowly than the skyline.
var _sun_y = _start + 150 - _climbed * lerp(0.22, 0.08, _altitude);
draw_set_alpha(0.85);
draw_set_color(make_color_rgb(255, 186, 110));
draw_circle(980, _sun_y, 34 + _altitude * 10, false);
draw_set_alpha(0.18);
draw_circle(980, _sun_y, 70 + _altitude * 18, false);
draw_set_alpha(1);
for (var _i = 0; _i < 18; _i++) {
    var _x = _i * 84;
    var _col_top = bg_y + 90 + (_i mod 4) * 70;
    draw_set_color(make_color_rgb(52 + _i mod 3 * 6, 43, 51));
    draw_rectangle(_x, _col_top, _x + 54, _col_top + 520, false);
}
var _sprite = ChatGPT_Image_31_Oct_2026__02_56_25;
var _sx = room_width / sprite_get_width(_sprite);
var _sy = _view_h / sprite_get_height(_sprite);
var _tint = make_color_rgb(lerp(255, 176, _altitude), lerp(255, 198, _altitude), lerp(255, 232, _altitude));
draw_sprite_ext(_sprite, 0, 0, bg_y, _sx, _sy, 0, _tint, 1);

if (global.game_state == "ending") {
    var _amount = clamp(ending_timer / 180, 0, 1);
    draw_set_color(make_color_rgb(108, 185, 108));
    for (var _k = 0; _k < instance_number(obj_build_block); _k++) {
        var _b = instance_find(obj_build_block, _k);
        draw_line_width(_b.x + 8, _b.y, _b.x + 8, _b.y - 22 * _amount, 3);
        draw_ellipse(_b.x + 5, _b.y - 20 * _amount, _b.x + 20, _b.y - 10 * _amount, false);
    }
}
draw_set_alpha(1);
draw_set_color(c_white);

// The floor silhouette matches the two collision banks exactly.
var _floor=scr_floor_y();
draw_set_color(make_color_rgb(10,13,23));
draw_rectangle(540,_floor,826,room_height,false);
for(var _bank=0;_bank<2;_bank++) {
    var _left=(_bank==0?0:826),_right=(_bank==0?540:room_width);
    draw_set_color(make_color_rgb(48,40,45));draw_rectangle(_left,_floor,_right,room_height,false);
    draw_set_color(make_color_rgb(122,111,105));draw_rectangle(_left,_floor,_right,_floor+12,false);
    draw_set_color(make_color_rgb(188,165,130));draw_rectangle(_left,_floor,_right,_floor+3,false);
    for(var _stone=_left;_stone<_right-8;_stone+=28) {
        draw_set_color(make_color_rgb(78,68,67));
        draw_rectangle(_stone+4,_floor+24,_stone+16,_floor+32,false);
    }
}
// Broken edges and a receding wall expose the depth of the central chasm.
for(var _edge=0;_edge<2;_edge++) {
    var _ex=(_edge==0?540:826);var _side=(_edge==0?-1:1);
    draw_set_color(make_color_rgb(97,74,68));
    for(var _crack=0;_crack<6;_crack++)
        draw_rectangle(min(_ex,_ex+_side*(12+_crack*4)),_floor+16+_crack*16,max(_ex,_ex+_side*(12+_crack*4)),_floor+24+_crack*16,false);
}
draw_set_color(c_white);draw_set_alpha(1);
