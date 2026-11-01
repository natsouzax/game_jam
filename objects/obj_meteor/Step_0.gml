if(global.game_state!="play")exit;
age++;
y+=fall_speed;
x=clamp(x+drift+sin((global.game_timer+phase_offset)/14)*0.35,20,room_width-20);
var _cam_top=camera_get_view_y(view_camera[0]);
for(var _i=0;_i<2;_i++) {
    var _p=instance_find((_i==0?obj_player_p1:obj_player_p2),0);
    if(_p==noone || !_p.active_player || _p.dead || _p.invulnerable>0)continue;
    if(abs(_p.x-x)<radius+14 && _p.y>y-radius && _p.y-_p.body_height<y+radius) {
        if(_p.vy>=0 && (_p.y-35)<y && abs(_p.x-x)<radius+16) {
            _p.vy=_p.jump_speed;
            _p.invulnerable=10;
            scr_sfx(sfx_hit,0.04);
            instance_destroy();
            exit;
        }
        _p.enemy_hits++;
        scr_sfx(sfx_hit,0.05);
        with(_p)scr_player_die();
        instance_destroy();
        exit;
    }
}
if(y>_cam_top+820) { instance_destroy(); exit; }
if(scr_world_aabb_solid(x-radius,y-radius,x+radius,y+radius)) { instance_destroy(); exit; }