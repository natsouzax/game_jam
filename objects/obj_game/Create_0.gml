global.qa_skip_ending=false;
if (!variable_global_exists("game_state")) global.game_state="title";
if (!variable_global_exists("game_timer")) global.game_timer=0;
if (!variable_global_exists("menu_mode")) { global.menu_mode=1; global.menu_stage=0; global.solo_character=0; global.player_count=2; }
if (!variable_global_exists("intro_seen")) global.intro_seen=[false,false,false];
if (!variable_global_exists("qa_menu_ok")) global.qa_menu_ok=false;
if (!variable_global_exists("qa_section_test")) global.qa_section_test=false;
if (!variable_global_exists("qa_recovery_test")) global.qa_recovery_test=false;
if (!variable_global_exists("simultaneous_frames")) global.simultaneous_frames=0;
if (!variable_global_exists("qa")) global.qa=false;
if (!variable_global_exists("qa_frame")) global.qa_frame=0;
if (!variable_global_exists("qa_stage")) global.qa_stage=0;
if (!variable_global_exists("qa_ending_seen")) global.qa_ending_seen=false;
if (!variable_global_exists("qa_solo")) global.qa_solo=-1;
for(var _a=1;_a<=parameter_count();_a++) {
    var _arg=parameter_string(_a);
    if(_arg=="--qa-section-reset"){global.qa=true;global.qa_section_test=true;}
    if(_arg=="--qa-skip-ending"){global.qa=true;global.qa_skip_ending=true;}
    if(_arg=="--qa")global.qa=true;
    if(_arg=="--qa-recovery"){global.qa=true;global.qa_recovery_test=true;}
    if(_arg=="--qa-solo1"){global.qa=true;global.qa_solo=0;}
    if(_arg=="--qa-solo2"){global.qa=true;global.qa_solo=1;}
}
game_set_speed(global.qa ? 300 : 60, gamespeed_fps);
if(global.qa)display_reset(0,false);
random_set_seed(global.qa ? 7231 : current_time);
scr_audio_init();
scr_screen_music(global.game_state);
spawn_timer=120;spawn_side=0;ending_timer=0;camera_y=room_height-768;bg_y=camera_y;altitude=0;depth=400;
if (!variable_global_exists("gameover_choice")) global.gameover_choice=0;
global.gameover_timer=0;
life_spawn_timer=irandom_range(300,600);
global.death_window_timer=0;
global.restart_game=false;
// tower platforms with gap
var _floor=scr_floor_y();
var _ls=instance_create_layer(0,_floor,"Instances_1",obj_world_solid);
_ls.solid_width=540;_ls.solid_height=128;
var _rs=instance_create_layer(826,_floor,"Instances_1",obj_world_solid);
_rs.solid_width=540;_rs.solid_height=128;
var _room_name=room_get_name(room);
if (_room_name=="Room1") {
    var _e1=instance_create_layer(720, scr_floor_y()-40, "Instances_1", obj_enemy);
    _e1.home_y = _e1.y;
    var _e2=instance_create_layer(1040, scr_floor_y()-200, "Instances_1", obj_enemy_flying);
    _e2.home_y = _e2.y;
}
display_set_gui_size(1366,768);gpu_set_texfilter(false);
view_enabled=true;view_visible[0]=true;cam=view_camera[0];camera_set_view_size(cam,1366,768);camera_set_view_pos(cam,0,camera_y);
// QA-only one-way traversal scaffolding. A normal game never creates these.
if(global.qa && !global.qa_section_test) {
    for(var _qi=1;_qi<=5;_qi++) {
        var _qb=instance_create_layer(512,scr_floor_y()-_qi*192,"Instances_1",obj_build_block);
        _qb.solid_width=320;_qb.solid_height=20;_qb.is_checkpoint=true;_qb.level_id=0;
    }
}
window_set_caption("JUNTOS");
