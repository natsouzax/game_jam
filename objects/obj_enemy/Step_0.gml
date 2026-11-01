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
        phase+=0.035;
        x+=walk_dir*patrol_speed;
        if(x<64){x=64;walk_dir=1;}
        else if(x>room_width-64){x=room_width-64;walk_dir=-1;}
        if(star_landed) {
            var _support=scr_world_landing_surface(x-hit_radius,x+hit_radius,y+hit_radius-1,y+hit_radius+1);
            if(_support!=noone) {y=_support-hit_radius;star_fall_speed=0;}
            else star_landed=false;
        }
        if(!star_landed) {
            star_fall_speed=min(star_fall_speed+0.18,5);
            var _next_star_y=y+star_fall_speed;
            var _star_surface=scr_world_landing_surface(x-hit_radius,x+hit_radius,y+hit_radius,_next_star_y+hit_radius);
            if(_star_surface!=noone) {y=_star_surface-hit_radius;star_landed=true;star_fall_speed=0;}
            else y=_next_star_y;
        }
        fall_t=clamp(star_fall_speed/5,0,1);
        if(y>room_height+hit_radius+80){instance_destroy();exit;}
        break;
    case 4:
        phase+=0.020;
        var _metal_fall=phase mod 1;
        fall_t=_metal_fall;
        x+=walk_dir*patrol_speed;
        if(x<64){x=64;walk_dir=1;}
        else if(x>room_width-64){x=room_width-64;walk_dir=-1;}
        y=home_y-fall_range/2+_metal_fall*fall_range;
        break;
    default:
        phase+=0.08;
        x+=walk_dir*patrol_speed;
        if(x<64){x=64;walk_dir=1;}
        else if(x>room_width-64){x=room_width-64;walk_dir=-1;}
        y=home_y+sin(phase*2)*bob_amount;
        break;
}
for(var _i=0;_i<2;_i++) {
    var _p=instance_find((_i==0?obj_player_p1:obj_player_p2),0);
    if(_p!=noone && _p.active_player && !_p.dead && _p.invulnerable<=0 && !(_p.player_number==0 && _p._hthrust>0) && point_distance(x,y,_p.x,_p.y-35)<hit_radius) {
        // stomp: player falling and above the enemy
        var _stomp=(_p.vy>=0 && (_p.y-35)<y && abs(_p.x-x)<28);
        if(kind==3 && _p.vy<=0)_stomp=false;
        if (_stomp) {
            if(kind==3) {
                _p.material_count+=4;
                _p.collected_total+=4;
                _p.vy=_p.jump_speed;
                _p.invulnerable=10;
                scr_sfx(sfx_collect,0.05);
                instance_destroy();
                exit;
            }
            hp--;
            _p.vy = _p.jump_speed;
            _p.invulnerable = 10;
            scr_sfx(sfx_hit, 0.04);
            if (hp <= 0) { _p.material_count++; instance_destroy(); exit; }
        } else {
            if(kind==3) with(_p){enemy_hits++;scr_player_die(STAR_STUN_FRAMES);}
            else with(_p){enemy_hits++;scr_player_die();}
        }
    }
}
