if (global.game_state != "play") exit;
hover_phase += 0.05;
attack_timer = max(0, attack_timer - 1);

if (state == 0) {
    base_y = y;
    y = base_y + sin(hover_phase) * 10;
    if (attack_timer <= 0) {
        // pick nearest active player
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
    var _t = attack_progress / attack_duration;
    if (_t >= 1) {
        state = 0;
        attack_timer = 7 * 60;
        y = base_y;
    } else {
        x = lerp(start_x, target_x, _t);
        var _rel = (x - target_x) / 40;
        y = target_y - 80 - (_rel * _rel * 40);
    }
}

// collision with players
for (var _i = 0; _i < 2; _i++) {
    var _p = instance_find((_i == 0 ? obj_player_p1 : obj_player_p2), 0);
    if (_p == noone || !_p.active_player || _p.dead || _p.invulnerable > 0) continue;
    if (point_distance(x, y, _p.x, _p.y - 35) < 40) {
        // jump on head?
        if (_p.vy > 0 && _p.y < y - 8) {
            hp--;
            _p.vy = _p.jump_speed;
            _p.invulnerable = 10;
            scr_sfx(sfx_hit, 0.04);
            if (hp <= 0) { instance_destroy(); exit; }
            state = 0;
            attack_timer = 7 * 60;
        } else {
            with (_p) { enemy_hits++; scr_player_die(); }
        }
    }
}