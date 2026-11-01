if(global.game_state!="play")exit;
age++;
if(age>(landed?2400:3600)){instance_destroy();exit;}
fall_speed = min(fall_speed + gravity_speed, fall_max);
var _next_y = y + fall_speed;
var _landing_y = scr_world_landing_surface(x - 18, x + 18, y + 18, _next_y + 18);
if (_landing_y != noone) {
    y = _landing_y - 18;
    fall_speed = 0;
    if(!landed){landed=true;age=0;}
} else if (!scr_world_aabb_solid(x - 18, _next_y - 18, x + 18, _next_y + 18)) {
    y = _next_y;
}
