function scr_qa_report_name() {
    if(global.qa_solo>=0)return "qa_solo"+string(global.qa_solo+1)+"_result.json";
    return global.qa_recovery_test?"qa_recovery_result.json":"qa_result.json";
}
function scr_qa_menu() {
    // Stage 0 -> Stage 1 (Iniciar Jogo), then mode/character selection.
    if(global.qa_frame==15)scr_menu_input(0,true,false);
    if(global.qa_frame==25)scr_menu_input(-1,false,false);
    if(global.qa_frame==35)scr_menu_input(0,true,false);
    if(global.qa_solo<0) {
        if(global.qa_frame==45) {
            global.qa_menu_ok=global.menu_stage==2 && global.menu_mode==0;
            scr_menu_input(0,false,true);
            global.qa_menu_ok=global.qa_menu_ok && global.menu_stage==1;
        }
        if(global.qa_frame==55)scr_menu_input(1,false,false);
        if(global.qa_frame==65)scr_menu_input(0,true,false);
    } else {
        if(global.qa_frame==45 && global.qa_solo==1)scr_menu_input(1,false,false);
        if(global.qa_frame==55) {
            global.qa_menu_ok=global.menu_stage==2 && global.menu_mode==0 && global.solo_character==global.qa_solo;
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
    var _floor=scr_floor_y();
    var _created=[];
    for(var _b=0;_b<14;_b++) {
        var _blk=instance_create_layer(64+(_b mod 7)*64,_floor-64-(_b div 7)*64,"Instances_1",obj_build_block);
        _blk.builder_number=(_b mod 2);
        array_push(_created,_blk);
    }
    _p1.checkpoint_level=1;_p1.respawn_x=640;_p1.respawn_y=_floor-192;_p1.material_count=3;_p1.player_lives=2;
    with(_p1) scr_player_die();
    var _remaining_after_damage=0;
    for(var _c=0;_c<array_length(_created);_c++) if(instance_exists(_created[_c])) _remaining_after_damage++;
    var _damage_preserves_ok=(_remaining_after_damage==14 && _p1.reset_blocks_total==0 && _p1.player_lives==1);
    _p2.material_count=2;_p2.player_lives=1;
    with(_p2) scr_player_die();
    var _remaining_after_death=0;
    for(var _d=0;_d<array_length(_created);_d++) if(instance_exists(_created[_d])) _remaining_after_death++;
    var _fixed=0;
    for(var _i=0;_i<instance_number(obj_build_block);_i++) {
        if(instance_find(obj_build_block,_i).is_checkpoint) _fixed++;
    }
    var _ok=_damage_preserves_ok && _remaining_after_death==4 && _p2.reset_blocks_total==10
        && _fixed==0 && _p1.recovery_valid && _p2.recovery_valid;
    return {passed:_ok,damage_removed:_p1.reset_blocks_total,death_removed:_p2.reset_blocks_total,
        remaining_after_damage:_remaining_after_damage,remaining_after_death:_remaining_after_death,
        fixed_platforms:_fixed,inventories_preserved:_p1.material_count==3 && _p2.material_count==2};
}

// Regression fixture for split floor, independent jump/dash and death menu retry.
function scr_qa_regression(_p1,_p2) {
    var _g=instance_find(obj_game,0);
    if(_g.qa_regression_stage==0 && !variable_global_exists("regression_report")) {
        global.game_state="play";global.player_count=1;global.solo_character=0;
        _p2.active_player=false;
        var _floor=scr_floor_y();
        var _hole=!scr_world_aabb_solid(650,_floor,710,_floor+1);
        var _bank=scr_world_aabb_solid(180,_floor,220,_floor+1);
        with(_p1) {
            x=200;y=scr_floor_y();vy=0;
            scr_player_tick(0,true,false,false,true);
        }
        var _normal=abs(_p1.vy-(-11+0.48))<0.01 && _p1.charge==0 && _p1._hthrust==0;
        // Releasing jump key early immediately stops upward ascent.
        with(_p1) {
            scr_player_tick(0,false,false,false,false);
        }
        var _early_stop=(_p1.vy>=0 && !_p1.jump_rising);
        // Holding jump key climbs higher than releasing early and caps at max height.
        var _min_y_short=_floor;
        with(_p1) {
            x=200;y=scr_floor_y();vy=0;
            scr_player_tick(0,true,false,false,true);
            repeat(3){scr_player_tick(0,false,false,false,true);_min_y_short=min(_min_y_short,y);}
            repeat(20){scr_player_tick(0,false,false,false,false);_min_y_short=min(_min_y_short,y);}
        }
        var _min_y_full=_floor;
        with(_p1) {
            x=200;y=scr_floor_y();vy=0;
            scr_player_tick(0,true,false,false,true);
            repeat(40){scr_player_tick(0,false,false,false,true);_min_y_full=min(_min_y_full,y);}
        }
        var _var_jump=(_early_stop && _min_y_full<_min_y_short-60);
        // Releasing Q before full charge does not jump (Q is only Dash).
        with(_p1) {
            x=200;y=scr_floor_y();vy=0;charge=0;_hthrust=0;
            repeat(10)scr_player_tick(1,false,false,true,false);
            scr_player_tick(0,false,false,false,false);
        }
        var _partial_dash_no_jump=(_p1.charge==0 && _p1._hthrust==0 && _p1.y==_floor);
        with(_p1) {
            x=200;y=scr_floor_y();vy=0;
            repeat(150)scr_player_tick(1,false,false,true);
        }
        var _held=_p1.charge==DASH_CHARGE_FRAMES && _p1.x==200 && _var_jump && _partial_dash_no_jump;
        var _dash_enemy=instance_create_layer(226,scr_floor_y()-30,"Instances_1",obj_enemy);
        with(_p1)scr_player_tick(0,false,false,false);
        var _dash=_p1.x==200+DASH_THRUST && _p1._hthrust>0 && _p1.vy<0;
        var _ability_kill=!instance_exists(_dash_enemy);
        global.player_count=2;_p2.active_player=true;
        var _magnet_mat=instance_create_layer(240,scr_floor_y()-30,"Instances_1",obj_material);
        with(_p2) {
            x=200;y=scr_floor_y();vy=0;material_count=0;_hthrust=0;
            repeat(DASH_CHARGE_FRAMES)scr_player_tick(1,false,false,true);
            scr_player_tick(0,false,false,false);
        }
        var _ability_magnet=_p2.material_count==1 && !instance_exists(_magnet_mat);
        _p2.active_player=false;global.player_count=1;
        global.regression_report={hole:_hole,bank:_bank,normal_jump:_normal,charge:_held,dash:_dash,
            ability_kill:_ability_kill,ability_magnet:_ability_magnet};
        with(_p1){x=270;y=scr_floor_y();vy=0;_hthrust=0;}
        _g.qa_regression_stage=1;
    } else if(_g.qa_regression_stage==1) {
        _g.qa_regression_hold++;
        if(_g.qa_regression_hold<12)return;
        _g.qa_regression_hold=0;
        var _test_blocks=[];
        for(var _bi=0;_bi<14;_bi++) {
            var _tb=instance_create_layer(64+(_bi mod 7)*64,scr_floor_y()-64-(_bi div 7)*64,"Instances_1",obj_build_block);
            _tb.builder_number=0;
            array_push(_test_blocks,_tb);
        }
        _p1.player_lives=2;
        with(_p1)scr_player_die();
        var _unobstructed_ok=true;
        with(_p1){_unobstructed_ok=!scr_is_spawn_obstructed(x,y);}
        var _after_dmg=0;
        for(var _ci=0;_ci<array_length(_test_blocks);_ci++) if(instance_exists(_test_blocks[_ci])) _after_dmg++;
        // Second hit kills the player (lives == 0) and removes at most 10 random blocks.
        with(_p1)scr_player_die();
        var _after_death=0;
        for(var _di=0;_di<array_length(_test_blocks);_di++) if(instance_exists(_test_blocks[_di])) _after_death++;
        global.regression_report.damage_keeps_blocks=(_after_dmg==14 && _unobstructed_ok);
        global.regression_report.death_removes_max_10=(_after_death==4);
        global.regression_report.solo_menu=global.game_state=="gameover";
        _g.qa_regression_stage=2;
    } else if(_g.qa_regression_stage==2) {
        _g.qa_regression_hold++;
        if(_g.qa_regression_hold<8)return;
        _g.qa_regression_stage=3;scr_gameover_select(0);
    } else {
        global.regression_report.retry=global.game_state=="play" && _p1.active_player && !_p2.active_player && _p1.player_lives==3;
        global.player_count=2;_p2.active_player=true;_p1.player_lives=1;
        with(_p1)scr_player_die();
        global.regression_report.coop_menu=global.game_state=="gameover";
        scr_gameover_select(1);
        var _gp_arr=scr_gamepad_menu_input();
        var _menu_gp_ok=(array_length(_gp_arr)==4);
        // Verify non-inverted menu navigation: S (-1) moves down, W (+1) moves up; A (-1) selects left (0), D (+1) selects right (1).
        global.menu_stage=0;global.title_choice=0;
        scr_menu_input(0,false,false,-1,false);
        var _down_ok=(global.title_choice==1);
        scr_menu_input(0,false,false,1,false);
        var _up_ok=(global.title_choice==0);
        scr_menu_input(0,true,false,0,false);
        var _enter_stage1=(global.menu_stage==1 && global.menu_mode==1);
        scr_menu_input(-1,false,false,0,false);
        var _left_ok=(global.menu_mode==0);
        scr_menu_input(-1,false,false,0,false);
        _left_ok=(_left_ok && global.menu_mode==0);
        scr_menu_input(1,false,false,0,false);
        var _right_ok=(global.menu_mode==1);
        global.menu_stage=0;
        global.regression_report.return_title=(global.game_state=="title" && _menu_gp_ok && _down_ok && _up_ok && _enter_stage1 && _left_ok && _right_ok);
        var _r=global.regression_report;
        _r.passed=_r.hole && _r.bank && _r.normal_jump && _r.charge && _r.dash && _r.ability_kill && _r.ability_magnet && _r.damage_keeps_blocks && _r.death_removes_max_10 && _r.solo_menu && _r.retry && _r.coop_menu && _r.return_title;
        var _file=file_text_open_write("qa_regression_result.json");
        file_text_write_string(_file,json_stringify(_r));file_text_close(_file);game_end();
    }
}
