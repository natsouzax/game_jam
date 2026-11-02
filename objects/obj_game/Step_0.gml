if(global.game_state!="pause")global.game_timer++;
var _p1=instance_find(obj_player_p1,0);var _p2=instance_find(obj_player_p2,0);
if(_p1==noone || _p2==noone)exit;
if(global.pause_guard>0)global.pause_guard--;
if(variable_global_exists("retry_pending") && global.retry_pending) {
    global.retry_pending=false;
    _p1.active_player=global.player_count==2 || global.solo_character==0;
    _p2.active_player=global.player_count==2 || global.solo_character==1;
}
if(global.qa_block_test){scr_qa_block_interaction(_p1,_p2);exit;}
if(global.qa_revive_test){scr_qa_revive(_p1,_p2);exit;}
if(global.qa_spawn_test){scr_qa_spawn(_p1,_p2);exit;}
if(global.qa_save_test){scr_qa_save(_p1,_p2);exit;}
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
if(global.game_state=="play" && (keyboard_check_pressed(vk_escape)||keyboard_check_pressed(ord("P"))
   || scr_gamepad_pause_pressed())) {
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
    if(global.game_timer>=150 || keyboard_check_pressed(ord("E")) || keyboard_check_pressed(vk_enter) || scr_gamepad_skip_pressed()) {
        global.game_state="video";global.game_timer=0;
        video_open("intro_story.mp4");
        global.boot_video_started=true;
    }
} else if(global.game_state=="video") {
    var _skip=keyboard_check_pressed(ord("E")) || keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_escape) || scr_gamepad_skip_pressed();
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
    if(global.game_timer>=720 || (!global.qa && global.game_timer>60 && (keyboard_check_pressed(ord("E"))||keyboard_check_pressed(vk_enter)||scr_gamepad_skip_pressed()))) {
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
    // Tower tier = highest platform (checkpoint) reached by an active player. Each tier adds +10% resource spawn rate and +15% enemy spawn rate.
    var _tier=0;
    if(!global.qa) {
        if(_p1.active_player) _tier=max(_tier,_p1.checkpoint_level);
        if(_p2.active_player) _tier=max(_tier,_p2.checkpoint_level);
    }
    var _res_mult=1+0.10*_tier;
    var _enemy_mult=1+0.15*min(_tier,5);
    // height-based enemy spawning
    if(!global.qa) {
        var _alt=altitude;
        // count entities on camera
        var _ent_count=instance_number(obj_slime)+instance_number(obj_enemy_flying)+instance_number(obj_meteor_enemy);
        var _cam_top=camera_y; var _cam_bot=camera_y+768;
        // Detect kills: counts that dropped since last frame (cleanup below adjusts the baseline, so it is not counted as a kill).
        var _dn0=instance_number(obj_devil);var _sn0=instance_number(obj_meteor_enemy);
        if(_dn0<devil_prev){devil_kills+=devil_prev-_dn0;devil_timer=max(devil_timer,600);}
        if(_sn0<ship_prev) ships_defeated=true;
        // One enemy at a time: a shared cooldown spaces spawns out, and the
        // simultaneous cap only grows as the player climbs higher.
        // On the ground stretch (first 25% of the climb) keep 2 to 3 slimes alive.
        var _cap=(_alt<0.25?3:round((_alt<0.5?1:(_alt<0.75?2:3))*_enemy_mult));
        // The fixed fire-spawner ship must not eat the slime quota below 50% altitude.
        if(_alt<0.5) _ent_count=instance_number(obj_slime);
        // The cooldown only runs while there is room, so a kill never triggers an instant respawn on top of another enemy.
        if(enemy_spawn_timer>0 && _ent_count<_cap) enemy_spawn_timer--;
        if(enemy_spawn_timer<=0 && _ent_count<_cap) {
            var _sx=irandom_range(100,room_width-100);
            var _roll=irandom(99);
            var _retry=false;
            if(_alt<0.5) {
                var _sp=scr_slime_spawn_point();
                if(_sp!=undefined) {var _ns=instance_create_layer(_sp[0],_sp[1],"Instances_1",obj_slime);_ns.spawn_t=_ns.spawn_total;scr_sfx(sfx_slime_spawn,0.05,0.7);}
                else _retry=true; // nothing to stand on yet, retry in a second
            } else if(_alt<0.75) {
                if(_roll<50) scr_spawn_ship(_sx,camera_y-60);
                else scr_spawn_ship(_sx,camera_y-60);
            } else {
                scr_spawn_ship(_sx,camera_y-60);
            }
            // 6s between spawns at the bottom, down to ~3.5s near the top.
            enemy_spawn_timer=max(30,round((round(lerp(360,210,clamp(_alt,0,1)))+irandom_range(0,60))/_enemy_mult));
            if(_retry) enemy_spawn_timer=60;
            // Below the minimum of 2 slimes, refill quickly (1 s) instead of waiting the full cooldown.
            if(_alt<0.25 && instance_number(obj_slime)<2) enemy_spawn_timer=min(enemy_spawn_timer,60);
        }
        // Fire-spawner ship of platform 4: hovers halfway between platforms 3 and 4 (created once the climb nears platform 3).
        if(!meteor_post_done && _alt>=0.3 && room_get_name(room)=="Room1" && variable_global_exists("tower_spacing")) {
            meteor_post_done=true;
            instance_create_layer(room_width/2,round(scr_floor_y()-global.tower_spacing*3.5),"Instances_1",obj_meteor_enemy);
        }
        // Devils up high: always at least 2 alive, never more than 3.
        if(devil_timer>0) devil_timer--;
        // Devils start just past platform 4 (about 63% altitude). At most 1 per platform and 2 per section
        // (a section = the stretch between two platforms, so its two platforms are its two slots).
        if(_alt>=0.63 && devil_timer<=0 && variable_global_exists("tower_spacing")) {
            var _dk=scr_tower_section(camera_y+384);var _free_pid=-1;
            for(var _pid=_dk;_pid<=_dk+1;_pid++) {
                if(_pid<4) continue;
                var _taken=false;
                with(obj_devil) { if(variable_instance_exists(id,"plat_id") && plat_id==_pid) _taken=true; }
                if(!_taken && _free_pid<0) _free_pid=_pid;
            }
            // Two devils at first; once they have been killed only one remains, and every respawn takes 10 s.
            if(_free_pid>=0 && instance_number(obj_devil)<(devil_kills>=2?1:2)) {
                var _dv=instance_create_layer(irandom_range(140,room_width-140),camera_y-100,"Instances_1",obj_devil);
                _dv.plat_id=_free_pid;
                devil_timer=(devil_kills==0?150:600);
            }
        }
        devil_prev=instance_number(obj_devil);ship_prev=instance_number(obj_meteor_enemy);
        // Cleanup entities far below camera
        with(obj_slime) { if(y > other.camera_y + 900) instance_destroy(); }
        // A fallen skeleton mage re-forms on its platform after 25 s.
        for(var _sp=0;_sp<array_length(skeleton_posts);_sp++) {
            var _post=skeleton_posts[_sp];
            if(instance_exists(_post.inst)) continue;
            _post.timer++;
            if(_post.timer>=1500) {_post.inst=instance_create_layer(_post.x,_post.y,"Instances_1",obj_skeleton);_post.timer=0;}
        }
        with(obj_devil) { if(y > other.camera_y + 900) {other.devil_prev--;instance_destroy();} }
        with(obj_enemy_flying) { if(y > other.camera_y + 900) instance_destroy(); }
        with(obj_meteor_enemy) { if(y > other.camera_y + 900) {other.ship_prev--;instance_destroy();} }
    }
    if(global.death_window_timer>0) global.death_window_timer--;
    // Resource rain: a steady stream whose rate grows smoothly with altitude (no bursts, no stalls).
    //   drops/s = lerp(1.5, 6, d) * (1 + 0.10 * d * tower_levels),  d = climb fraction 0..1
    var _d_res=clamp(altitude,0,1);
    var _res_rate=lerp(1.5,6,_d_res)*(1+0.10*_d_res*tower_levels)/60;
    // Opening shower: for the first 3 s of a run, resources rain faster so everyone has a starting stock.
    if(global.game_state=="play" && global.game_timer<180) _res_rate+=6/60;
    res_acc+=_res_rate;
    with(obj_material) { if(y>other.camera_y+1500) instance_destroy(); }
    while(res_acc>=1) {
        res_acc-=1;
        // Evenly spread across the full width (golden-ratio stepping), above the visible sky.
        res_slot=(res_slot+0.618034) mod 1;
        instance_create_layer(64+res_slot*(room_width-128),camera_y-40,"Instances_1",obj_material);
    }
    // life item spawn
    life_spawn_timer--;
    if(life_spawn_timer<=0) {
        // Hearts fall more often the higher you climb: 10-20 s at the bottom down to 4-8 s at the top.
        // From platform 5 up the heart rate doubles (interval halves).
        var _p5=(variable_global_exists("tower_spacing") && scr_floor_y()-(camera_y+384)>=5*global.tower_spacing);
        life_spawn_timer=round(irandom_range(600,1200)*lerp(1,0.4,clamp(altitude,0,1))*(_p5?0.5:1));
        if(instance_number(obj_life_item)<(altitude<0.5?2:(_p5?4:3))) {
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
                // From platform 5 up only rock meteors fall (no more yellow shooting stars).
                var _at5=(variable_global_exists("tower_spacing") && scr_floor_y()-(camera_y+384)>=5*global.tower_spacing);
                var _kind=(_at5 || altitude>0.72)?1:0;
                var _target=instance_find((irandom(1)==0?obj_player_p1:obj_player_p2),0);
                var _sx=irandom_range(80,room_width-80);
                if(_target!=noone && _target.active_player && !_target.dead)
                    _sx=clamp(_target.x+irandom_range(-170,170),80,room_width-80);
                var _h=instance_create_layer(_sx,camera_y-70,"Instances_1",obj_meteor);
                _h.kind=_kind;
                scr_sfx(_kind==0?sfx_shooting_star:sfx_meteor_fall,0.07,_kind==0?0.55:0.65);
                if(_kind==0) {
                    _h.radius=13;_h.fall_speed=3.2+_hazard_level*2.2;_h.drift=random_range(-0.45,0.45);
                } else {
                    _h.radius=20;_h.fall_speed=5.2+_hazard_level*2.6;_h.drift=random_range(-0.75,0.75);
                }
                hazard_timer=max(30,round((round(lerp(280,120,_hazard_level))+irandom_range(-30,30))/_enemy_mult));
            }
        } else hazard_timer=150;
    }
    // GOD MODE (debug): type Down, Down, Left, Right to toggle. Immortal + auto-flies to the top.
    if(!global.qa) {
        var _tok="";
        if(keyboard_check_pressed(vk_down)||keyboard_check_pressed(ord("S")))_tok="D";
        else if(keyboard_check_pressed(vk_left)||keyboard_check_pressed(ord("A")))_tok="L";
        else if(keyboard_check_pressed(vk_right)||keyboard_check_pressed(ord("D")))_tok="R";
        else if(keyboard_check_pressed(vk_up)||keyboard_check_pressed(ord("W")))_tok="U";
        if(_tok!="") { god_buf=string_copy(god_buf+_tok,max(1,string_length(god_buf+_tok)-3),4); if(god_buf=="DDLR") { global.god=!global.god; god_buf=""; if(!global.god){with(_p1)gravity_speed=0.48;with(_p2)gravity_speed=0.48;} scr_sfx(sfx_checkpoint,0,0.9); } }
    }
    // L1 on the controller also toggles god mode.
    if(!global.qa && scr_gamepad_god_pressed()) { global.god=!global.god; scr_sfx(sfx_checkpoint,0,0.9); if(!global.god){with(_p1)gravity_speed=0.48;with(_p2)gravity_speed=0.48;} }
    if(global.god) {
        for(var _gi=0;_gi<2;_gi++) {
            var _gp=(_gi==0?_p1:_p2);
            if(!_gp.active_player) continue;
            _gp.dead=false; _gp.player_lives=9; _gp.invulnerable=max(_gp.invulnerable,30); _gp.stun_timer=0;
            _gp.vy=0;
            _gp.gravity_speed=0; // free flight: no sinking while hovering
            {
                // Manual flight: P1 = W/A/S/D, P2 = arrows; in solo both layouts work.
                var _solo=(global.player_count==1);
                var _gl=((_gi==0||_solo)&&keyboard_check(ord("A")))||((_gi==1||_solo)&&keyboard_check(vk_left));
                var _gr=((_gi==0||_solo)&&keyboard_check(ord("D")))||((_gi==1||_solo)&&keyboard_check(vk_right));
                var _gu=((_gi==0||_solo)&&keyboard_check(ord("W")))||((_gi==1||_solo)&&keyboard_check(vk_up));
                var _gd=((_gi==0||_solo)&&keyboard_check(ord("S")))||((_gi==1||_solo)&&keyboard_check(vk_down));
                // Controller: left stick or D-pad flies the character that controller drives.
                var _pad=scr_gamepad_for_player(_gi);
                if(_pad>=0) {
                    var _pax=gamepad_axis_value(_pad,gp_axislh);var _pay=gamepad_axis_value(_pad,gp_axislv);
                    _gl=_gl||_pax<-0.4||gamepad_button_check(_pad,gp_padl);
                    _gr=_gr||_pax>0.4||gamepad_button_check(_pad,gp_padr);
                    _gu=_gu||_pay<-0.4||gamepad_button_check(_pad,gp_padu);
                    _gd=_gd||_pay>0.4||gamepad_button_check(_pad,gp_padd);
                }
                _gp.x=clamp(_gp.x+(_gr-_gl)*6,32,room_width-32);
                _gp.y=clamp(_gp.y+(_gd-_gu)*8,60,scr_floor_y());
            }
        }
    }
    // Finish: touch the deity waiting on the top platform (automated QA keeps the old height rule).
    var _won=false;
    if(global.qa) {
        var _all_finished=true;var _any_active=false;
        for(var _fi=0;_fi<2;_fi++) {
            var _fp=(_fi==0?_p1:_p2);
            if(!_fp.active_player) continue;
            _any_active=true;
            if(_fp.dead || _fp.y >= 220) _all_finished=false;
        }
        _won=(_any_active && _all_finished);
    } else if(instance_exists(obj_god_npc)) {
        _won=(obj_god_npc.reached && obj_god_npc.reached_t>=50);
    }
    if(_won) {
        if(room_next(room)!=-1) { global.retry_pending=true; room_goto_next(); exit; }
        else { global.game_state="ending"; ending_timer=0; global.game_timer=0; scr_screen_music("ending"); scr_sfx(sfx_victory,0,0.9); }
    }
} else if(global.game_state=="ending") {
    ending_timer++;
    scr_cut_voice(ending_timer);
    if(ending_timer>30 && ending_timer<4600 &&
       ((global.qa_skip_ending && ending_timer==100) || (!global.qa && (keyboard_check_pressed(ord("E"))||keyboard_check_pressed(vk_enter)||scr_gamepad_skip_pressed())))) {
        ending_timer=4600;scr_cut_voice_stop();
    }
    if(ending_timer>=4660 && !global.qa) {
        var _back_click=mouse_check_button_pressed(mb_left) && point_in_rectangle(device_mouse_x_to_gui(0),device_mouse_y_to_gui(0),543,616,823,684);
        if(_back_click||keyboard_check_pressed(vk_enter)||keyboard_check_pressed(ord("E"))||keyboard_check_pressed(ord("W"))||keyboard_check_pressed(vk_up)||scr_gamepad_confirm_pressed()) {scr_sfx(sfx_ui_confirm);scr_return_to_title();exit;}
    }
    if(ending_timer>=4780 && global.qa) {
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
