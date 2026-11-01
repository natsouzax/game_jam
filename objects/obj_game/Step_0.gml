if(global.game_state!="pause")global.game_timer++;
var _p1=instance_find(obj_player_p1,0);var _p2=instance_find(obj_player_p2,0);
if(_p1==noone || _p2==noone)exit;
if(global.pause_guard>0)global.pause_guard--;
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
if(global.game_state=="pause") {
    global.pause_timer++;
    scr_pause_input();
    exit;
}
if(global.game_state=="play" && (keyboard_check_pressed(vk_escape)||keyboard_check_pressed(ord("P")))) {
    scr_begin_pause();
    exit;
}
if(!global.qa && keyboard_check_pressed(ord("M")))scr_audio_mute_toggle();
if(!global.qa && keyboard_check_pressed(vk_f11)){window_set_fullscreen(!window_get_fullscreen());scr_settings_save();}
if(!global.qa) {
    if(keyboard_check(vk_escape)) {
        global.esc_hold++;
        if(global.esc_hold>=180) game_end();
    } else global.esc_hold=0;
}
if(global.boot_test && global.game_state=="title" && global.game_timer==45) {
    var _boot_report=file_text_open_write("boot_test_result.json");
    file_text_write_string(_boot_report,json_stringify({video_started:global.boot_video_started,video_played:global.boot_video_was_playing,video_error:global.boot_video_error,menu_reached:true}));
    file_text_close(_boot_report);game_end();exit;
}
if(global.game_state=="studio") {
    if(global.game_timer>=150 || keyboard_check_pressed(ord("E")) || keyboard_check_pressed(vk_enter)) {
        global.game_state="video";global.game_timer=0;
        video_open("intro_story.mp4");
        global.boot_video_started=true;
    }
} else if(global.game_state=="video") {
    var _skip=keyboard_check_pressed(ord("E")) || keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_escape);
    var _video_status=video_get_status();
    if(_video_status==video_status_playing)global.boot_video_was_playing=true;
    if(_skip || global.boot_video_error || global.game_timer>1200
       || (global.boot_video_was_playing && _video_status==video_status_closed)
       || (!global.boot_video_was_playing && global.game_timer>180 && _video_status==video_status_closed)) {
        video_close();global.game_state="title";global.game_timer=0;
        scr_screen_music("title");
    }
} else if(global.game_state=="title") {
    if(global.qa)scr_qa_menu();
    else {
        var _direction = (keyboard_check_pressed(ord("D")) || keyboard_check_pressed(vk_right))
            - (keyboard_check_pressed(ord("A")) || keyboard_check_pressed(vk_left));
        var _confirm=keyboard_check_pressed(ord("E"))||keyboard_check_pressed(vk_enter);
        var _back=keyboard_check_pressed(ord("S"))||keyboard_check_pressed(vk_down);
        var _vertical = (keyboard_check_pressed(ord("W")) || keyboard_check_pressed(vk_up))
            - (keyboard_check_pressed(ord("S")) || keyboard_check_pressed(vk_down));
        var _escape=keyboard_check_pressed(vk_escape);
        var _gp_menu=scr_gamepad_menu_input();
        if(_gp_menu[0]!=0)_direction=_gp_menu[0];
        if(array_length(_gp_menu)>3 && _gp_menu[3]!=0)_vertical=_gp_menu[3];
        _confirm=_confirm||_gp_menu[1];
        _back=_back||_gp_menu[2];
        scr_menu_input(_direction,_confirm,_back,_vertical,_escape);
    }
} else if(global.game_state=="intro") {
    global.intro_seen[min(2,global.game_timer div 240)]=true;
    scr_intro_audio();
    if(global.game_timer>=720 || (!global.qa && global.game_timer>60 && (keyboard_check_pressed(ord("E"))||keyboard_check_pressed(vk_enter)||scr_gamepad_confirm_pressed()))) {
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
    // auto-save every 1 minute (3600 frames) and once per difficulty level reached per run
    global.auto_save_timer--;
    var _save_now=false;
    if(global.auto_save_timer<=0){_save_now=true;global.auto_save_timer=3600;}
    var _cur_level=(altitude>=0.75?3:(altitude>=0.5?2:(altitude>=0.25?1:0)));
    if(_cur_level>0 && !global.level_saved[_cur_level]) {
        global.level_saved[_cur_level]=true;
        _save_now=true;
    }
    if(_save_now && !global.qa) scr_save_game(_p1,_p2);
    // height-based enemy spawning
    if(!global.qa) {
        var _alt=altitude;
        // count entities on camera
        var _ent_count=instance_number(obj_slime)+instance_number(obj_skeleton)+instance_number(obj_devil)+instance_number(obj_enemy_flying)+instance_number(obj_meteor_enemy);
        var _cam_top=camera_y; var _cam_bot=camera_y+768;
        // Level 1 (altitude 0-0.25): slime only
        if(_alt<0.25 && _ent_count<3) {
            if(irandom(200)==0) instance_create_layer(irandom_range(100,room_width-100),scr_floor_y()-200,"Instances_1",obj_slime);
        }
        // Level 2 (0.25-0.5): slime + skeleton
        if(_alt>=0.25 && _alt<0.5 && _ent_count<4) {
            if(irandom(220)==0) instance_create_layer(irandom_range(100,room_width-100),scr_floor_y()-300,"Instances_1",obj_slime);
            if(irandom(300)==0) instance_create_layer(irandom_range(100,room_width-100),scr_floor_y()-400,"Instances_1",obj_skeleton);
        }
        // Level 3 (0.5-0.75): no slime, meteors + skeletons
        if(_alt>=0.5 && _alt<0.75 && _ent_count<4) {
            if(irandom(250)==0) instance_create_layer(irandom_range(100,room_width-100),camera_y-60,"Instances_1",obj_meteor_enemy);
            if(irandom(300)==0) instance_create_layer(irandom_range(100,room_width-100),scr_floor_y()-500,"Instances_1",obj_skeleton);
        }
        // Level 4 (0.75+): devils, skeletons, meteors. Max 5 entities.
        if(_alt>=0.75 && _ent_count<5) {
            if(irandom(200)==0) instance_create_layer(irandom_range(100,room_width-100),camera_y-60,"Instances_1",obj_meteor_enemy);
            if(irandom(280)==0) instance_create_layer(irandom_range(100,room_width-100),scr_floor_y()-500,"Instances_1",obj_skeleton);
            if(irandom(320)==0) instance_create_layer(irandom_range(100,room_width-100),camera_y-100,"Instances_1",obj_devil);
        }
        // Cleanup entities far below camera
        with(obj_slime) { if(y > other.camera_y + 900) instance_destroy(); }
        with(obj_skeleton) { if(y > other.camera_y + 900) instance_destroy(); }
        with(obj_devil) { if(y > other.camera_y + 900) instance_destroy(); }
        with(obj_enemy_flying) { if(y > other.camera_y + 900) instance_destroy(); }
        with(obj_meteor_enemy) { if(y > other.camera_y + 900) instance_destroy(); }
    }
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
        // Two uniform picks averaged: covers the whole map with a natural centre bias.
        var _drop_x=(irandom_range(64,room_width-64)+irandom_range(64,room_width-64))/2;
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
    // falling hazards ramp up with the climb height
    if(!global.qa) {
        var _hazard_level=clamp((altitude-0.32)/0.68,0,1);
        if(altitude>0.32) {
            hazard_timer--;
            if(hazard_timer<=0) {
                var _kind=(altitude>0.72 && random(1)<0.55)?1:0;
                var _target=instance_find((irandom(1)==0?obj_player_p1:obj_player_p2),0);
                var _sx=irandom_range(80,room_width-80);
                if(_target!=noone && _target.active_player && !_target.dead)
                    _sx=clamp(_target.x+irandom_range(-170,170),80,room_width-80);
                var _h=instance_create_layer(_sx,camera_y-70,"Instances_1",obj_meteor);
                _h.kind=_kind;
                if(_kind==0) {
                    _h.radius=13;_h.fall_speed=3.2+_hazard_level*2.2;_h.drift=random_range(-0.45,0.45);
                } else {
                    _h.radius=20;_h.fall_speed=5.2+_hazard_level*2.6;_h.drift=random_range(-0.75,0.75);
                }
                hazard_timer=round(lerp(280,120,_hazard_level))+irandom_range(-30,30);
            }
        } else hazard_timer=150;
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
    if(ending_timer>=4780 && (keyboard_check_pressed(ord("W"))||keyboard_check_pressed(vk_up)||scr_gamepad_confirm_pressed()||global.qa)) {
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
