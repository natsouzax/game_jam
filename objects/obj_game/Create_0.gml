global.qa_regression=false;
global.boot_test=false;
global.qa_block_test=false;
global.qa_revive_test=false;
global.qa_spawn_test=false;
global.qa_save_test=false;
qa_regression_stage=0;qa_regression_hold=0;
global.qa_skip_ending=false;
if (!variable_global_exists("game_state")) global.game_state="title";
if (!variable_global_exists("boot_seen")) {
    global.boot_seen=true;
    global.game_state="studio";
    global.game_timer=0;
}
global.boot_video_started=false;
global.boot_video_was_playing=false;
global.boot_video_error=false;
if (!variable_global_exists("game_timer")) global.game_timer=0;
if (!variable_global_exists("menu_mode")) { global.menu_mode=1; global.menu_stage=0; global.solo_character=0; global.player_count=2; global.title_choice=0; }
if (!variable_global_exists("title_choice")) global.title_choice=0;
if (!variable_global_exists("settings_index")) global.settings_index=0;
if (!variable_global_exists("gp_prev_l")) {
    global.gp_prev_l=false; global.gp_prev_r=false;
    global.gp_prev_u=false; global.gp_prev_d=false;
    global.gp_prev_c=false; global.gp_prev_b=false;
    global.gp_prev_confirm_any=false;
    global.gp_prev_pu=false; global.gp_prev_pd=false; global.gp_prev_pc=false;
    global.gp_btn_last=-1;
}
if (!variable_global_exists("dbg_mv")) {
    global.dbg_mv=0; global.dbg_jp=false; global.dbg_jh=false; global.dbg_bl=false; global.dbg_gp=-1;
}
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
    if(_arg=="--qa-regression"){global.qa=true;global.qa_regression=true;}
    if(_arg=="--qa")global.qa=true;
    if(_arg=="--qa-recovery"){global.qa=true;global.qa_recovery_test=true;}
    if(_arg=="--qa-solo1"){global.qa=true;global.qa_solo=0;}
    if(_arg=="--qa-solo2"){global.qa=true;global.qa_solo=1;}
    if(_arg=="--qa-block-test"){global.qa=true;global.qa_block_test=true;}
    if(_arg=="--qa-revive-test"){global.qa=true;global.qa_revive_test=true;}
    if(_arg=="--qa-spawn-test"){global.qa=true;global.qa_spawn_test=true;}
    if(_arg=="--qa-save-test"){global.qa=true;global.qa_save_test=true;}
    if(_arg=="--boot-test")global.boot_test=true;
}
game_set_speed(global.qa ? 300 : 60, gamespeed_fps);
if(global.qa && (global.game_state=="studio" || global.game_state=="video")) global.game_state="title";
if(global.qa)display_reset(0,false);
random_set_seed(global.qa ? 7231 : current_time);
scr_audio_init();
scr_settings_load();
if(global.game_state=="studio" || global.game_state=="video")scr_music_stop();
else scr_screen_music(global.game_state);
spawn_timer=30;spawn_side=0;ending_timer=0;camera_y=room_height-768;bg_y=camera_y;altitude=0;depth=400;
enemy_spawn_timer=360;enemy_respawn_queue=[];
if (!variable_global_exists("gameover_choice")) global.gameover_choice=0;
if (!variable_global_exists("audio_muted")) global.audio_muted=false;
global.gameover_timer=0;
global.pause_index=0;global.pause_stage=0;global.pause_timer=0;global.pause_guard=0;
life_spawn_timer=irandom_range(300,600);
hazard_timer=150;
global.death_window_timer=0;
global.restart_game=false;
global.auto_save_timer=3600;
global.last_save_altitude=0;
if (!variable_global_exists("level_saved")) global.level_saved=[false,false,false,false];
if (!variable_global_exists("esc_hold")) global.esc_hold=0;
// tower platforms with gap
var _floor=scr_floor_y();
var _ls=instance_create_layer(0,_floor,"Instances_1",obj_world_solid);
_ls.solid_width=540;_ls.solid_height=128;
var _rs=instance_create_layer(826,_floor,"Instances_1",obj_world_solid);
_rs.solid_width=540;_rs.solid_height=128;
var _room_name=room_get_name(room);
// A small checkpoint base at each visual altitude band gives the climb a place to regroup.
if(_room_name=="Room1") {
    var _climb_span=max(1,_floor-220);
    for(var _stage=1;_stage<=3;_stage++) {
        var _base_y=round(_floor-_climb_span*(_stage*0.25));
        var _base_x=(_stage mod 2==1?190:896);
        var _base=instance_create_layer(_base_x,_base_y,"Instances_1",obj_build_block);
        _base.solid_width=280;_base.solid_height=20;_base.is_checkpoint=true;_base.level_id=_stage;
    }
} else if(_room_name=="Room2") {
    var _final_base=instance_create_layer(543,round(_floor-(_floor-220)*0.5),"Instances_1",obj_build_block);
    _final_base.solid_width=280;_final_base.solid_height=20;_final_base.is_checkpoint=true;_final_base.level_id=4;
}
// Enemies are spawned dynamically based on altitude (see Step_0).
// Only the demon appears in Room2.
if (_room_name=="Room2") {
    var _demon=instance_create_layer(683, 640, "Instances_1", obj_demon);
    if(!global.qa) scr_enemy_apply_difficulty(_demon,0.72);
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
window_set_caption("TOGETHER");
