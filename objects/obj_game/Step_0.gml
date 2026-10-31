global.game_timer++;
var _p1=instance_find(obj_player_p1,0);var _p2=instance_find(obj_player_p2,0);
if(_p1==noone || _p2==noone)exit;
if(variable_global_exists("retry_pending") && global.retry_pending) {
    global.retry_pending=false;
    _p1.active_player=global.player_count==2 || global.solo_character==0;
    _p2.active_player=global.player_count==2 || global.solo_character==1;
}
if(global.qa_regression){scr_qa_regression(_p1,_p2);exit;}
if(global.restart_game){scr_return_to_title();exit;}
if(global.qa_section_test) {
    var _section_report=scr_qa_section_reset_test(_p1,_p2);
    var _section_file=file_text_open_write("qa_section_reset_result.json");
    file_text_write_string(_section_file,json_stringify(_section_report));file_text_close(_section_file);
    game_end();exit;
}
if(global.qa && variable_global_exists("qa_restart_pending") && global.qa_restart_pending) {
    var _restart_ok=global.game_state=="title" && global.menu_stage==0 && global.menu_mode==1
        && _p1.material_count==0 && _p2.material_count==0 && instance_number(obj_build_block)==5;
    global.qa_result.restarted=_restart_ok;global.qa_result.passed=global.qa_result.passed && _restart_ok;
    var _report=file_text_open_write(scr_qa_report_name());file_text_write_string(_report,json_stringify(global.qa_result));file_text_close(_report);game_end();exit;
}
if(!global.qa && keyboard_check_pressed(ord("M")))scr_audio_mute_toggle();
if(global.game_state=="title") {
    if(global.qa)scr_qa_menu();
    else {
        var _direction=(keyboard_check_pressed(ord("D"))||keyboard_check_pressed(vk_right))
            -(keyboard_check_pressed(ord("A"))||keyboard_check_pressed(vk_left));
        var _confirm=keyboard_check_pressed(ord("E"))||keyboard_check_pressed(vk_enter);
        var _back=keyboard_check_pressed(ord("S"))||keyboard_check_pressed(vk_down);
        var _vertical=(keyboard_check_pressed(ord("W"))||keyboard_check_pressed(vk_up))
            -(keyboard_check_pressed(ord("S"))||keyboard_check_pressed(vk_down));
        scr_menu_input(_direction,_confirm,_back,_vertical);
    }
} else if(global.game_state=="intro") {
    global.intro_seen[min(2,global.game_timer div 240)]=true;
    scr_intro_audio();
    if(global.game_timer>=720 || (!global.qa && global.game_timer>60 && (keyboard_check_pressed(ord("E"))||keyboard_check_pressed(vk_enter)))) {
        global.game_state="play";global.game_timer=0;
        scr_screen_music("play");
    }
} else if(global.game_state=="play") {
    var _sum_y=0;var _count=0;
    for(var _i=0;_i<2;_i++) {
        var _p=(_i==0?_p1:_p2);
        if(!_p.active_player || _p.dead)continue;
        _sum_y+=_p.y;_count++;
    }
    var _mean_y=(_count>0?_sum_y/_count:camera_y+384);
    camera_y=lerp(camera_y,clamp(_mean_y-384,0,room_height-768),0.09);camera_set_view_pos(cam,0,camera_y);
    // respawn management
    for(var _di=0;_di<2;_di++) {
        var _dp=(_di==0?_p1:_p2);
        if(_dp.dead) {
            _dp.respawn_timer--;
            if(_dp.respawn_timer<=0) {
                _dp.dead=false;_dp.active_player=true;_dp.player_lives=2;
                with(_dp) scr_player_recover();
            }
        }
    }
    if(global.death_window_timer>0) global.death_window_timer--;
    // resource spawn
    spawn_timer--;
    if(instance_number(obj_material)<4 && spawn_timer<=0) {
        var _drop_x=room_width/2+irandom_range(-160,160);
        var _drop_y=camera_y+16;
        for(var _si=0;_si<instance_number(obj_world_solid);_si++) {
            var _roof=instance_find(obj_world_solid,_si);
            if(_drop_x+18>_roof.x && _drop_x-18<_roof.x+_roof.solid_width
                && _drop_y+18>_roof.y && _drop_y-18<_roof.y+_roof.solid_height)
                _drop_y=_roof.y+_roof.solid_height+20;
        }
        instance_create_layer(_drop_x,_drop_y,"Instances_1",obj_material);
        spawn_timer=120;
    }
    // life item spawn
    life_spawn_timer--;
    if(life_spawn_timer<=0) {
        life_spawn_timer=irandom_range(600,1200);
        if(instance_number(obj_life_item)<2) {
            var _lx=irandom_range(64,room_width-64);
            var _ly=camera_y+16;
            for(var _si2=0;_si2<instance_number(obj_world_solid);_si2++) {
                var _roof2=instance_find(obj_world_solid,_si2);
                if(_lx+14>_roof2.x && _lx-14<_roof2.x+_roof2.solid_width
                    && _ly+14>_roof2.y && _ly-14<_roof2.y+_roof2.solid_height)
                    _ly=_roof2.y+_roof2.solid_height+20;
            }
            instance_create_layer(_lx,_ly,"Instances_1",obj_life_item);
        }
    }
    // finish line
    var _finish_y=220;
    var _all_finished=true;var _any_active=false;
    for(var _fi=0;_fi<2;_fi++) {
        var _fp=(_fi==0?_p1:_p2);
        if(!_fp.active_player || _fp.dead) continue;
        _any_active=true;
        if(_fp.y >= _finish_y) _all_finished=false;
    }
    if(_any_active && _all_finished) {
        if(room_next(room)!=-1) { room_goto_next(); exit; }
        else { global.game_state="ending"; ending_timer=0; global.game_timer=0; scr_screen_music("ending"); scr_sfx(sfx_victory,0,0.9); }
    }
} else if(global.game_state=="ending") {
    ending_timer++;
    scr_cut_voice(ending_timer);
    if(ending_timer>30 && ending_timer<4600 &&
       ((global.qa_skip_ending && ending_timer==100) || (!global.qa && (keyboard_check_pressed(ord("E"))||keyboard_check_pressed(vk_enter))))) {
        ending_timer=4600;scr_cut_voice_stop();
    }
    if(ending_timer>=4780 && (keyboard_check_pressed(ord("W"))||keyboard_check_pressed(vk_up)||global.qa)) {
        if(global.qa) {global.qa_result=scr_qa_summary(_p1,_p2);global.qa_restart_pending=true;}
        scr_return_to_title();exit;
    }
} else if(global.game_state=="gameover") {
    global.gameover_timer++;
    if(!global.qa) scr_gameover_input(global.gameover_timer);
}
if(global.qa) {
    global.qa_frame++;
    if(_p1.active_player && _p2.active_player && _p1.last_move!=0 && _p2.last_move!=0)global.simultaneous_frames++;
    if(global.qa_frame mod 300==0) {
        var _q=file_text_open_write("qa_progress.json");
        file_text_write_string(_q,json_stringify({frames:global.qa_frame,state:global.game_state,p1x:_p1.x,p1y:_p1.y,p2x:_p2.x,p2y:_p2.y,p1stock:_p1.material_count,p2stock:_p2.material_count,p1falls:_p1.fall_hits,p2enemy:_p2.enemy_hits,p1built:_p1.built_total,p2built:_p2.built_total}));file_text_close(_q);
    }
    if(global.qa_frame>24000) {
        var _failed=scr_qa_summary(_p1,_p2);_failed.passed=false;_failed.ending=false;
        var _f=file_text_open_write(scr_qa_report_name());file_text_write_string(_f,json_stringify(_failed));file_text_close(_f);game_end();
    }
}
