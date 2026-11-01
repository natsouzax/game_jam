if(global.game_state!="play")exit;
var _p1=instance_find(obj_player_p1,0);var _p2=instance_find(obj_player_p2,0);
if(_p1==noone || _p2==noone)exit;
phase+=0.04;
teleport_timer=max(0,teleport_timer-1);
shoot_timer=max(0,shoot_timer-1);
// teleport far from both players
if(teleport_timer<=0) {
    var _best_x=room_width/2; var _best_y=scr_floor_y()-200; var _best_d=0;
    // find a spot far from both players
    for(var _t=0;_t<20;_t++) {
        var _cx=irandom_range(80,room_width-80);
        var _cy=irandom_range(80,scr_floor_y()-80);
        var _d1=point_distance(_cx,_cy,_p1.x,_p1.y);
        var _d2=point_distance(_cx,_cy,_p2.x,_p2.y);
        var _mind=min(_d1,_d2);
        if(_mind>_best_d){_best_d=_mind;_best_x=_cx;_best_y=_cy;}
    }
    x=_best_x; y=_best_y;
    teleport_timer=irandom_range(600,900);
    scr_sfx(sfx_hit,0.03);
}
// shoot projectile toward nearest player
if(shoot_timer<=0) {
    var _target=instance_find((_p1.active_player && (point_distance(x,y,_p1.x,_p1.y)<point_distance(x,y,_p2.x,_p2.y))?obj_player_p1:obj_player_p2),0);
    if(_target!=noone && _target.active_player && !_target.dead) {
        var _dir=point_direction(x,y,_target.x,_target.y-35);
        var _proj=instance_create_layer(x,y,"Instances_1",obj_skeleton_projectile);
        _proj.vx=lengthdir_x(projectile_speed,_dir);
        _proj.vy=lengthdir_y(projectile_speed,_dir);
        _proj.owner=id;
        shoot_timer=irandom_range(90,150);
    }
}
// collision with players (stomp or damage)
for(var _i=0;_i<2;_i++) {
    var _p=instance_find((_i==0?obj_player_p1:obj_player_p2),0);
    if(_p==noone || !_p.active_player || _p.dead || _p.invulnerable>0) continue;
    if(point_distance(x,y,_p.x,_p.y-35)<28) {
        if(_p.vy>0 && (_p.y-35)<y && abs(_p.x-x)<22) {
            hp--;_p.vy=_p.jump_speed;_p.invulnerable=10;scr_sfx(sfx_hit,0.04);
            if(hp<=0) instance_destroy();
        } else {
            with(_p){enemy_hits++;scr_player_die();}
        }
    }
}