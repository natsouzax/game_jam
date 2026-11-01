if(global.game_state!="play")exit;
age++;
y+=fall_speed;
var _wind=drift+sin((age+x+y)*0.071)*0.35;
var _next_x=clamp(x+_wind,20,room_width-20);
x=_next_x;
for(var _i=0;_i<2;_i++) {
    var _p=instance_find((_i==0?obj_player_p1:obj_player_p2),0);
    if(_p==noone || !_p.active_player || _p.dead || _p.invulnerable>0)continue;
    if(abs(_p.x-x)<radius+14 && _p.y>y-radius && _p.y-_p.body_height<y+radius) {
        _p.enemy_hits++;
        scr_sfx(sfx_hit,0.05);
        with(_p)scr_player_die();
        instance_destroy();
        exit;
    }
}
var _cam_y=camera_get_view_y(view_camera[0]);
var _cam_h=camera_get_view_height(view_camera[0]);
if(y>_cam_y+_cam_h+52) { instance_destroy(); exit; }
for(var _bi=0;_bi<instance_number(obj_build_block);_bi++) {
    var _hit_block=instance_find(obj_build_block,_bi);
    if(_hit_block!=noone && !_hit_block.is_checkpoint && _hit_block.builder_number>=0
       && x+radius>_hit_block.x && x-radius<_hit_block.x+_hit_block.solid_width
       && y+radius>_hit_block.y && y-radius<_hit_block.y+_hit_block.solid_height) {
        instance_destroy(_hit_block);
        instance_destroy();exit;
    }
}
if(scr_world_aabb_solid(x-radius,y-radius,x+radius,y+radius)) { instance_destroy(); exit; }
