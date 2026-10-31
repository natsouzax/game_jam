if(global.game_state!="play")exit;
phase+=0.035;x=672+sin(phase)*240;y=home_y+sin(phase*2)*16;
for(var _i=0;_i<2;_i++) {
    var _p=instance_find((_i==0?obj_player_p1:obj_player_p2),0);
    if(_p!=noone && _p.active_player && _p.invulnerable<=0 && point_distance(x,y,_p.x,_p.y-35)<38)with(_p){enemy_hits++;scr_player_recover();}
}
