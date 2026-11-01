if (global.game_state != "play") exit;
hover_phase += 0.06;
attack_timer = max(0, attack_timer - 1);

if (state == 0) {
    // hover high, away from players
    base_y = lerp(base_y, start_y - 120, 0.04);
    x = start_x + sin(hover_phase * 0.9) * 80;
    y = base_y + sin(hover_phase) * 10;
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
    var _s = _t * _t * (3 - 2 * _t);
    x = lerp(start_x, target_x, _s * fly_speed * 0.4);
    var _arc = sin(_t * pi) * 60;
    y = lerp(start_y, target_y, _s) - _arc;
    if (_t >= 1) {
        state = 0;
        attack_timer = 5 * 60;
        start_x = x;
        start_y = y + 120;
        base_y = start_y;
    }
}

// collision with players
for (var _i = 0; _i < 2; _i++) {
    var _p = instance_find((_i == 0 ? obj_player_p1 : obj_player_p2), 0);
    if (_p == noone || !_p.active_player || _p.dead || _p.invulnerable > 0) continue;
    if (point_distance(x, y, _p.x, _p.y - 35) < 40) {
        if (_p.vy > 0 && _p.y < y - 8) {
            hp--;
            _p.vy = _p.jump_speed;
            _p.invulnerable = 10;
            scr_sfx(sfx_hit, 0.04);
            if (hp <= 0) { instance_destroy(); exit; }
            state = 0;
            attack_timer = 5 * 60;
            start_x = x;
            start_y = y + 120;
            base_y = start_y;
        } else {
            with (_p) { enemy_hits++; scr_player_die(); }
        }
    }
}