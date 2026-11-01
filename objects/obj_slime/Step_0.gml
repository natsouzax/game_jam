if(global.game_state!="play")exit;
phase+=0.05;
// gravity
vy=min(vy+gravity_speed,10);
var _ny=y+vy;
if(vy>0) {
    var _land=scr_world_landing_surface(x-12,x+12,y,_ny);
    if(_land!=noone){y=_land;vy=0;grounded=true;}
    else y=_ny;
} else if(!scr_world_aabb_solid(x-12,_ny-12,x+12,_ny+12,true)) y=_ny;
else vy=0;
grounded=scr_world_aabb_solid(x-12,y,x+12,y+1);
// horizontal movement along blocks
var _nx=x+dir*move_speed;
if(!scr_world_aabb_solid(_nx-12,y-12,_nx+12,y+12,true)) {
    x=_nx;
} else {
    dir=-dir;
}
// reverse at platform edges
if(grounded && !scr_world_aabb_solid(x+dir*14,y+2,x+dir*14,y+2,true)) {
    dir=-dir;
}
x=clamp(x,16,room_width-16);
// collision with players
for(var _i=0;_i<2;_i++) {
    var _p=instance_find((_i==0?obj_player_p1:obj_player_p2),0);
    if(_p==noone || !_p.active_player || _p.dead || _p.invulnerable>0) continue;
    if(point_distance(x,y,_p.x,_p.y-35)<24) {
        if(_p.vy>0 && (_p.y-35)<y && abs(_p.x-x)<20) {
            hp--;_p.vy=_p.jump_speed;_p.invulnerable=10;scr_sfx(sfx_hit,0.04);
            if(hp<=0) instance_destroy();
        } else {
            with(_p){enemy_hits++;scr_player_die();}
        }
    }
}