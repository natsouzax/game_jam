if(global.game_state!="play")exit;
phase+=0.03;
// slow horizontal movement
x+=dir*move_speed;
if(x<60 || x>room_width-60) dir=-dir;
x=clamp(x,60,room_width-60);
y=home_y+sin(phase)*8;
// spawn foguinhos
if(spawn_count<max_spawns) {
    spawn_timer--;
    if(spawn_timer<=0) {
        var _fg=instance_create_layer(x,y,"Instances_1",obj_enemy_flying);
        _fg.start_x=x;_fg.start_y=y;_fg.base_y=y+100;
        spawn_count++;
        spawn_timer=irandom_range(180,300);
    }
}
// cleanup if far below camera
var _cam_top=camera_get_view_y(view_camera[0]);
if(y>_cam_top+900) {instance_destroy();exit;}
// collision with players (stomp)
for(var _i=0;_i<2;_i++) {
    var _p=instance_find((_i==0?obj_player_p1:obj_player_p2),0);
    if(_p==noone || !_p.active_player || _p.dead || _p.invulnerable>0) continue;
    if(point_distance(x,y,_p.x,_p.y-35)<28) {
        if(_p.vy>=0 && (_p.y-35)<y && abs(_p.x-x)<22) {
            hp--;_p.vy=_p.jump_speed;_p.invulnerable=10;scr_sfx(sfx_hit,0.04);
            if(hp<=0) instance_destroy();
        } else {
            with(_p){enemy_hits++;scr_player_die();}
        }
    }
}