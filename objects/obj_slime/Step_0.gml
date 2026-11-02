if(global.game_state!="play")exit;
// Emerging from the ground: no movement, gravity or collision until fully out.
if(spawn_t>0){spawn_t--;exit;}
phase+=0.08;

var _nx=x+dir*move_speed;
var _hit_wall=scr_world_aabb_solid(_nx-18,y-44,_nx+18,y-2,true);

// Slimes never climb player-built blocks: a wall just turns them around.
if(_hit_wall) {dir=-dir;_nx=x+dir*move_speed;}
{
    wall_dir=0;
    vy=min(vy+gravity_speed,9);
    var _ny=y+vy;
    if(vy>0) {
        var _land=scr_world_landing_surface(x-18,x+18,y,_ny);
        if(_land!=noone){y=_land;vy=0;grounded=true;}
        else {y=_ny;grounded=false;}
    } else if(!scr_world_aabb_solid(x-18,_ny-46,x+18,_ny,true)) {
        y=_ny;grounded=false;
    } else vy=0;

    grounded=scr_world_aabb_solid(x-18,y,x+18,y+2);
    if(grounded) {
        // Turn around at ledges (checkpoint platforms count as ground) so the slime keeps patrolling.
        if(!scr_world_aabb_solid(_nx+dir*16-2,y,_nx+dir*16+2,y+6)) {
            dir=-dir;
            _nx=x+dir*move_speed;
        }
    }
    if(!scr_world_aabb_solid(_nx-26,y-50,_nx+26,y-2,true)) {
        x=_nx;
    } else {
        dir=-dir;
    }
}

if(x<=24){x=24;dir=1;}
if(x>=room_width-24){x=room_width-24;dir=-1;}

// Collision with players: a falling player landing on top stomps it; any other contact hurts the player.
for(var _i=0;_i<2;_i++) {
    var _p=instance_find((_i==0?obj_player_p1:obj_player_p2),0);
    if(_p==noone || !_p.active_player || _p.dead || _p.invulnerable>0) continue;
    if(_p.player_number==0 && _p._hthrust>0) continue;
    if(abs(_p.x-x)<44 && _p.y>y-68 && _p.y-70<y+4) {
        if(_p.vy>0 && _p.y<y-30) {
            hp--;_p.vy=_p.jump_speed;_p.invulnerable=10;scr_sfx(sfx_hit,0.04);
            if(hp<=0) { _p.material_count++; scr_sfx(sfx_slime_die,0.06); instance_destroy(); exit; }
        } else {
            with(_p){enemy_hits++;scr_player_die();}
        }
    }
}
