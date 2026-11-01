if(global.game_state!="play")exit;
life--;
if(life<=0){instance_destroy();exit;}
x+=vx;y+=vy;
// collision with players
for(var _i=0;_i<2;_i++) {
    var _p=instance_find((_i==0?obj_player_p1:obj_player_p2),0);
    if(_p==noone || !_p.active_player || _p.dead || _p.invulnerable>0) continue;
    if(point_distance(x,y,_p.x,_p.y-35)<14) {
        with(_p){enemy_hits++;scr_player_die();}
        instance_destroy();exit;
    }
}
// out of room
if(x<0 || x>room_width || y<0 || y>room_height) instance_destroy();