if (global.game_state != "play") exit;
var _frame = (global.game_timer div 8) mod 4;
var _fw = sprite_get_width(spr_foguinho) / 4;
var _fh = sprite_get_height(spr_foguinho);
var _scale = 0.35;
draw_sprite_part_ext(spr_foguinho, 0, _frame * _fw, 0, _fw, _fh,
    x - _fw * _scale / 2, y - _fh * _scale / 2, _scale, _scale, c_white, 1);
// hp indicator
draw_set_color(c_red);
for (var _h = 0; _h < hp; _h++) draw_rectangle(x - 10 + _h * 6, y - _fh * _scale / 2 - 8, x - 6 + _h * 6, y - _fh * _scale / 2 - 4, false);
draw_set_color(c_white);