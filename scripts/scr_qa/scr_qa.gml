function scr_qa_report_name() {
    if(global.qa_solo>=0)return "qa_solo"+string(global.qa_solo+1)+"_result.json";
    return global.qa_recovery_test?"qa_recovery_result.json":"qa_result.json";
}
function scr_qa_menu() {
    // Same menu handler as physical inputs, including return from avatar selection.
    if(global.qa_frame==25)scr_menu_input(-1,false,false);
    if(global.qa_frame==35)scr_menu_input(0,true,false);
    if(global.qa_solo<0) {
        if(global.qa_frame==45) {
            global.qa_menu_ok=global.menu_stage==1 && global.menu_mode==0;
            scr_menu_input(0,false,true);
            global.qa_menu_ok=global.qa_menu_ok && global.menu_stage==0;
        }
        if(global.qa_frame==55)scr_menu_input(1,false,false);
        if(global.qa_frame==65)scr_menu_input(0,true,false);
    } else {
        if(global.qa_frame==45 && global.qa_solo==1)scr_menu_input(1,false,false);
        if(global.qa_frame==55) {
            global.qa_menu_ok=global.menu_stage==1 && global.menu_mode==0 && global.solo_character==global.qa_solo;
            scr_menu_input(0,true,false);
        }
    }
}
function scr_qa_summary(_p1,_p2) {
    var _ok=global.qa_menu_ok && global.intro_seen[0] && global.intro_seen[1] && global.intro_seen[2];
    var _inactive_ok=true;
    for(var _i=0;_i<2;_i++) {
        var _p=(_i==0?_p1:_p2);
        if(_p.active_player)_ok=_ok && _p.collected_total>0 && _p.built_total>0 && _p.checkpoint_level==0;
        else _inactive_ok=_inactive_ok && _p.collected_total==0 && _p.built_total==0 && _p.recoveries==0 && _p.checkpoint_level==0;
    }
    _ok=_ok && _inactive_ok;
    if(global.player_count==2)_ok=_ok && global.simultaneous_frames>0 && _p1.shared_uses>0 && _p2.shared_uses>0;
    if(global.qa_recovery_test)_ok=_ok && _p1.fall_hits>0 && _p2.fall_hits>0 && _p1.recovery_valid && _p2.recovery_valid;
    return {passed:_ok,ending:true,frames:global.qa_frame,players:global.player_count,solo_character:global.solo_character,
        menu_ok:global.qa_menu_ok,intro_all_scenes:global.intro_seen[0] && global.intro_seen[1] && global.intro_seen[2],inactive_untouched:_inactive_ok,
        p1_collected:_p1.collected_total,p2_collected:_p2.collected_total,p1_built:_p1.built_total,p2_built:_p2.built_total,
        p1_checkpoint:_p1.checkpoint_level,p2_checkpoint:_p2.checkpoint_level,p1_recoveries:_p1.recoveries,p2_recoveries:_p2.recoveries,
        fall_hits:_p1.fall_hits,enemy_hits:_p2.enemy_hits,p1_enemy_hits:_p1.enemy_hits,p2_fall_hits:_p2.fall_hits,simultaneous_frames:global.simultaneous_frames,
        p1_shared_uses:_p1.shared_uses,p2_shared_uses:_p2.shared_uses,p1_removed_blocks:_p1.reset_blocks_total,p2_removed_blocks:_p2.reset_blocks_total,
        section_scope_ok:_p1.recovery_valid && _p2.recovery_valid};
}
function scr_qa_capture() {
    if(global.game_state=="title" && global.qa_frame==20)screen_save("qa_menu.png");
    if(global.game_state=="title" && global.qa_frame==46)screen_save("qa_character.png");
    if(global.game_state=="intro" && global.game_timer mod 240==120)screen_save("qa_intro_"+string(global.game_timer div 240)+".png");
    if(global.game_state=="play" && global.game_timer==300)screen_save(global.qa_solo>=0?"qa_solo"+string(global.qa_solo+1)+"_gameplay.png":"qa_gameplay.png");
    if(global.game_state=="play" && global.game_timer==5)screen_save(global.qa_solo>=0?"qa_solo"+string(global.qa_solo+1)+"_start.png":"qa_coop_start.png");
    if(global.game_state=="ending" && ending_timer==300)screen_save("qa_final.png");
}
function scr_qa_input() {
    var _move=0;var _jump=false;var _build=false;
    if(qa_jump_cooldown>0)qa_jump_cooldown--;
    if(qa_target!=noone && !instance_exists(qa_target))qa_target=noone;
    if(qa_target!=noone && grounded && y<=qa_target.y+3)qa_target=noone;
    if(qa_target==noone && grounded) {
        var _best=noone;var _best_y=y-12;
        for(var _i=0;_i<instance_number(obj_build_block);_i++) {
            var _s=instance_find(obj_build_block,_i);
            var _margin=min(12,_s.solid_width/2);
            var _tx=clamp(x,_s.x+_margin,_s.x+_s.solid_width-_margin);
            if(_s.y<y-12 && _s.y>=y-100 && abs(_tx-x)<120 && (_best==noone || _s.y<_best_y)) {_best=_s;_best_y=_s.y;}
        }
        qa_target=_best;
    }
    if(qa_target!=noone) {
        var _margin=min(12,qa_target.solid_width/2);
        var _target=clamp(x,qa_target.x+_margin,qa_target.x+qa_target.solid_width-_margin);
        // A retained upper-section block can be a ceiling: choose a clear landing column.
        if(qa_target.is_checkpoint) {
            var _candidates=[_target];
            for(var _column=qa_target.x+24;_column<qa_target.x+qa_target.solid_width-16;_column+=32) array_push(_candidates,_column);
            var _distance=100000;
            for(var _c=0;_c<array_length(_candidates);_c++) {
                var _cx=_candidates[_c];
                if(abs(_cx-x)<_distance && !scr_world_aabb_solid(_cx-16,qa_target.y-body_height,_cx+16,y,true)) {
                    _target=_cx;_distance=abs(_cx-x);
                }
            }
        }
        _move=(abs(_target-x)>3 ? sign(_target-x):0);
        _jump=grounded && qa_jump_cooldown==0;
    } else if(grounded && y>448) {
        if(material_count>0) {_move=(x<600?1:(x>760?-1:facing));_build=true;}
        else {
            var _resource=instance_nearest(x,y,obj_material);
            if(_resource!=noone && abs(_resource.x-x)>12)_move=sign(_resource.x-x);
        }
    }
    if(_jump)qa_jump_cooldown=28;
    return [_move,_jump,_build];
}

