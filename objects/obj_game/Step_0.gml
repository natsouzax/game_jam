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
    var _restart_ok=global.game_state=="title" && _p1.material_count==0 && _p2.material_count==0 && instance_number(obj_build_block)==5;
    global.qa_result.restarted=_restart_ok;global.qa_result.passed=global.qa_result.passed && _restart_ok;
    var _report=file_text_open_write(global.qa_recovery_test?"qa_recovery_result.json":"qa_result.json");file_text_write_string(_report,json_stringify(global.qa_result));file_text_close(_report);game_end();exit;
}
if(global.game_state=="title") {
    if(keyboard_check_pressed(ord("W")) || global.qa)global.ready_one=true;
    if(keyboard_check_pressed(vk_up) || global.qa)global.ready_two=true;
    if(global.ready_one && global.ready_two) {global.game_state="intro";global.game_timer=0;}
} else if(global.game_state=="intro") {
    if(global.game_timer>180 || (global.qa && global.game_timer>30)) {global.game_state="play";global.game_timer=0;}
} else if(global.game_state=="play") {
    spawn_timer--;
    if(instance_number(obj_material)==0 && spawn_timer<=0) {
        var _p=(spawn_side mod 2==0?_p1:_p2);spawn_side++;
        var _drop_x=clamp(_p.x+irandom_range(-14,14),64,room_width-64);
        var _drop_y=max(20,_p.y-180);
        for(var _si=0;_si<instance_number(obj_world_solid);_si++) {
            var _roof=instance_find(obj_world_solid,_si);
            if(_drop_x+18>_roof.x && _drop_x-18<_roof.x+_roof.solid_width && _roof.y<_p.y-40 && _roof.y+_roof.solid_height>_drop_y)
                _drop_y=max(_drop_y,_roof.y+_roof.solid_height+20);
        }
        _drop_y=min(_drop_y,_p.y-45);
        var _m=instance_create_layer(_drop_x,_drop_y,"Instances_1",obj_material);
        spawn_timer=38;
    }
    camera_y=lerp(camera_y,clamp(max(_p1.y,_p2.y)-600,0,room_height-768),0.09);
    camera_set_view_pos(cam,0,camera_y);
    if(_p1.grounded && _p2.grounded && abs(_p1.y-448)<2 && abs(_p2.y-448)<2 && _p1.x>500 && _p1.x<844 && _p2.x>500 && _p2.x<844) {
        global.game_state="ending";ending_timer=0;global.game_timer=0;
    }
} else if(global.game_state=="ending") {
    ending_timer++;
    if(ending_timer>420 && (keyboard_check_pressed(ord("W"))||keyboard_check_pressed(vk_up)||global.qa)) {
        if(global.qa) {
            var _ok=_p1.collected_total>0 && _p2.collected_total>0 && _p1.built_total>0 && _p2.built_total>0 && global.simultaneous_frames>0;
            if(global.qa_recovery_test)_ok=_ok && _p1.fall_hits>0 && _p2.enemy_hits>0 && _p1.recovery_valid && _p2.recovery_valid;
            global.qa_result={passed:_ok,ending:true,frames:global.qa_frame,p1_collected:_p1.collected_total,p2_collected:_p2.collected_total,p1_built:_p1.built_total,p2_built:_p2.built_total,p1_checkpoint:_p1.checkpoint_level,p2_checkpoint:_p2.checkpoint_level,p1_recoveries:_p1.recoveries,p2_recoveries:_p2.recoveries,fall_hits:_p1.fall_hits,enemy_hits:_p2.enemy_hits,simultaneous_frames:global.simultaneous_frames,p1_shared_uses:_p1.shared_uses,p2_shared_uses:_p2.shared_uses,p1_removed_blocks:_p1.reset_blocks_total,p2_removed_blocks:_p2.reset_blocks_total,section_scope_ok:_p1.recovery_valid && _p2.recovery_valid};
            global.qa_restart_pending=true;room_restart();exit;
        } else room_restart();
    }
}
if(global.qa) {
    global.qa_frame++;
    if(_p1.last_move!=0 && _p2.last_move!=0)global.simultaneous_frames++;
    if(global.qa_frame mod 300==0) {
        var _q=file_text_open_write("qa_progress.json");file_text_write_string(_q,json_stringify({frames:global.qa_frame,state:global.game_state,p1x:_p1.x,p1y:_p1.y,p2x:_p2.x,p2y:_p2.y,p1stock:_p1.material_count,p2stock:_p2.material_count,p1falls:_p1.fall_hits,p2enemy:_p2.enemy_hits,p1built:_p1.built_total,p2built:_p2.built_total,p1target:(_p1.qa_target!=noone && instance_exists(_p1.qa_target)?_p1.qa_target.y:-1),p1grounded:_p1.grounded}));file_text_close(_q);
    }
    if(global.qa_stage==1 || global.qa_frame>24000) {
        var _ok=global.qa_ending_seen && _p1.collected_total>0 && _p2.collected_total>0 && _p1.built_total>0 && _p2.built_total>0;
        var _f=file_text_open_write(global.qa_recovery_test?"qa_recovery_result.json":"qa_result.json");
        file_text_write_string(_f,json_stringify({passed:_ok,ending:global.qa_ending_seen,frames:global.qa_frame,p1_collected:_p1.collected_total,p2_collected:_p2.collected_total,p1_built:_p1.built_total,p2_built:_p2.built_total,p1_checkpoint:_p1.checkpoint_level,p2_checkpoint:_p2.checkpoint_level,p1_recoveries:_p1.recoveries,p2_recoveries:_p2.recoveries}));
        file_text_close(_f);game_end();
    }
}
