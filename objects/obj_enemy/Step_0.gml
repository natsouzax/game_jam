if(global.game_state!="play")exit;
switch(kind) {
    case 0:
        phase+=0.08;
        x+=walk_dir*patrol_speed;
        if(x<96 || x>room_width-96) walk_dir=-walk_dir;
        y=home_y+sin(phase*4)*2;
        break;
    case 1:
        phase+=patrol_speed;
        x=home_x+sin(phase)*orbit_reach;
        y=home_y+sin(phase*2.7)*bob_amount;
        break;
    case 3:
        phase+=patrol_speed;
        var _star_fall=phase mod 1;
        if(_star_fall<fall_t) home_x=irandom_range(120,room_width-120);
        fall_t=_star_fall;
        x=home_x+sin(phase*6)*34;
        y=home_y-fall_range/2+_star_fall*fall_range;
        break;
    case 4:
        phase+=patrol_speed;
        var _metal_fall=phase mod 1;
        if(_metal_fall<fall_t) home_x=irandom_range(120,room_width-120);
        fall_t=_metal_fall;
        x=home_x+sin(phase*3)*18;
        y=home_y-fall_range/2+_metal_fall*fall_range;
        break;
    default:
        phase+=patrol_speed;
        x=home_x+sin(phase)*orbit_reach;
        y=home_y+sin(phase*2)*bob_amount;
        break;
}
for(var _i=0;_i<2;_i++) {
    var _p=instance_find((_i==0?obj_player_p1:obj_player_p2),0);
    if(_p!=noone && _p.active_player && !_p.dead && _p.invulnerable<=0 && point_distance(x,y,_p.x,_p.y-35)<hit_radius) {
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