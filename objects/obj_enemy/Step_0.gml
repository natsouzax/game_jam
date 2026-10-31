if(global.game_state!="play")exit;
phase+=0.035;x=672+sin(phase)*240;y=home_y+sin(phase*2)*16;
for(var _i=0;_i<2;_i++) {
    var _p=instance_find((_i==0?obj_player_p1:obj_player_p2),0);
    if(_p!=noone && _p.active_player && !_p.dead && _p.invulnerable<=0 && point_distance(x,y,_p.x,_p.y-35)<32) {
        // stomp: player falling and above the enemy
        if (_p.vy >= 0 && (_p.y - 35) < y && abs(_p.x - x) < 28) {
            hp--;
            _p.vy = _p.jump_speed;
            _p.invulnerable = 10;
            scr_sfx(sfx_hit, 0.04);
            if (hp <= 0) { instance_destroy(); }
        } else {
            with(_p){enemy_hits++;scr_player_die();}
        }
    }
}