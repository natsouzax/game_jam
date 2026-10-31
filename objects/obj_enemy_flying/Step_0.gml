if (global.game_state != "play") exit;
hover_phase += 0.03;
attack_timer = max(0, attack_timer - 1);

if (state == 0) {
    // smooth hover
    base_y = lerp(base_y, start_y, 0.05);
    x = start_x + sin(hover_phase * 0.7) * 60;
    y = base_y + sin(hover_phase) * 12;
    if (attack_timer <= 0) {
        var _best = noone; var _best_d = 100000;
        for (var _i = 0; _i < 2; _i++) {
            var _p = instance_find((_i == 0 ? obj_player_p1 : obj_player_p2), 0);
            if (_p != noone && _p.active_player && !_p.dead) {
                var _d = point_distance(x, y, _p.x, _p.y);
                if (_d < _best_d) { _best = _p; _best_d = _d; }
            }
        }
        if (_best != noone) {
            target = _best;
            target_x = _best.x;
            target_y = _best.y;
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
    // smoothstep easing for predictable motion
    var _s = _t * _t * (3 - 2 * _t);
    // horizontal: smooth toward target
    x = lerp(start_x, target_x, _s);
    // vertical: gentle arc
    var _arc = sin(_t * pi) * 50;
    y = lerp(start_y, target_y, _s) - _arc;
    if (_t >= 1) {
        state = 0;
        attack_timer = 7 * 60;
        start_x = x;
        start_y = y;
        base_y = y;
    }
}

// collision with players
for (var _i = 0; _i < 2; _i++) {
    var _p = instance_find((_i == 0 ? obj_player_p1 : obj_player_p2), 0);
    if (_p == noone || !_p.active_player || _p.dead || _p.invulnerable > 0) continue;
    if (point_distance(x, y, _p.x, _p.y - 35) < 32) {
        if (_p.vy >= 0 && (_p.y - 35) < y && abs(_p.x - x) < 28) {
            hp--;
            _p.vy = _p.jump_speed;
            _p.invulnerable = 10;
            scr_sfx(sfx_hit, 0.04);
            if (hp <= 0) { instance_destroy(); exit; }
            state = 0;
            attack_timer = 7 * 60;
            start_x = x;
            start_y = y;
            base_y = y;
        } else {
            with (_p) { enemy_hits++; scr_player_die(); }
        }
    }
}