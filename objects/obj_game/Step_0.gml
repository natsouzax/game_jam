global.game_timer++;
var _p1=instance_find(obj_player_p1,0);var _p2=instance_find(obj_player_p2,0);
if(_p1==noone || _p2==noone)exit;
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
        scr_music(mus_game);
    }
} else if(global.game_state=="play") {
    var _sum_y=0;var _active_count=0;var _at_top=true;
    for(var _i=0;_i<2;_i++) {
        var _p=(_i==0?_p1:_p2);
        if(!_p.active_player)continue;
        _sum_y+=_p.y;_active_count++;
        _at_top=_at_top && _p.grounded && abs(_p.y-448)<2 && _p.x>500 && _p.x<844;
    }
    // Resources become scarcer as the pair climbs; the delay grows with height.
    var _average_y=(_active_count>0 ? _sum_y/_active_count : 1408);
    var _climb=clamp((1408-_average_y)/960,0,1);
    var _spawn_delay=round(34+86*_climb*_climb);
    spawn_timer--;
    if(instance_number(obj_material)==0 && spawn_timer<=0) {
        var _receiver=(global.player_count==1?(global.solo_character==0?_p1:_p2):(spawn_side mod 2==0?_p1:_p2));spawn_side++;
        // Materials only rain over the tower, whatever side the players climb.
        var _drop_x=clamp(672+irandom_range(-140,140),512,832);
        var _drop_y=max(20,_receiver.y-180);
        for(var _si=0;_si<instance_number(obj_world_solid);_si++) {
            var _roof=instance_find(obj_world_solid,_si);
            if(_drop_x+18>_roof.x && _drop_x-18<_roof.x+_roof.solid_width && _roof.y<_receiver.y-40 && _roof.y+_roof.solid_height>_drop_y)
                _drop_y=max(_drop_y,_roof.y+_roof.solid_height+20);
        }
        _drop_y=min(_drop_y,_receiver.y-45);
        instance_create_layer(_drop_x,_drop_y,"Instances_1",obj_material);
        spawn_timer=_spawn_delay;
    }
    // Allow brief separation during jumps, but require the pair to reunite.
    if(_active_count==2 && abs(_p1.y-_p2.y)>600) separation_timer++;
    else separation_timer=max(0,separation_timer-2);
    if(separation_timer>=180) {
        global.coop_restart=true;
        room_restart();exit;
    }
    if(_active_count>0) camera_y=lerp(camera_y,clamp(_sum_y/_active_count-384,0,room_height-768),0.09);
    camera_set_view_pos(cam,0,camera_y);
    if(_at_top) {global.game_state="ending";ending_timer=0;global.game_timer=0;audio_stop_all();}
} else if(global.game_state=="ending") {
    ending_timer++;
    scr_cut_voice(ending_timer);
    var _skip_cutscene=(global.qa_skip_ending && ending_timer==100) ||
        (!global.qa && (keyboard_check_pressed(ord("E"))||keyboard_check_pressed(vk_enter)));
    if(ending_timer>30 && ending_timer<4600 && _skip_cutscene){ending_timer=4600;scr_cut_voice_stop();}
    if(ending_timer>=4780 && (global.qa || keyboard_check_pressed(ord("W")) || keyboard_check_pressed(vk_up))) {
        if(global.qa) {global.qa_result=scr_qa_summary(_p1,_p2);global.qa_restart_pending=true;}
        if(variable_global_exists("cutscene_surface") && surface_exists(global.cutscene_surface))surface_free(global.cutscene_surface);
        room_restart();exit;
    }
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
