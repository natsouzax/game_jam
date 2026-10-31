global.game_state="title";
global.game_timer=0;
global.menu_mode=1;global.menu_stage=0;global.solo_character=0;global.player_count=2;
global.intro_seen=[false,false,false];global.qa_menu_ok=false;
global.qa_section_test=false;global.qa_recovery_test=false;global.simultaneous_frames=0;
global.qa=false;global.qa_frame=0;global.qa_stage=0;global.qa_ending_seen=false;global.qa_solo=-1;
for(var _a=1;_a<=parameter_count();_a++) {
    var _arg=parameter_string(_a);
    if(_arg=="--qa-section-reset"){global.qa=true;global.qa_section_test=true;}
    if(_arg=="--qa")global.qa=true;
    if(_arg=="--qa-recovery"){global.qa=true;global.qa_recovery_test=true;}
    if(_arg=="--qa-solo1"){global.qa=true;global.qa_solo=0;}
    if(_arg=="--qa-solo2"){global.qa=true;global.qa_solo=1;}
}
game_set_speed(global.qa ? 300 : 60, gamespeed_fps);
if(global.qa)display_reset(0,false);
random_set_seed(global.qa ? 7231 : current_time);
spawn_timer=30;spawn_side=0;ending_timer=0;camera_y=room_height-768;depth=400;
display_set_gui_size(1366,768);gpu_set_texfilter(false);
view_enabled=true;view_visible[0]=true;cam=view_camera[0];camera_set_view_size(cam,1366,768);camera_set_view_pos(cam,0,camera_y);
for(var _i=1;_i<=5;_i++) {
    var _b=instance_create_layer(512,1408-_i*192,"Instances_1",obj_build_block);
    _b.solid_width=320;_b.solid_height=20;_b.is_checkpoint=true;_b.level_id=_i;
}
var _e=instance_create_layer(680,940,"Instances_1",obj_enemy);
_e.home_y=940;

window_set_caption("JUNTOS");
