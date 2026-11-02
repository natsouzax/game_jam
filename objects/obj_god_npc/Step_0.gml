if(global.game_state!="play")exit;
walk_t++;
// Nearest active player, if any.
var _near=noone;var _nd=100000;
for(var _i=0;_i<2;_i++) {
    var _p=instance_find((_i==0?obj_player_p1:obj_player_p2),0);
    if(_p==noone || !_p.active_player || _p.dead) continue;
    var _d=point_distance(x,y-40,_p.x,_p.y-35);
    if(_d<_nd){_nd=_d;_near=_p;}
}
var _was_excited=excited;
excited=(_near!=noone && _nd<260);
if(excited && !_was_excited) scr_sfx(sfx_god_chime,0,0.8);
if(excited) {
    // Turns to greet the player and stops pacing.
    face=(_near.x>=x?1:-1);
} else {
    x+=dir*0.55;
    if(x>home_x+patrol_range){x=home_x+patrol_range;dir=-1;}
    if(x<home_x-patrol_range){x=home_x-patrol_range;dir=1;}
    face=dir;
}
// Contact with any active player ends the game (peaceful: nothing here hurts anyone).
if(!reached && _near!=noone && abs(_near.x-x)<34 && _near.y>y-100 && _near.y-70<y+4) {
    reached=true;reached_t=0;
}
if(reached) reached_t++;
