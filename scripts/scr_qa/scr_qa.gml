function scr_qa_report_name() {
    if(global.qa_solo>=0)return "qa_solo"+string(global.qa_solo+1)+"_result.json";
    return global.qa_recovery_test?"qa_recovery_result.json":"qa_result.json";
}
function scr_qa_block_interaction(_p1,_p2) {
    global.game_state="play";
    _p2.active_player=false;
    _p1.x=300;_p1.y=scr_floor_y();_p1.vy=0;_p1.facing=1;_p1.grounded=true;_p1.material_count=2;
    var _target=noone;
    with(_p1)_target=scr_get_build_target();
    var _cell=[_target.bx,_target.by];
    _p1.build_cooldown=0;
    with(_p1)scr_player_tick(0,false,true,false);
    var _block=scr_world_block_at(_cell[0],_cell[1]);
    var _built=(_block!=noone && _p1.material_count==1 && _p1.built_total==1);
    _p1.build_cooldown=0;
    with(_p1)scr_player_tick(0,false,false,false,false,true);
    var _marked=instance_exists(_block) && _block.crack_until>=global.game_timer;
    _p1.build_cooldown=0;
    with(_p1)scr_player_tick(0,false,false,false,false,true);
    var _broken=!instance_exists(_block) && _p1.material_count==2;
    var _fixed=instance_create_layer(_cell[0],_cell[1],"Instances_1",obj_build_block);
    _fixed.is_checkpoint=true;
    _p1.build_cooldown=0;
    with(_p1)scr_player_tick(0,false,true,false);
    var _checkpoint_safe=instance_exists(_fixed);
    instance_destroy(_fixed);
    _p1.material_count=2;
    var _meteor_block=instance_create_layer(640,_cell[1],"Instances_1",obj_build_block);
    _meteor_block.builder_number=0;
    var _meteor=instance_create_layer(672,_cell[1]-30,"Instances_1",obj_meteor);
    _meteor.fall_speed=20;_meteor.drift=0;_meteor.radius=13;
    with(_meteor)event_perform(ev_step,ev_step_normal);
    var _meteor_broke=!instance_exists(_meteor_block) && !instance_exists(_meteor);
    var _enemy=instance_create_layer(_p1.x+35,_p1.y-35,"Instances_1",obj_enemy);
    _p1._hthrust=40;_p1._hdir=1;
    with(_p1)scr_player_dash_ability(x);
    var _reward=!instance_exists(_enemy) && _p1.material_count==3;
    _p1.y=scr_floor_y()-300;_p1.invulnerable=100;
    var _chaser=instance_create_layer(450,scr_floor_y()-80,"Instances_1",obj_enemy_flying);
    _chaser.attack_timer=600;
    var _chaser_start_y=_chaser.y;
    repeat(90)with(_chaser)event_perform(ev_step,ev_step_normal);
    var _chased_up=instance_exists(_chaser) && _chaser.y<_chaser_start_y-35;
    var _passed=_built && _marked && _broken && _checkpoint_safe && _meteor_broke && _reward && _chased_up;
    var _report=file_text_open_write("qa_block_interaction_result.json");
    file_text_write_string(_report,json_stringify({passed:_passed,built:_built,marked:_marked,broken:_broken,checkpoint_safe:_checkpoint_safe,meteor_broke:_meteor_broke,kill_reward:_reward,chased_up:_chased_up}));
    file_text_close(_report);game_end();
}
function scr_qa_revive(_p1,_p2) {
    global.game_state="play";global.player_count=2;
    _p1.player_lives=1;_p2.player_lives=2;
    var _old=instance_create_layer(320,scr_floor_y()-64,"Instances_1",obj_build_block);
    _old.builder_number=0;
    with(_p1)scr_player_die();
    var _partner_continues=global.game_state=="play" && _p1.dead && _p1.player_lives==0
        && !_p2.dead && _p2.active_player && instance_exists(_old) && _p1.reset_blocks_total==0;
    var _new=instance_create_layer(400,scr_floor_y()-64,"Instances_1",obj_build_block);
    _new.builder_number=1;
    var _heart1=instance_create_layer(_p2.x,_p2.y-35,"Instances_1",obj_life_item);
    with(_heart1)event_perform(ev_step,ev_step_normal);
    var _healed_first=_p2.player_lives==3 && _p1.dead && !instance_exists(_heart1);
    var _heart2=instance_create_layer(_p2.x,_p2.y-35,"Instances_1",obj_life_item);
    with(_heart2)event_perform(ev_step,ev_step_normal);
    var _partner_block_preserved=instance_exists(_new);
    var _revived=_p1.player_lives==1 && !_p1.dead && _p1.x==_p1.respawn_x
        && _p1.y==_p1.respawn_y && _p2.player_lives==3 && _partner_block_preserved;
    _p1.player_lives=3;_p2.player_lives=1;
    with(_p2)scr_player_die();
    var _heart3=instance_create_layer(_p1.x,_p1.y-35,"Instances_1",obj_life_item);
    with(_heart3)event_perform(ev_step,ev_step_normal);
    var _reverse_revive=global.game_state=="play" && !_p2.dead && _p2.player_lives==1
        && _p1.player_lives==3 && !instance_exists(_heart3);
    _p1.player_lives=1;with(_p1)scr_player_die();
    _p2.player_lives=1;with(_p2)scr_player_die();
    var _last_death_ends=global.game_state=="gameover";
    var _report=file_text_open_write("qa_revive_result.json");
    file_text_write_string(_report,json_stringify({passed:_partner_continues && _healed_first && _revived && _reverse_revive && _last_death_ends,partner_continues:_partner_continues,healed_first:_healed_first,revived:_revived,reverse_revive:_reverse_revive,partner_block_preserved:_partner_block_preserved,last_death_ends:_last_death_ends}));
    file_text_close(_report);game_end();
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
    } else if(y>448) {
        if(material_count>0) {
            _move=(x<600?1:(x>760?-1:facing));
            // Jump first, then place a forward step near the jump apex.
            _jump=grounded && qa_jump_cooldown==0;
            _build=!grounded && qa_jump_cooldown==18;
        } else if(grounded) {
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
    var _fixed_before=0;
    for(var _fi=0;_fi<instance_number(obj_build_block);_fi++) {
        if(instance_find(obj_build_block,_fi).is_checkpoint) _fixed_before++;
    }
    var _created=[];
    for(var _b=0;_b<14;_b++) {
        var _blk=instance_create_layer(64+(_b mod 7)*64,_floor-64-(_b div 7)*64,"Instances_1",obj_build_block);
        _blk.builder_number=(_b mod 2);
        array_push(_created,_blk);
    }
    global.player_count=1;_p2.active_player=false;
    _p1.checkpoint_level=1;_p1.respawn_x=640;_p1.respawn_y=_floor-192;_p1.material_count=3;_p1.player_lives=2;
    _p1.reset_blocks_total=0;
    with(_p1) scr_player_die();
    var _remaining_after_damage=0;
    for(var _c=0;_c<array_length(_created);_c++) if(instance_exists(_created[_c])) _remaining_after_damage++;
    var _damage_preserves_ok=(_remaining_after_damage==14 && _p1.reset_blocks_total==0 && _p1.player_lives==1);
    with(_p1) scr_player_die();
    var _remaining_after_death=0;
    for(var _d=0;_d<array_length(_created);_d++) if(instance_exists(_created[_d])) _remaining_after_death++;
    var _fixed=0;
    for(var _i=0;_i<instance_number(obj_build_block);_i++) {
        if(instance_find(obj_build_block,_i).is_checkpoint) _fixed++;
    }
    var _fixed_ok=(_fixed==_fixed_before);
    var _ok=_damage_preserves_ok && _remaining_after_death==4 && _p1.reset_blocks_total==10
        && _fixed_ok && _p1.recovery_valid;
    return {passed:_ok,damage_removed:0,death_removed:_p1.reset_blocks_total,
        remaining_after_damage:_remaining_after_damage,remaining_after_death:_remaining_after_death,
        fixed_platforms:_fixed,fixed_platforms_before:_fixed_before,inventories_preserved:_p1.material_count==3};
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
            scr_player_tick(0,true,false,false,false);
        }
        var _normal=abs(_p1.vy-(-11+0.48))<0.01 && _p1.charge==0 && _p1._hthrust==0;
        var _min_y_normal=_floor;
        with(_p1) {
            x=200;y=scr_floor_y();vy=0;jump_rising=false;jump_hold_frames=0;
            scr_player_tick(0,true,false,false,false);
            repeat(80){scr_player_tick(0,false,false,false,false);_min_y_normal=min(_min_y_normal,y);}
        }
        // Holding jump fills the meter and applies a second takeoff after the first jump.
        var _min_y_double=_floor;
        with(_p1) {
            x=200;y=scr_floor_y();vy=0;jump_rising=false;jump_hold_frames=0;jump_double_used=false;
            scr_player_tick(0,true,false,false,true);
            repeat(DOUBLE_JUMP_CHARGE_FRAMES){
                scr_player_tick(0,false,false,false,true);
                _min_y_double=min(_min_y_double,y);
            }
        }
        var _double_triggered=_p1.jump_double_used;
        with(_p1) {
            repeat(70){scr_player_tick(0,false,false,false,false);_min_y_double=min(_min_y_double,y);}
        }
        var _double_jump=_double_triggered && _min_y_double<_min_y_normal-40;
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
        var _held=_p1.charge==DASH_CHARGE_FRAMES && _p1.x==200 && _partial_dash_no_jump;
        var _dash_enemy=instance_create_layer(226,scr_floor_y()-30,"Instances_1",obj_enemy);
        with(_p1)scr_player_tick(0,false,false,false);
        var _dash=_p1.x==200+DASH_THRUST && _p1._hthrust>0 && _p1.vy<0;
        var _ability_kill=!instance_exists(_dash_enemy);
        global.player_count=2;_p2.active_player=true;
        // Far pickup is outside the original aura but inside the 3x aura.
        var _magnet_mat=instance_create_layer(440,scr_floor_y()-30,"Instances_1",obj_material);
        var _outside_mat=instance_create_layer(480,scr_floor_y()-30,"Instances_1",obj_material);
        with(_p2) {
            x=200;y=scr_floor_y();vy=0;material_count=0;_hthrust=0;
            repeat(DASH_CHARGE_FRAMES)scr_player_tick(1,false,false,true);
            scr_player_tick(0,false,false,false);
        }
        var _ability_magnet=_p2.material_count==1 && !instance_exists(_magnet_mat) && instance_exists(_outside_mat);
        _p2.active_player=false;global.player_count=1;
        global.regression_report={hole:_hole,bank:_bank,normal_jump:_normal,double_jump:_double_jump,charge:_held,dash:_dash,
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
        _p1.reset_blocks_total=0;
        _p1.player_lives=2;
        with(_p1)scr_player_die();
        var _unobstructed_ok=true;
        with(_p1){_unobstructed_ok=!scr_is_spawn_obstructed(x,y);}
        var _after_dmg=0;
        for(var _ci=0;_ci<array_length(_test_blocks);_ci++) if(instance_exists(_test_blocks[_ci])) _after_dmg++;
        // Second hit kills the player (lives == 0) and removes at most 10 random blocks.
        with(_p1)scr_player_die();
        var _after_death=0;
        var _remaining_blocks=[];
        for(var _di=0;_di<array_length(_test_blocks);_di++) {
            if(instance_exists(_test_blocks[_di])) { _after_death++; array_push(_remaining_blocks,_test_blocks[_di]); }
        }
        global.qa_retry_blocks=_remaining_blocks;
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
        var _retry_kept=0;
        for(var _ri=0;_ri<array_length(global.qa_retry_blocks);_ri++) if(instance_exists(global.qa_retry_blocks[_ri])) _retry_kept++;
        global.regression_report.retry_clears_blocks=(_retry_kept==0);
        global.player_count=2;_p2.active_player=true;_p1.player_lives=1;
        with(_p1)scr_player_die();
        global.regression_report.coop_survives=global.game_state=="play" && _p1.dead && !_p2.dead;
        _p2.player_lives=1;
        with(_p2)scr_player_die();
        global.regression_report.coop_menu=global.game_state=="gameover";
        scr_gameover_select(1);
        var _gp_arr=scr_gamepad_menu_input();
        var _menu_gp_ok=(array_length(_gp_arr)==4);
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
        _r.passed=_r.hole && _r.bank && _r.normal_jump && _r.double_jump && _r.charge && _r.dash && _r.ability_kill && _r.ability_magnet && _r.damage_keeps_blocks && _r.death_removes_max_10 && _r.retry_clears_blocks && _r.solo_menu && _r.retry && _r.coop_survives && _r.coop_menu && _r.return_title;
        var _file=file_text_open_write("qa_regression_result.json");
        file_text_write_string(_file,json_stringify(_r));file_text_close(_file);game_end();
    }
}