// Focused runtime fixture, separate from the action-driven full-game replay.
function scr_qa_section_reset_test(_p1,_p2) {
    var _earlier=instance_create_layer(64,1376,"Instances_1",obj_build_block);
    var _current_one=instance_create_layer(128,1184,"Instances_1",obj_build_block);
    var _current_two=instance_create_layer(192,1152,"Instances_1",obj_build_block);
    var _later=instance_create_layer(256,992,"Instances_1",obj_build_block);
    _current_one.builder_number=0;_current_two.builder_number=1;
    _p1.checkpoint_level=1;_p1.respawn_x=640;_p1.respawn_y=1216;_p1.material_count=3;
    with(_p1) scr_player_recover();
    var _section_one_ok=!instance_exists(_current_one) && !instance_exists(_current_two)
        && instance_exists(_earlier) && instance_exists(_later)
        && _p1.x==640 && _p1.y==1216 && _p1.material_count==3 && _p1.reset_blocks_total==2;
    _p2.material_count=2;
    with(_p2) scr_player_recover();
    var _fixed=0;
    for(var _i=0;_i<instance_number(obj_build_block);_i++) {
        if(instance_find(obj_build_block,_i).is_checkpoint) _fixed++;
    }
    var _ok=_section_one_ok && !instance_exists(_earlier) && instance_exists(_later)
        && _p2.y==1408 && _p2.material_count==2 && _p2.reset_blocks_total==1
        && _fixed==0 && instance_number(obj_build_block)==1 && _p1.recovery_valid && _p2.recovery_valid;
    return {passed:_ok,section_one_removed:_p1.reset_blocks_total,section_zero_removed:_p2.reset_blocks_total,
        fixed_platforms:_fixed,later_section_preserved:instance_exists(_later),both_builders_removed:_section_one_ok,
        inventories_preserved:_p1.material_count==3 && _p2.material_count==2,checkpoint_return:_p1.y==1216 && _p2.y==1408};
}
