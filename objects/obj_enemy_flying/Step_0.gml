if (global.game_state != "play") exit;
hover_phase += 0.04;
attack_timer = max(0, attack_timer - 1);

// avoid nearest player: drift away horizontally
var _nearest=noone; var _nd=100000;
for(var _i=0;_i<2;_i++) {
    var _pp=instance_find((_i==0?obj_player_p1:obj_player_p2),0);
    if(_pp!=noone && _pp.active_player && !_pp.dead) {
        var _d=point_distance(x,y,_pp.x,_pp.y);
        if(_d<_nd){_nd=_d;_nearest=_pp;}
    }
}
if(_nearest!=noone) {
    if(x<_nearest.x) start_x -= 0.3;
    else start_x += 0.3;
    start_x=clamp(start_x,80,room_width-80);
}

if (state == 0) {
    base_y = lerp(base_y, start_y - 100, 0.04);
    x = lerp(x, start_x, 0.05);
    y = base_y + sin(hover_phase) * 8;
    if (attack_timer <= 0) {
        if(_nearest!=noone && point_distance(x,y,_nearest.x,_nearest.y)>200) {
            target = _nearest;
            target_x = _nearest.x;
            target_y = _nearest.y;
            start_x = x;
            start_y = y;
            attack_progress = 0;
            state = 1;
        } else {
            attack_timer = 60;
        }
    }
} else {
    attack_progress++;
    var _t = clamp(attack_progress / attack_duration, 0, 1);
    var _s = _t * _t * (3 - 2 * _t);
    x = lerp(start_x, target_x, _s);
    var _arc = sin(_t * pi) * 40;
    y = lerp(start_y, target_y, _s) - _arc;
    if (_t >= 1) {
        state = 0;
        attack_timer = 7 * 60;
        start_x = x;
        start_y = y + 100;
        base_y = start_y;
    }
}

// collision with players
for (var _i = 0; _i < 2; _i++) {
    var _p = instance_find((_i == 0 ? obj_player_p1 : obj_player_p2), 0);
    if (_p == noone || !_p.active_player || _p.dead || _p.invulnerable > 0) continue;
    if (point_distance(x, y, _p.x, _p.y - 35) < 32) {
        // foguinho dies when hitting player
        hp--;
        _p.vy = _p.jump_speed;
        _p.invulnerable = 10;
        scr_sfx(sfx_hit, 0.04);
        if (hp <= 0) { instance_destroy(); exit; }
        state = 0;
        attack_timer = 7 * 60;
        start_x = x;
        start_y = y + 100;
        base_y = start_y;
    }
}