function scr_qa_spawn(_p1,_p2) {
    if(!variable_global_exists("qa_spawn_frame")) {
        global.qa_spawn_frame=0;
        global.game_state="play";
        _p1.active_player=false;_p2.active_player=false;
        var _floor=scr_floor_y();
        instance_create_layer(200,_floor-240,"Instances_1",obj_slime);
        instance_create_layer(400,_floor-240,"Instances_1",obj_skeleton);
        instance_create_layer(620,_floor-300,"Instances_1",obj_devil);
        instance_create_layer(760,camera_y-80,"Instances_1",obj_meteor_enemy);
    }
    global.qa_spawn_frame++;
    if(global.qa_spawn_frame<20) return;
    var _counts={slime:instance_number(obj_slime),skeleton:instance_number(obj_skeleton),
        devil:instance_number(obj_devil),meteor:instance_number(obj_meteor_enemy),
        flying:instance_number(obj_enemy_flying),frames:global.qa_spawn_frame};
    _counts.passed=(_counts.slime>=1 && _counts.skeleton>=1 && _counts.devil>=1 && _counts.meteor>=1);
    var _file=file_text_open_write("qa_spawn_result.json");
    file_text_write_string(_file,json_stringify(_counts));file_text_close(_file);game_end();
}

function scr_qa_save(_p1,_p2) {
    var _g=instance_find(obj_game,0);
    global.game_state="play";
    global.player_count=2;global.solo_character=0;
    global.level_saved=[true,false,true,false];
    _p1.x=333;_p1.y=444;_p1.player_lives=2;_p1.material_count=7;
    _p2.x=555;_p2.y=666;_p2.player_lives=3;_p2.material_count=4;
    var _floor=scr_floor_y();
    var _b=instance_create_layer(704,_floor-64,"Instances_1",obj_build_block);
    _b.builder_number=1;
    _g.camera_y=1234;_g.altitude=0.6;
    scr_save_game(_p1,_p2);
    var _saved_exists=scr_save_exists();
    var _read_handle=file_text_open_read("save.json");
    var _read_len=0;
    if(_read_handle!=-1){var _read_text=file_text_read_string(_read_handle);_read_len=string_length(_read_text);file_text_close(_read_handle);}
    _p1.x=1;_p1.y=1;_p1.player_lives=1;_p1.material_count=0;
    _p2.x=2;_p2.y=2;_p2.player_lives=1;_p2.material_count=0;
    instance_destroy(_b);
    _g.camera_y=0;_g.altitude=0;
    global.player_count=1;global.solo_character=1;global.level_saved=[false,false,false,false];
    var _load_exists=scr_save_exists();
    scr_load_game();
    var _after_load_exists=scr_save_exists();
    var _saved_block=noone;
    for(var _i=0;_i<instance_number(obj_build_block);_i++) {
        var _nb=instance_find(obj_build_block,_i);
        if(!_nb.is_checkpoint && _nb.x==704 && _nb.y==_floor-64) _saved_block=_nb;
    }
    var _ok=(_p1.x==333 && _p1.y==444 && _p1.player_lives==2 && _p1.material_count==7
        && _p2.x==555 && _p2.y==666 && _p2.player_lives==3 && _p2.material_count==4
        && global.player_count==2 && global.solo_character==0
        && _g.camera_y==1234 && abs(global.last_save_altitude-0.6)<0.001
        && global.level_saved[0] && !global.level_saved[1] && global.level_saved[2]
        && _saved_block!=noone && _saved_block.builder_number==1
        && global.game_state=="play");
    scr_clear_save();
    var _cleared=!scr_save_exists();
    _ok=_ok && _cleared;
    var _file=file_text_open_write("qa_save_result.json");
    file_text_write_string(_file,json_stringify({passed:_ok,loaded_x:_p1.x,loaded_stock:_p1.material_count,
        loaded_lives:_p1.player_lives,loaded_camera:_g.camera_y,loaded_altitude:global.last_save_altitude,
        block_restored:_saved_block!=noone,cleared:_cleared,saved_exists:_saved_exists,
        load_exists:_load_exists,after_load_exists:_after_load_exists,
        read_handle:_read_handle,read_len:_read_len}));file_text_close(_file);game_end();
}
