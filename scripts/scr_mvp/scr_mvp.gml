#macro DASH_CHARGE_FRAMES 45
#macro DASH_THRUST 40
#macro DASH_THRUST_DECAY 1.0
#macro JUMP_HOLD_MAX_FRAMES 20
#macro JUMP_HOLD_BOOST 0.28

function scr_player_init(_index) {
    player_number = _index; active_player=true; body_half_width = 16; body_height = 70;
    move_speed = 4; jump_speed = -11; gravity_speed = 0.48;
    x = (_index==0 ? 270 : 1096); y = scr_floor_y(); vy = 0; facing = (_index == 0 ? 1 : -1);
    material_count = 0; collected_total = 0; built_total = 0; recoveries = 0;
    respawn_x = x; respawn_y = y; grounded = true; invulnerable = 0;
    enemy_hits=0;fall_hits=0;last_move=0;shared_uses=0;last_support=noone;recovery_valid=true;reset_blocks_total=0;section_resets=0;
    checkpoint_level = 0; depth = -10; qa_jump_cooldown = 0; qa_target=noone;
    player_lives = 3; dead = false; respawn_timer = 0;
    charge = 0; _hthrust = 0; _hdir = 1; _jump_was_held = false; _charge_dir = 0; jump_held = false; _hjump_cooldown = 0;
    jump_rising = false; jump_hold_frames = 0;
    dash_kills = 0; dash_kill_flash = 0; dash_collects = 0; dash_collect_flash = 0;
}
// Floor sits 128 px above the bottom of the room, so a taller room is more climb.
function scr_floor_y() {
    return room_height - 128;
}
// One distinct hazard per phase (1..5): duck, bat, patrol robot, star, falling metal.
function scr_enemy_spawn(_level) {
    var _home_y=1408-(_level-1)*192-120;
    var _e=instance_create_layer(672,_home_y,"Instances_1",obj_enemy);
    _e.kind=_level-1;
    _e.level_id=_level;
    _e.home_x=672;_e.home_y=_home_y;
    _e.phase=_level*0.9;
    switch(_e.kind) {
        case 0:
            _e.x=180;_e.home_x=180;_e.home_y=1374;
            _e.walk_dir=1;_e.patrol_speed=1.4;_e.hit_radius=28;
            break;
        case 1:
            _e.home_x=room_width/2;_e.patrol_speed=0.050;_e.orbit_reach=570;_e.bob_amount=30;_e.hit_radius=31;
            break;
        case 2:
            _e.home_x=room_width/2;_e.patrol_speed=0.056;_e.orbit_reach=560;_e.bob_amount=16;_e.hit_radius=34;
            break;
        case 3:
            _e.home_y=705;_e.patrol_speed=0.014;_e.fall_range=100;_e.hit_radius=28;
            break;
        case 4:
            _e.home_y=510;_e.patrol_speed=0.020;_e.fall_range=90;_e.hit_radius=32;
            break;
    }
    return _e;
}
// Section 0 is ground-to-first-checkpoint; each next section is 192 px high.
function scr_tower_section_at_y(_top) {
    return max(0, floor((scr_floor_y() - _top - 1) / 192));
}
function scr_reset_section_blocks(_section) {
    var _remove=[];
    var _keep=[];
    for(var _i=0;_i<instance_number(obj_build_block);_i++) {
        var _block=instance_find(obj_build_block,_i);
        if(!_block.is_checkpoint && _block.section_id==_section) array_push(_remove,_block);
        else array_push(_keep,_block);
    }
    for(var _j=0;_j<array_length(_remove);_j++) instance_destroy(_remove[_j]);
    var _valid=true;
    for(var _k=0;_k<array_length(_keep);_k++) _valid=_valid && instance_exists(_keep[_k]);
    for(var _n=0;_n<array_length(_remove);_n++) _valid=_valid && !instance_exists(_remove[_n]);
    return {removed:array_length(_remove),scope_ok:_valid};
}
function scr_remove_random_blocks(_max_remove=10) {
    var _candidates=[];
    for(var _i=0;_i<instance_number(obj_build_block);_i++) {
        var _block=instance_find(obj_build_block,_i);
        if(_block!=noone && !_block.is_checkpoint) array_push(_candidates,_block);
    }
    var _to_remove=min(array_length(_candidates),_max_remove);
    var _removed=[];
    for(var _r=0;_r<_to_remove;_r++) {
        var _idx=irandom(array_length(_candidates)-1);
        var _target=_candidates[_idx];
        array_delete(_candidates,_idx,1);
        array_push(_removed,_target);
    }
    for(var _j=0;_j<array_length(_removed);_j++) {
        if(instance_exists(_removed[_j])) instance_destroy(_removed[_j]);
    }
    var _valid=true;
    for(var _k=0;_k<array_length(_candidates);_k++) _valid=_valid && instance_exists(_candidates[_k]);
    for(var _n=0;_n<array_length(_removed);_n++) _valid=_valid && !instance_exists(_removed[_n]);
    return {removed:array_length(_removed),scope_ok:_valid};
}
function scr_is_spawn_obstructed(_tx, _ty) {
    if (_tx < 32 || _tx > room_width - 32) return true;
    // Check if the player's body AABB overlaps any solid block (including constructed blocks).
    if (scr_world_aabb_solid(_tx - body_half_width, _ty - body_height, _tx + body_half_width, _ty, true)) return true;
    // Also avoid spawning directly over the central void when at or below floor level.
    if (_ty >= scr_floor_y() && _tx > 540 - body_half_width && _tx < 826 + body_half_width) return true;
    return false;
}
function scr_find_unobstructed_spawn(_pref_x, _pref_y, _cam_top, _cam_bottom) {
    var _min_y = _cam_top + body_height + 4;
    var _max_y = _cam_bottom - 4;
    var _cx = clamp(_pref_x, 32, room_width - 32);
    var _cy = clamp(_pref_y, _min_y, _max_y);
    if (!scr_is_spawn_obstructed(_cx, _cy)) return [_cx, _cy];
    // 1. Try stepping upward above any stacked blocks at the same X column.
    for (var _up = 1; _up <= 8; _up++) {
        var _uy = _cy - _up * 64;
        if (_uy < _min_y) break;
        if (!scr_is_spawn_obstructed(_cx, _uy) && scr_world_aabb_solid(_cx - body_half_width, _uy, _cx + body_half_width, _uy + 4)) {
            return [_cx, _uy];
        }
    }
    // 2. Search outward horizontally and across vertical offsets for a supported, unobstructed spot.
    for (var _dx_step = 1; _dx_step <= 20; _dx_step++) {
        for (var _side = -1; _side <= 1; _side += 2) {
            var _tx = _cx + _side * _dx_step * 32;
            if (_tx < 32 || _tx > room_width - 32) continue;
            for (var _dy_step = 0; _dy_step <= 6; _dy_step++) {
                var _ty = clamp(_cy - _dy_step * 64, _min_y, _max_y);
                if (!scr_is_spawn_obstructed(_tx, _ty) && scr_world_aabb_solid(_tx - body_half_width, _ty, _tx + body_half_width, _ty + 4)) {
                    return [_tx, _ty];
                }
            }
        }
    }
    // 3. Fallback: any unobstructed position inside the camera view.
    for (var _fx_step = 0; _fx_step <= 20; _fx_step++) {
        for (var _fside = -1; _fside <= 1; _fside += 2) {
            var _ftx = clamp(_cx + _fside * _fx_step * 32, 32, room_width - 32);
            for (var _fdy = 0; _fdy <= 8; _fdy++) {
                var _fty = clamp(_cy - _fdy * 48, _min_y, _max_y);
                if (!scr_is_spawn_obstructed(_ftx, _fty)) return [_ftx, _fty];
            }
        }
    }
    return [_cx, _cy];
}
function scr_player_recover() {
    var _stock_before=material_count;
    // Taking non-lethal damage does not remove or alter any constructed blocks.
    var _cam_top=camera_get_view_y(view_camera[0]);
    var _cam_bottom=_cam_top+camera_get_view_height(view_camera[0]);
    x=respawn_x; y=respawn_y;
    if (y-body_height>_cam_bottom || y<_cam_top) {
        var _partner=instance_find((player_number==0?obj_player_p2:obj_player_p1),0);
        if (_partner!=noone && _partner.active_player) {
            x=_partner.x; y=_partner.y;
        } else {
            x=clamp(respawn_x,32,room_width-32);
            y=_cam_bottom-96;
        }
    }
    x=clamp(x,32,room_width-32);
    y=clamp(y,_cam_top+body_height+4,_cam_bottom-4);
    if (scr_is_spawn_obstructed(x, y)) {
        var _safe_spawn=scr_find_unobstructed_spawn(x, y, _cam_top, _cam_bottom);
        x=_safe_spawn[0]; y=_safe_spawn[1];
        respawn_x=x; respawn_y=y;
    }
    vy=0; grounded=scr_world_aabb_solid(x-body_half_width,y,x+body_half_width,y+1);
    charge=0; _hthrust=0; _jump_was_held=false; _charge_dir=0; jump_held=false; _hjump_cooldown=0;
    jump_rising=false; jump_hold_frames=0;
    dash_kill_flash=0; dash_collect_flash=0;
    invulnerable=100; recoveries++; qa_target=noone; last_support=noone;
    recovery_valid=recovery_valid && material_count==_stock_before;
}
function scr_player_die() {
    if (!active_player) return;
    player_lives--;
    if (player_lives > 0) {
        scr_player_recover();
        invulnerable = 120;
    } else {
        // Blocks are only lost upon actual death (lives == 0), capped at 10 random blocks.
        var _reset = scr_remove_random_blocks(10);
        reset_blocks_total += _reset.removed;
        section_resets++;
        recovery_valid = recovery_valid && _reset.scope_ok;
        // A defeated teammate ends the attempt for the pair and for solo.
        scr_begin_gameover();
    }
}
// Computes the exact grid cell {bx, by, valid} for block placement and preview.
// - On ground: places in front of the player (if the cell below/in front is empty and supported,
//   or at the player's level / 1 block above, within 2 blocks horizontally and vertically).
// - Airborne (jumping): places underneath the player on top of the highest supported surface within 2 blocks.
// - Requires solid support directly underneath (no floating blocks).
function scr_get_build_target() {
    var _cur_col=floor(x/64)*64;
    var _foot_row=floor((y+4)/64)*64;
    var _other_player=instance_find((player_number==0?obj_player_p2:obj_player_p1),0);
    var _bx=_cur_col;
    var _by=_foot_row-64;
    if (grounded) {
        // Check 1 block in front first, then 2 blocks in front (max 2 blocks horizontal range).
        var _found=false;
        for (var _step_x=1;_step_x<=2;_step_x++) {
            var _cand_x=_cur_col+facing*_step_x*64;
            if (_cand_x<64 || _cand_x+64>room_width-64) continue;
            // Check from 1 block below the feet level (_foot_row, i.e. ground below and in front)
            // up to 2 blocks above (_foot_row-128).
            var _candidate_rows=[_foot_row+64,_foot_row,_foot_row-64,_foot_row-128];
            for (var _ri=0;_ri<array_length(_candidate_rows);_ri++) {
                var _cand_y=_candidate_rows[_ri];
                if (_cand_y<64 || _cand_y+64>room_height) continue;
                if (abs((_cand_y+32)-(y-32))>128) continue;
                var _empty=!scr_world_aabb_solid(_cand_x+2,_cand_y+2,_cand_x+62,_cand_y+62);
                var _sup=scr_world_aabb_solid(_cand_x+4,_cand_y+64,_cand_x+60,_cand_y+66);
                if (_empty && _sup) {
                    _bx=_cand_x; _by=_cand_y; _found=true; break;
                }
            }
            if (_found) break;
        }
        if (!_found) {
            _bx=clamp(_cur_col+facing*64,64,room_width-128);
            _by=clamp(_foot_row-64,64,room_height-64);
        }
    } else {
        // Jumping: only place underneath the character, within 2 blocks (128px) downward.
        _bx=clamp(_cur_col,64,room_width-128);
        var _start_row=ceil((y-2)/64)*64;
        _by=clamp(_start_row,64,room_height-64);
        for (var _drop=0;_drop<=2;_drop++) {
            var _cand_y=_start_row+_drop*64;
            if (_cand_y<64 || _cand_y+64>room_height) continue;
            if (abs((_cand_y+32)-(y-32))>128) continue;
            var _empty=!scr_world_aabb_solid(_bx+2,_cand_y+2,_bx+62,_cand_y+62);
            var _sup=scr_world_aabb_solid(_bx+4,_cand_y+64,_bx+60,_cand_y+66);
            if (_empty && _sup) {
                _by=_cand_y; break;
            }
        }
    }
    var _supported=scr_world_aabb_solid(_bx+4,_by+64,_bx+60,_by+66);
    var _within_range=(abs((_bx+32)-x)<=128+32 && abs((_by+32)-(y-32))<=128);
    var _occupied_self=(x+14>_bx && x-14<_bx+64 && y>_by+2 && y-body_height<_by+62);
    var _occupied_partner=(_other_player!=noone && _other_player.active_player && _other_player.x+16>_bx && _other_player.x-16<_bx+64 && _other_player.y>_by && _other_player.y-70<_by+64);
    var _free=!scr_world_aabb_solid(_bx+2,_by+2,_bx+62,_by+62);
    var _valid=(_bx>=64 && _bx+64<=room_width-64 && _by>=64 && _by+64<=room_height && _supported && _within_range && _free && !_occupied_self && !_occupied_partner);
    return {bx:_bx,by:_by,valid:_valid,supported:_supported,within_range:_within_range};
}
function scr_player_dash_ability(_from_x) {
    if (_hthrust<=0) return;
    var _left=min(_from_x,x)-body_half_width-6;
    var _right=max(_from_x,x)+body_half_width+6;
    if (player_number==0) {
        var _reach=26;
        if (_hdir>0) _right+=_reach; else _left-=_reach;
        var _top=y-body_height-8;var _bottom=y+8;
        var _kills=0;
        var _enemy_types=[obj_enemy,obj_enemy_flying,obj_slime,obj_skeleton,obj_devil,obj_meteor_enemy,obj_meteor];
        for (var _kind=0;_kind<array_length(_enemy_types);_kind++) {
            var _obj=_enemy_types[_kind];
            for (var _i=instance_number(_obj)-1;_i>=0;_i--) {
                var _e=instance_find(_obj,_i);
                if (_e!=noone && _e.x>_left && _e.x<_right && _e.y>_top && _e.y<_bottom) {
                    instance_destroy(_e);_kills++;
                }
            }
        }
        if (_kills>0) {
            dash_kills+=_kills;dash_kill_flash=12;
            scr_sfx(sfx_hit,0.05,1);
        }
    } else {
        // Tall magnet column: grabs everything above and below the dash line.
        var _mleft=_left-44;var _mright=_right+44;
        var _mtop=y-body_height-46;var _mbottom=y+40;
        var _grabbed=0;
        for (var _mi=instance_number(obj_material)-1;_mi>=0;_mi--) {
            var _m=instance_find(obj_material,_mi);
            if (_m!=noone && _m.x>_mleft && _m.x<_mright && _m.y>_mtop && _m.y<_mbottom) {
                material_count++;collected_total++;instance_destroy(_m);_grabbed++;
            }
        }
        if (_grabbed>0) {
            dash_collects+=_grabbed;dash_collect_flash=10;
            scr_sfx(sfx_collect,0.05);
        }
    }
}
function scr_player_tick(_move, _jump, _build, _jump_held=false, _jump_key_held=true) {
    if (!active_player || global.game_state != "play") return;
    last_move=_move;
    if (invulnerable > 0) invulnerable--;
    if (dash_kill_flash>0) dash_kill_flash--;
    if (dash_collect_flash>0) dash_collect_flash--;
    if (_move != 0) facing=sign(_move);
    grounded=scr_world_aabb_solid(x-body_half_width,y,x+body_half_width,y+1);
    // Q / RShift charges only the horizontal dash; W / Up controls variable-height jump.
    var _charging=_jump_held && grounded && !_jump;
    var _release=_jump_was_held && !_jump_held && grounded;
    jump_held=_charging;
    if (_charging) {
        charge=min(charge+1,DASH_CHARGE_FRAMES);
        if (_move!=0) _charge_dir=sign(_move);
    }
    if (_jump && grounded) {
        vy=jump_speed;charge=0;_hthrust=0;_charge_dir=0;
        jump_rising=true;jump_hold_frames=0;
        scr_sfx(sfx_jump,0.04);
    } else if (_release && charge>0) {
        if (charge>=DASH_CHARGE_FRAMES) {
            _hdir=(_charge_dir!=0?_charge_dir:facing);
            _hthrust=DASH_THRUST;vy=-12;facing=_hdir;
            jump_rising=false;jump_hold_frames=0;
            scr_sfx(sfx_jump,0.04);
        }
        charge=0;_charge_dir=0;
    }
    if (!grounded) {
        charge=0;_charge_dir=0;
        if (!_jump && jump_rising && _hthrust<=0) {
            if (vy<0) {
                if (!_jump_key_held) {
                    vy=0;
                    jump_rising=false;
                    jump_hold_frames=0;
                } else if (jump_hold_frames<JUMP_HOLD_MAX_FRAMES) {
                    jump_hold_frames++;
                    vy-=JUMP_HOLD_BOOST;
                }
            } else {
                jump_rising=false;
                jump_hold_frames=0;
            }
        }
    } else if (!_jump) {
        jump_rising=false;
        jump_hold_frames=0;
    }
    _jump_was_held=_charging;
    var _dir=(_hthrust>0?_hdir:sign(_move));
    var _speed=(_charging?0:(_hthrust>0?_hthrust:abs(_move)*move_speed));
    var _x_before=x;
    repeat(round(_speed)) {
        var _nx=x+_dir;
        if(scr_world_aabb_solid(_nx-body_half_width,y-body_height,_nx+body_half_width,y,true))break;
        x=_nx;
    }
    scr_player_dash_ability(_x_before);
    _hthrust=max(0,_hthrust-DASH_THRUST_DECAY);
    x=clamp(x,32,room_width-32);
    vy = min(vy + gravity_speed, 14);
    var _ny = y + vy;
    if (vy > 0) {
        var _land = scr_world_landing_surface(x-body_half_width,x+body_half_width,y,_ny);
        if (_land != noone) {y = _land; vy = 0;}
        else y = _ny;
    } else if (!scr_world_aabb_solid(x-body_half_width,_ny-body_height,x+body_half_width,_ny,true)) y = _ny;
    else vy = 0;
    grounded = scr_world_aabb_solid(x-body_half_width,y,x+body_half_width,y+1);
    var _m = instance_nearest(x,y-35,obj_material);
    if (_m != noone && abs(_m.x-x)<40 && _m.y+18>y-body_height && _m.y-18<y) {
        material_count++; collected_total++; instance_destroy(_m); scr_sfx(sfx_collect, 0.03);
    }
    if (_build && material_count > 0) {
        var _target = scr_get_build_target();
        if (_target.valid) {
            var _new_block=instance_create_layer(_target.bx,_target.by,"Instances_1",obj_build_block);
            _new_block.builder_number=player_number;
            material_count--; built_total++; scr_sfx(sfx_block, 0.05);
        }
    }
    if (grounded) {
        for (var _i=0;_i<instance_number(obj_build_block);_i++) {
            var _s=instance_find(obj_build_block,_i);
            if(abs(y-_s.y)<2 && x>_s.x-12 && x<_s.x+_s.solid_width+12 && _s.builder_number>=0 && _s.builder_number!=player_number && last_support!=_s) {shared_uses++;last_support=_s;}
            if (_s.is_checkpoint && abs(y-_s.y)<2 && x>_s.x+8 && x<_s.x+_s.solid_width-8 && _s.level_id>checkpoint_level) {
                checkpoint_level=_s.level_id; respawn_x=x; respawn_y=_s.y;
                scr_sfx(sfx_checkpoint, 0, 0.9);
            }
        }
    }
    var _cam_bottom=camera_get_view_y(view_camera[0])+camera_get_view_height(view_camera[0]);
    if (y-body_height > _cam_bottom) {fall_hits++;scr_sfx(sfx_fall);scr_player_die();}
}
function scr_player_render(_index) {
    if(!active_player || (global.game_state!="play" && global.game_state!="ending" && global.game_state!="pause"))return;
    if (invulnerable > 0 && (invulnerable div 5) mod 2 == 0 && global.game_state != "pause") return;
    var _frame=0;
    if(jump_held) _frame=0;
    else if(!grounded)_frame=3;
    else if(last_move!=0) {var _cycle=[0,1,0,2];_frame=_cycle[(global.game_timer div 7) mod 4];}
    if(grounded && last_move==0 && !jump_held) scr_menu_idle(_index,x,y,80,facing);
    else scr_actor_pose(_index,_frame,x,y,80,facing);
    var _accent=(_index==0 ? make_color_rgb(80,220,215) : make_color_rgb(247,181,77));
    draw_set_color(_accent);
    draw_triangle(x-6,y-94,x+6,y-94,x,y-87,false);
    if (_hthrust>0) {
        // Speed streaks behind the dash keep the burst readable at a glance.
        var _sa=clamp(_hthrust/DASH_THRUST,0,1);var _sdir=-_hdir;
        draw_set_alpha(0.34*_sa);
        for(var _st=0;_st<3;_st++) {
            var _sy=y-18-_st*20;
            draw_line_width(x+_sdir*20,_sy,x+_sdir*(44+_st*16),_sy,3-_st*0.6);
        }
        draw_set_alpha(1);
    }
    if (player_number==1 && _hthrust>0) {
        // Magnet field: soft rings around the whole body while the dash runs.
        var _ma=clamp(_hthrust/DASH_THRUST,0,1);
        var _mp=0.5+0.5*sin(global.game_timer/4);
        draw_set_alpha(0.16+0.12*_ma);
        draw_set_color(_accent);
        draw_circle(x,y-35,66+8*_mp,true);
        draw_circle(x,y-35,92+12*_mp,true);
        draw_set_alpha(1);
    }
    if (dash_collect_flash>0) {
        var _cf=dash_collect_flash/10;
        scr_cut_glow(x,y-35,54,make_color_rgb(255,214,140),0.5*_cf);
        draw_set_alpha(_cf);
        draw_set_color(make_color_rgb(255,240,200));
        for(var _sp=0;_sp<6;_sp++) {
            var _ang=_sp*60+global.game_timer*7;
            draw_circle(x+lengthdir_x(30+20*(1-_cf),_ang),y-35+lengthdir_y(30+20*(1-_cf),_ang),2,false);
        }
        draw_set_alpha(1);
    }
    if (dash_kill_flash>0) {
        var _kf=dash_kill_flash/12;
        scr_cut_glow(x,y-35,64,make_color_rgb(255,214,140),0.55*_kf);
        draw_set_alpha(_kf);
        draw_set_color(make_color_rgb(255,240,200));
        draw_circle(x,y-35,32+(1-_kf)*44,true);
        draw_set_alpha(1);
    }
    draw_set_color(c_white);
    if (grounded && jump_held && charge > 0) {
        var _c=min(charge,DASH_CHARGE_FRAMES)/DASH_CHARGE_FRAMES;
        var _full=(charge>=DASH_CHARGE_FRAMES);
        var _bw=124;var _bh=18;var _bx=x-_bw/2;var _by=y-138;
        var _pulse=(_full?0.5+0.5*sin(global.game_timer/6):0);
        if(_full)scr_cut_glow(x,_by+_bh/2,52+8*_pulse,make_color_rgb(255,214,140),0.24+0.16*_pulse);
        // Sprite frame + inner panel keep the charge bar in the same language as the HUD.
        var _frame=(_full?merge_colour(make_color_rgb(255,214,140),c_white,_pulse*0.5):make_color_rgb(58,72,80));
        draw_set_color(make_color_rgb(8,14,20));
        draw_roundrect_ext(_bx+3,_by+4,_bx+_bw+3,_by+_bh+4,8,8,false);
        draw_set_color(_frame);
        draw_roundrect_ext(_bx,_by,_bx+_bw,_by+_bh,8,8,false);
        draw_sprite_ext(spr_jump_charge,0,_bx+2,_by+2,(_bw-4)/120,(_bh-4)/16,0,c_white,1);
        var _fw=(_bw-8)*_c;
        if(_fw>0) {
            draw_set_color(_accent);draw_rectangle(_bx+4,_by+4,_bx+4+_fw,_by+_bh-4,false);
            draw_set_color(merge_colour(_accent,c_white,0.4));
            draw_rectangle(_bx+4,_by+4,_bx+4+_fw,_by+_bh-10,false);
        }
        draw_set_color(make_color_rgb(10,16,22));
        for(var _t=1;_t<4;_t++) {
            var _tx=_bx+4+(_bw-8)*_t/4;
            draw_rectangle(_tx,_by+4,_tx+1,_by+_bh-4,false);
        }
        if(_full) {
            draw_set_color(make_color_rgb(255,240,200));
            draw_triangle(_bx+_bw-9,_by+_bh/2,_bx+_bw-17,_by+5,_bx+_bw-17,_by+_bh-5,false);
        }
        draw_set_color(c_white);
    }
    // Placement preview: show where the next block will be placed, in each player's color.
    if (global.game_state == "play") {
        var _preview = scr_get_build_target();
        var _px = _preview.bx;
        var _py = _preview.by;
        var _pcol = (player_number==0 ? make_color_rgb(80,220,215) : make_color_rgb(247,181,77));
        var _can_place = (_preview.valid && material_count > 0);
        draw_set_alpha(_can_place ? 0.32 : 0.14);
        draw_set_color(_preview.valid ? _pcol : make_color_rgb(215,85,85));
        draw_rectangle(_px,_py,_px+63,_py+63,false);
        draw_set_alpha(_can_place ? 0.85 : 0.42);
        draw_set_color(_pcol);
        draw_rectangle(_px,_py,_px+63,_py+63,true);
        draw_rectangle(_px+2,_py+2,_px+61,_py+61,true);
        draw_set_alpha(1);
    }
    for(var _j=0;_j<min(material_count,8);_j++) {
        var _ix=x+(_j-(min(material_count,8)-1)/2)*9;
        draw_triangle(_ix,y-107,_ix-3,y-103,_ix+3,y-103,false);
        draw_triangle(_ix,y-99,_ix-3,y-103,_ix+3,y-103,false);
    }
    draw_set_color(c_white);
}