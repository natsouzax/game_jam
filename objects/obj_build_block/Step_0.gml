// Player-built blocks dropped in mid-air fall until they meet the nearest base, then snap onto it.
if(!falling) exit;
if(global.game_state!="play") exit;
fall_vy=min(fall_vy+0.7,14);
var _ny=y+fall_vy;
// While falling the block is intangible (solid size 0), so it cannot crush or trap anyone.
var _land=scr_world_landing_surface(x+2,x+62,y+64,_ny+64);
if(_land!=noone) {
    var _ty=_land-64;
    y=_ty;
    // Wait on the base while a player stands in the cell, so nobody ends up inside the block.
    var _blocked=false;
    for(var _i=0;_i<2;_i++) {
        var _p=instance_find((_i==0?obj_player_p1:obj_player_p2),0);
        if(_p!=noone && _p.active_player && !_p.dead && _p.x+16>x && _p.x-16<x+64 && _p.y>y && _p.y-70<y+64) _blocked=true;
    }
    if(_blocked) {fall_vy=0;exit;}
    falling=false;fall_vy=0;
    solid_width=64;solid_height=64;
    section_id=scr_tower_section_at_y(y);
    scr_sfx(sfx_block,0.05,0.8);
} else {
    y=_ny;
    if(y>room_height+200) instance_destroy();
}
