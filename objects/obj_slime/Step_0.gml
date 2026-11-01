if(global.game_state!="play")exit;
phase+=0.08;

var _nx=x+dir*move_speed;
var _hit_wall=scr_world_aabb_solid(_nx-12,y-22,_nx+12,y-2,true);

if(_hit_wall) {
    // Climb up the side of player-placed blocks at 30% player speed.
    wall_dir=-1;
    vy=0;
    var _climb_y=y-move_speed;
    if(!scr_world_aabb_solid(x-12,_climb_y-24,x+12,_climb_y-2,true)) {
        y=_climb_y;
        // Once above the wall lip, step onto the top surface.
        if(!scr_world_aabb_solid(_nx-12,y-22,_nx+12,y-2,true)) {
            x=_nx;
            wall_dir=0;
        }
    } else {
        dir=-dir;
        wall_dir=0;
    }
} else {
    wall_dir=0;
    vy=min(vy+gravity_speed,9);
    var _ny=y+vy;
    if(vy>0) {
        var _land=scr_world_landing_surface(x-12,x+12,y,_ny);
        if(_land!=noone){y=_land;vy=0;grounded=true;}
        else {y=_ny;grounded=false;}
    } else if(!scr_world_aabb_solid(x-12,_ny-24,x+12,_ny,true)) {
        y=_ny;grounded=false;
    } else vy=0;

    grounded=scr_world_aabb_solid(x-12,y,x+12,y+2);
    if(grounded) {
        // Turn around at ledges so the slime keeps patrolling across surfaces.
        if(!scr_world_aabb_solid(_nx+dir*10-2,y,_nx+dir*10+2,y+6,true)) {
            dir=-dir;
            _nx=x+dir*move_speed;
        }
    }
    if(!scr_world_aabb_solid(_nx-12,y-22,_nx+12,y-2,true)) {
        x=_nx;
    } else {
        dir=-dir;
    }
}

if(x<=24){x=24;dir=1;}
if(x>=room_width-24){x=room_width-24;dir=-1;}

// Collision with players (stomp on head kills slime; side contact hurts player).
for(var _i=0;_i<2;_i++) {
    var _p=instance_find((_i==0?obj_player_p1:obj_player_p2),0);
    if(_p==noone || !_p.active_player || _p.dead || _p.invulnerable>0) continue;
    if(_p.player_number==0 && _p._hthrust>0) continue;
    if(point_distance(x,y-10,_p.x,_p.y-35)<26) {
        if(_p.vy>=0 && (_p.y-35)<y-6 && abs(_p.x-x)<24) {
            hp--;_p.vy=_p.jump_speed;_p.invulnerable=10;scr_sfx(sfx_hit,0.04);
            if(hp<=0) { instance_destroy(); exit; }
        } else {
            with(_p){enemy_hits++;scr_player_die();}
        }
    }
}