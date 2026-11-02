if(global.game_state!="play")exit;
// Only act while its platform is on screen.
var _cam_y=camera_get_view_y(view_camera[0]);
if(y<_cam_y-40 || y>_cam_y+768+80)exit;
phase+=0.04;
// nearest living player
var _target=noone;var _best_d=100000;
for(var _i=0;_i<2;_i++) {
    var _tp=instance_find((_i==0?obj_player_p1:obj_player_p2),0);
    if(_tp==noone || !_tp.active_player || _tp.dead) continue;
    var _d=point_distance(x,y-50,_tp.x,_tp.y-35);
    if(_d<_best_d){_best_d=_d;_target=_tp;}
}
if(state==0) {
    if(anim_t==0) scr_sfx(sfx_skel_spawn,0.03,0.7);
    anim_t++;
    if(anim_t>=36){state=1;anim_t=0;}
} else {
    if(_target!=noone) face=(_target.x>=x?1:-1);
    if(state==1) {
        anim_t++;
        shoot_timer--;
        if(shoot_timer<=0) {
            if(_target!=noone && _best_d<600) {state=2;cast_t=0;scr_sfx(sfx_skel_charge,0.03,0.6);}
            else shoot_timer=30;
        }
    } else {
        cast_t++;
        // Hand glow (18 f), arm out (12 f), release, follow-through.
        if(cast_t==30 && _target!=noone) {
            var _hx=x+face*35;var _hy=y-56;
            var _dir=point_direction(_hx,_hy,_target.x,_target.y-35);
            var _proj=instance_create_layer(_hx,_hy,"Instances_1",obj_skeleton_projectile);
            _proj.vx=lengthdir_x(projectile_speed,_dir);
            _proj.vy=lengthdir_y(projectile_speed,_dir);
            _proj.owner=id;
            scr_sfx(sfx_skel_shoot,0.05,0.8);
        }
        if(cast_t>=44){state=1;anim_t=0;shoot_timer=irandom_range(60,100);}
    }
    // collision with players (stomp or damage)
    for(var _j=0;_j<2;_j++) {
        var _p=instance_find((_j==0?obj_player_p1:obj_player_p2),0);
        if(_p==noone || !_p.active_player || _p.dead || _p.invulnerable>0) continue;
        if(_p.player_number==0 && _p._hthrust>0) continue;
        // Contact box: wide enough that visibly touching the skeleton always hurts (player half-width 16 + ~24 for the body).
        if(abs(_p.x-x)<40 && _p.y>y-84 && _p.y-70<y+6) {
            if(_p.vy>=0 && _p.y<y-44) {
                hp--;_p.vy=_p.jump_speed;_p.invulnerable=10;scr_sfx(sfx_hit,0.04);
                if(hp<=0) { _p.material_count++; scr_sfx(sfx_skel_die,0.05); instance_destroy(); exit; }
            } else {
                with(_p){enemy_hits++;scr_player_die();}
            }
        }
    }
}
