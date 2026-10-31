if(global.game_state!="play")exit;
hover_phase+=0.035;
attack_timer=max(0,attack_timer-1);

if(state==0) {
    base_y=lerp(base_y,start_y,0.04);
    x=start_x+sin(hover_phase*0.7)*80;
    y=base_y+sin(hover_phase*1.3)*16;
    if(attack_timer<=0) {
        var _best=noone;var _best_d=100000;
        for(var _i=0;_i<2;_i++) {
            var _p=instance_find((_i==0?obj_player_p1:obj_player_p2),0);
            if(_p!=noone && _p.active_player && !_p.dead) {
                var _d=point_distance(x,y,_p.x,_p.y-35);
                if(_d<_best_d){_best=_p;_best_d=_d;}
            }
        }
        if(_best!=noone) {
            target=_best;
            target_x=_best.x;
            target_y=_best.y-35;
            start_x=x;
            start_y=y;
            attack_progress=0;
            state=1;
        } else attack_timer=60;
    }
} else {
    attack_progress++;
    var _t=clamp(attack_progress/attack_duration,0,1);
    var _s=_t*_t*(3-2*_t);
    x=lerp(start_x,target_x,_s);
    y=lerp(start_y,target_y,_s)-sin(_t*pi)*40;
    if(_t>=1) {
        state=0;
        attack_timer=irandom_range(300,480);
        start_x=x;
        start_y=y;
        base_y=y;
    }
}

for(var _j=0;_j<2;_j++) {
    var _pl=instance_find((_j==0?obj_player_p1:obj_player_p2),0);
    if(_pl==noone || !_pl.active_player || _pl.dead || _pl.invulnerable>0) continue;
    if(point_distance(x,y,_pl.x,_pl.y-35)<34) {
        if(_pl.vy>=0 && (_pl.y-35)<y && abs(_pl.x-x)<30) {
            hp--;
            _pl.vy=_pl.jump_speed;
            _pl.invulnerable=10;
            scr_sfx(sfx_hit,0.04);
            if(hp<=0){instance_destroy();exit;}
            state=0;
            attack_timer=irandom_range(240,420);
            start_x=x;
            start_y=y;
            base_y=y;
        } else {
            with(_pl){enemy_hits++;scr_player_die();}
        }
    }
}
