if (global.game_state != "play") exit;
hover_phase += 0.04;
attack_timer = max(0, attack_timer - 1);

// Avoid nearest player: stay high and drift away horizontally when close.
var _nearest=noone; var _nd=100000;
for(var _i=0;_i<2;_i++) {
    var _pp=instance_find((_i==0?obj_player_p1:obj_player_p2),0);
    if(_pp!=noone && _pp.active_player && !_pp.dead) {
        var _d=point_distance(x,y,_pp.x,_pp.y);
        if(_d<_nd){_nd=_d;_nearest=_pp;}
    }
}
if(_nearest!=noone && state==0) {
    if(x<_nearest.x) start_x -= 0.45;
    else start_x += 0.45;
    start_x=clamp(start_x,80,room_width-80);
    var _high_target=min(start_y,_nearest.y-180);
    base_y=lerp(base_y,max(64,_high_target),0.04);
}

if (state == 0) {
    x = lerp(x, start_x + sin(hover_phase * 0.7) * 50, 0.06);
    y = base_y + sin(hover_phase) * 10;
    if (attack_timer <= 0) {
        if(_nearest!=noone) {
            target = _nearest;
            target_x = _nearest.x;
            target_y = _nearest.y - 25;
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
        attack_timer = 6 * 60;
        start_x = x;
        start_y = max(80, y - 140);
        base_y = start_y;
    }
}

// Collision with players: stomp kills foguinho safely; hitting player damages player and kills foguinho.
for (var _i = 0; _i < 2; _i++) {
    var _p = instance_find((_i == 0 ? obj_player_p1 : obj_player_p2), 0);
    if (_p == noone || !_p.active_player || _p.dead || _p.invulnerable > 0) continue;
    if (_p.player_number == 0 && _p._hthrust > 0) continue;
    if (point_distance(x, y, _p.x, _p.y - 35) < 32) {
        if (_p.vy >= 0 && (_p.y - 35) < y && abs(_p.x - x) < 28) {
            hp--;
            _p.vy = _p.jump_speed;
            _p.invulnerable = 10;
            scr_sfx(sfx_hit, 0.04);
            instance_destroy();
            exit;
        } else {
            scr_sfx(sfx_hit, 0.04);
            with (_p) { enemy_hits++; scr_player_die(); }
            instance_destroy();
            exit;
        }
    }
}