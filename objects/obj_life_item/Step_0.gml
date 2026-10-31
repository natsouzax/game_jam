if (global.game_state != "play") exit;
age++; if (age > 600) { instance_destroy(); exit; }
fall_speed = min(fall_speed + gravity_speed, 12);
var _next_y = y + fall_speed;
var _landing_y = scr_world_landing_surface(x - 14, x + 14, y + 14, _next_y + 14);
if (_landing_y != noone) { y = _landing_y - 14; fall_speed = 0; }
else if (!scr_world_aabb_solid(x - 14, _next_y - 14, x + 14, _next_y + 14)) { y = _next_y; }

// pickup
for (var _i = 0; _i < 2; _i++) {
    var _p = instance_find((_i == 0 ? obj_player_p1 : obj_player_p2), 0);
    if (_p != noone && _p.active_player && !_p.dead && point_distance(x, y, _p.x, _p.y - 35) < 30) {
        _p.player_lives = min(3, _p.player_lives + 1);
        scr_sfx(sfx_collect, 0.03);
        instance_destroy();
        exit;
    }
}