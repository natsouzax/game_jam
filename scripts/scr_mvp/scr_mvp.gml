#macro DASH_CHARGE_FRAMES 45
#macro DASH_THRUST 40
#macro DASH_THRUST_DECAY 1.0
#macro DOUBLE_JUMP_CHARGE_FRAMES 24
#macro P2_MAGNET_SCALE 3
#macro ENEMY_ACTIVE_CAP 2
#macro STAR_STUN_FRAMES 60

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
    jump_rising = false; jump_hold_frames = 0; jump_key_held=false; jump_double_used=false; double_jump_flash=0;stun_timer=0;aim_x=0;aim_y=0;
    dash_kills = 0; dash_kill_flash = 0; dash_collects = 0; dash_collect_flash = 0; build_cooldown=0;build_flash=0;build_flash_x=x;build_flash_y=y;
}
// Floor sits 128 px above the bottom of the room, so a taller room is more climb.
function scr_floor_y() {
    return room_height - 128;
}
// Compatibility helper for scripted waves. Ducks and bats are no longer spawned.
function scr_enemy_spawn(_level) {
    var _d=clamp((_level-1)/4,0,1);
    var _kind=(_d<0.50?2:(_d<0.78?3:4));
    var _home_y=clamp(1408-(_level-1)*192-120,96,room_height-96);
    return scr_enemy_make(obj_enemy,room_width/2,_home_y,_kind,_d);
}
function scr_enemy_altitude() {
    var _g=instance_find(obj_game,0);
    return (_g!=noone ? clamp(_g.altitude,0,1) : 0);
}
function scr_enemy_apply_difficulty(_e,_difficulty) {
    var _d=clamp(_difficulty,0,1);
    _e.difficulty=_d;
    if(_e.object_index==obj_enemy) {
        _e.hp=1+floor(_d*2);
        _e.patrol_speed*=1+_d*0.8;
        _e.hit_radius+=round(_d*6);
    } else if(_e.object_index==obj_enemy_flying) {
        _e.hp=1+floor(_d*2);
        _e.speed_scale=1+_d*0.7;
        _e.attack_timer=round(_e.attack_timer/_e.speed_scale);
        _e.attack_duration=round(lerp(120,78,_d));
    } else if(_e.object_index==obj_demon) {
        _e.hp=2+floor(_d*2);
        _e.speed_scale=1+_d*0.5;
        _e.attack_timer=round(_e.attack_timer/_e.speed_scale);
        _e.attack_duration=round(lerp(90,62,_d));
    }
}
function scr_enemy_make(_object,_x,_y,_kind,_difficulty) {
    var _e=instance_create_layer(_x,_y,"Instances_1",_object);
    if(_object==obj_enemy) {
        _e.kind=_kind;_e.home_x=_x;_e.home_y=_y;_e.phase=random(10);_e.fall_t=0;
        switch(_kind) {
            case 0:
                _e.walk_dir=(irandom(1)==0?-1:1);_e.patrol_speed=1.4;_e.hit_radius=28;
                break;
            case 1:
                _e.patrol_speed=0.050;_e.orbit_reach=irandom_range(240,520);_e.bob_amount=30;_e.hit_radius=31;
                break;
            case 2:
                _e.walk_dir=(irandom(1)==0?-1:1);_e.patrol_speed=1.25;_e.bob_amount=7;_e.hit_radius=34;
                break;
            case 3:
                _e.walk_dir=(irandom(1)==0?-1:1);_e.patrol_speed=1.0;_e.fall_range=100;_e.hit_radius=28;
                _e.star_landed=false;_e.star_fall_speed=0;
                break;
            case 4:
                _e.walk_dir=(irandom(1)==0?-1:1);_e.patrol_speed=1.2;_e.fall_range=90;_e.hit_radius=32;
                break;
        }
    }
    scr_enemy_apply_difficulty(_e,_difficulty);
    return _e;
}
function scr_enemy_wave_size(_altitude) {
    var _d=clamp(_altitude,0,1);
    // Quiet opening, a two-enemy stretch, then breathing room for the climb/finale.
    if(_d>=0.24 && _d<0.52) return 2;
    return 1;
}
function scr_resource_drop_interval(_altitude) {
    var _d=clamp(_altitude,0,1);
    return round(lerp(42,18,_d));
}
function scr_resource_drop_cap(_altitude) {
    return 8+floor(clamp(_altitude,0,1)*8);
}
function scr_resource_fall_gravity(_altitude) {
    return lerp(0.12,0.20,clamp(_altitude,0,1));
}
function scr_resource_fall_max(_altitude) {
    return lerp(7,10,clamp(_altitude,0,1));
}
function scr_enemy_notify_death(_object,_kind,_home_x,_home_y) {
    if(global.qa) return;
    if(_object==obj_demon) return;
    var _g=instance_find(obj_game,0);
    if(_g==noone || array_length(_g.enemy_respawn_queue)>=ENEMY_ACTIVE_CAP) return;
    var _d=scr_enemy_altitude();
    array_push(_g.enemy_respawn_queue,{obj_index:_object,kind:_kind,home_x:_home_x,home_y:_home_y,
        timer:round(lerp(420,240,_d))+irandom_range(0,60)});
}
function scr_enemy_spawn_extra(_difficulty) {
    var _d=clamp(_difficulty,0,1);
    var _cam_top=camera_get_view_y(view_camera[0]);
    var _cam_bottom=_cam_top+camera_get_view_height(view_camera[0]);
    var _object=obj_enemy;
    var _kind=2;
    var _roll=random(1);
    if(_d<0.35) _kind=2;
    else if(_d<0.72) _kind=(_roll<0.72?2:3);
    else _kind=(_roll<0.45?2:(_roll<0.78?3:4));
    var _x=0;var _y=0;var _clear=false;
    for(var _try=0;_try<10;_try++) {
        _x=irandom_range(90,room_width-90);
        _y=irandom_range(floor(max(96,_cam_top+120)),ceil(min(room_height-96,_cam_bottom-120)));
        _clear=true;
        for(var _pi=0;_pi<2;_pi++) {
            var _p=instance_find((_pi==0?obj_player_p1:obj_player_p2),0);
            if(_p!=noone && _p.active_player && !_p.dead && point_distance(_x,_y,_p.x,_p.y-35)<160) _clear=false;
        }
        if(scr_world_aabb_solid(_x-24,_y-24,_x+24,_y+24)) _clear=false;
        if(_clear) break;
    }
    if(!_clear) return;
    scr_enemy_make(_object,_x,_y,_kind,_d);
}
function scr_enemy_director() {
    var _g=instance_find(obj_game,0);
    if(_g==noone) return;
    var _d=scr_enemy_altitude();
    var _count=instance_number(obj_enemy)+instance_number(obj_enemy_flying)+instance_number(obj_demon);
    var _queued=array_length(_g.enemy_respawn_queue);
    // A dead enemy waits until the rest of its current wave is gone.
    if(_queued>0) {
        if(_count>0) return;
        var _entry=_g.enemy_respawn_queue[0];
        _entry.timer--;
        if(_entry.timer<=0) {
            array_delete(_g.enemy_respawn_queue,0,1);
            scr_enemy_make(_entry.obj_index,clamp(_entry.home_x,90,room_width-90),
                clamp(_entry.home_y,96,room_height-96),_entry.kind,_d);
            _g.enemy_spawn_timer=round(lerp(420,240,_d));
        }
        return;
    }
    var _target=min(ENEMY_ACTIVE_CAP,scr_enemy_wave_size(_d));
    if(_count>=_target || _count>=ENEMY_ACTIVE_CAP) return;
    _g.enemy_spawn_timer--;
    if(_g.enemy_spawn_timer<=0) {
        _g.enemy_spawn_timer=round(lerp(360,210,_d))+irandom_range(0,45);
        scr_enemy_spawn_extra(_d);
    }
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
    if (scr_world_aabb_solid(_tx - body_half_width, _ty - body_height, _tx + body_half_width, _ty, true)) return true;
    if (_ty >= scr_floor_y() && _tx > 540 - body_half_width && _tx < 826 + body_half_width) return true;
    return false;
}
function scr_find_unobstructed_spawn(_pref_x, _pref_y, _cam_top, _cam_bottom) {
    var _min_y = _cam_top + body_height + 4;
    var _max_y = _cam_bottom - 4;
    var _cx = clamp(_pref_x, 32, room_width - 32);
    var _cy = clamp(_pref_y, _min_y, _max_y);
    if (!scr_is_spawn_obstructed(_cx, _cy)) return [_cx, _cy];
    for (var _up = 1; _up <= 8; _up++) {
        var _uy = _cy - _up * 64;
        if (_uy < _min_y) break;
        if (!scr_is_spawn_obstructed(_cx, _uy) && scr_world_aabb_solid(_cx - body_half_width, _uy, _cx + body_half_width, _uy + 4)) {
            return [_cx, _uy];
        }
    }
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
function scr_get_build_target(_move=0,_vertical=0,_aim_x=0,_aim_y=0) {
    var _cell_x=floor(x/64)*64;
    var _under_y=ceil(y/64)*64;
    var _aim_dx=(abs(_aim_x)>0.5?sign(_aim_x)*max(1,round(abs(_aim_x)*2)):0);
    var _aim_dy=(abs(_aim_y)>0.5?sign(_aim_y)*max(1,round(abs(_aim_y)*2)):0);
    var _bx=_cell_x+_aim_dx*64;
    var _by=_under_y+_aim_dy*64;
    if(grounded) {
        // On solid ground the cell below is occupied: use the adjacent step as the neutral target.
        var _ground_row=floor((y+4)/64)*64-64;
        if(_aim_dx==0 && _aim_dy==0) _bx=_cell_x+facing*64;
        else if(_aim_dx==0) _bx=_cell_x+facing*64;
        _by=_ground_row+_aim_dy*64;
    }
    var _other=instance_find((player_number==0?obj_player_p2:obj_player_p1),0);
    var _within=(abs((_bx+32)-x)<=160 && abs((_by+32)-(y-32))<=160);
    var _occupied=scr_world_block_at(_bx,_by);
    if(_occupied!=noone) {
        return {bx:_bx,by:_by,valid:false,supported:(!_occupied.is_checkpoint && _occupied.builder_number>=0),within_range:_within};
    }
    var _self=(x+14>_bx && x-14<_bx+64 && y>_by+2 && y-body_height<_by+62);
    var _partner=(_other!=noone && _other.active_player && _other.x+16>_bx && _other.x-16<_bx+64 && _other.y>_by && _other.y-70<_by+64);
    var _free=!scr_world_aabb_solid(_bx+2,_by+2,_bx+62,_by+62);
    var _attached=scr_world_build_is_attached(_bx,_by);
    var _in_bounds=(_bx>=64 && _bx+64<=room_width-64 && _by>=64 && _by+64<=room_height);
    var _valid=(_in_bounds && _within && _free && !_self && !_partner && _attached);
    return {bx:_bx,by:_by,valid:_valid,supported:_attached,within_range:_within};
}
function scr_player_recover(_clear_section=false) {
    var _stock_before=material_count;
    var _reset=(_clear_section?scr_reset_section_blocks(checkpoint_level):{removed:0,scope_ok:true});
    reset_blocks_total+=_reset.removed; section_resets++;
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
    jump_rising=false; jump_hold_frames=0; jump_key_held=false; jump_double_used=false; double_jump_flash=0;stun_timer=0;
    dash_kill_flash=0; dash_collect_flash=0;build_cooldown=0;build_flash=0;
    invulnerable=100; recoveries++; qa_target=noone; last_support=noone;
    recovery_valid=recovery_valid && material_count==_stock_before && _reset.scope_ok;
}
function scr_player_die(_stun_frames=0) {
    if (!active_player || dead) return;
    player_lives--;
    if (player_lives > 0) {
        if(_stun_frames>0) {
            stun_timer=max(stun_timer,_stun_frames);
            invulnerable=max(invulnerable,_stun_frames+20);
            vy=0;charge=0;_hthrust=0;_jump_was_held=false;_charge_dir=0;jump_held=false;
            jump_rising=false;jump_hold_frames=0;jump_key_held=false;jump_double_used=false;double_jump_flash=0;
            return;
        }
        scr_player_recover();
        invulnerable = 120;
    } else {
        player_lives=0;
        var _partner=instance_find((player_number==0?obj_player_p2:obj_player_p1),0);
        if(global.player_count==2 && _partner!=noone && _partner.active_player && !_partner.dead && _partner.player_lives>0) {
            // The downed teammate waits at the checkpoint for an extra heart.
            scr_player_recover();
            dead=true;invulnerable=0;respawn_timer=-1;
        } else {
            // Blocks are only lost upon actual death (lives == 0), capped at 10 random blocks.
            var _reset=scr_remove_random_blocks(10);
            reset_blocks_total+=_reset.removed;
            section_resets++;
            recovery_valid=recovery_valid && _reset.scope_ok;
            scr_begin_gameover();
        }
    }
}
function scr_player_gain_life(_p) {
    if(_p==noone || !_p.active_player || _p.dead) return false;
    if(_p.player_lives<3) {
        _p.player_lives++;
        return true;
    }
    var _partner=instance_find((_p.player_number==0?obj_player_p2:obj_player_p1),0);
    if(global.player_count==2 && _partner!=noone && _partner.active_player && _partner.dead) {
        _partner.player_lives=1;_partner.dead=false;
        with(_partner)scr_player_recover(false);
        return true;
    }
    return false;
}
// Full-dash signature move: cyan cuts down enemies in front, amber sweeps resources like a magnet.
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
                    var _reward=(_obj==obj_enemy && _e.kind==3?4:1);
                    instance_destroy(_e);_kills++;material_count+=_reward;
                }
            }
        }
        if (_kills>0) {
            dash_kills+=_kills;dash_kill_flash=12;
            scr_sfx(sfx_hit,0.05,1);
        }
    } else {
        // Tall magnet column: grabs everything above and below the dash line.
        var _mcx=(_left+_right)*0.5;
        var _mcy=y-body_height*0.5-3;
        var _mhalf_width=(_right-_left)*0.5+44;
        var _mhalf_height=(body_height+86)*0.5;
        var _mleft=_mcx-_mhalf_width*P2_MAGNET_SCALE;
        var _mright=_mcx+_mhalf_width*P2_MAGNET_SCALE;
        var _mtop=_mcy-_mhalf_height*P2_MAGNET_SCALE;
        var _mbottom=_mcy+_mhalf_height*P2_MAGNET_SCALE;
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
function scr_player_tick(_move, _jump, _build, _jump_held=false, _jump_key_held=false, _break=false) {
    if (!active_player || global.game_state != "play") return;
    if(stun_timer>0) {
        stun_timer--;
        if(invulnerable>0)invulnerable--;
        last_move=0;
        return;
    }
    build_cooldown=max(0,build_cooldown-1);
    build_flash=max(0,build_flash-1);
    double_jump_flash=max(0,double_jump_flash-1);
    jump_key_held=_jump_key_held;
    last_move=_move;
    if (invulnerable > 0) invulnerable--;
    if (dash_kill_flash>0) dash_kill_flash--;
    if (dash_collect_flash>0) dash_collect_flash--;
    if (_move != 0) facing=sign(_move);
    grounded=scr_world_aabb_solid(x-body_half_width,y,x+body_half_width,y+1);
    // A tap is a normal jump; a full airborne meter triggers a separate second jump.
    var _charging=_jump_held && grounded && !_jump;
    var _release=_jump_was_held && !_jump_held && grounded;
    jump_held=_charging;
    if (_charging) {
        charge=min(charge+1,DASH_CHARGE_FRAMES);
        if (_move!=0) _charge_dir=sign(_move);
    }
    if (_jump && grounded) {
        vy=jump_speed;charge=0;_hthrust=0;_charge_dir=0;
        jump_rising=true;jump_hold_frames=0;jump_double_used=false;
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
        if (!_jump && jump_rising && !jump_double_used && _hthrust<=0) {
            if (_jump_key_held) {
                jump_hold_frames++;
                if(jump_hold_frames>=DOUBLE_JUMP_CHARGE_FRAMES) {
                    vy=jump_speed;
                    jump_rising=false;
                    jump_hold_frames=0;
                    jump_double_used=true;
                    double_jump_flash=12;
                    scr_sfx(sfx_jump,0.04);
                }
            } else {
                jump_rising=false;
                jump_hold_frames=0;
            }
        }
    } else if (!_jump) {
        jump_rising=false;
        jump_hold_frames=0;
        jump_double_used=false;
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
    if ((_build || _break) && build_cooldown<=0) {
        build_cooldown=10;
        var _target=scr_get_build_target(_move,sign(vy),aim_x,aim_y);
        var _bx=_target.bx;var _by=_target.by;
        var _old_block=scr_world_block_at(_bx,_by);
        if(_break && _old_block!=noone) {
            if(!_old_block.is_checkpoint && _old_block.builder_number>=0) {
                if(_old_block.crack_until>=global.game_timer) {
                    material_count++;
                    instance_destroy(_old_block);
                    scr_sfx(sfx_block,0.05);
                } else _old_block.crack_until=global.game_timer+30;
            }
        } else if(_build && _old_block==noone && material_count>0 && _target.valid) {
            var _new_block=instance_create_layer(_bx,_by,"Instances_1",obj_build_block);
            _new_block.builder_number=player_number;
            build_flash=8;build_flash_x=_bx;build_flash_y=_by;
            material_count--;built_total++;scr_sfx(sfx_block,0.05);
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
    if(!active_player || dead || (global.game_state!="play" && global.game_state!="ending" && global.game_state!="pause"))return;
    if (invulnerable > 0 && stun_timer<=0 && (invulnerable div 5) mod 2 == 0 && global.game_state != "pause") return;
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
        draw_set_alpha(0.08+0.07*_ma);
        draw_set_color(_accent);
        draw_circle(x,y-35,(66+8*_mp)*P2_MAGNET_SCALE,true);
        draw_circle(x,y-35,(92+12*_mp)*P2_MAGNET_SCALE,true);
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
    if ((!grounded && jump_rising && jump_key_held && !jump_double_used) || double_jump_flash>0) {
        var _double_full=(double_jump_flash>0);
        var _double_fill=(_double_full?1:clamp(jump_hold_frames/DOUBLE_JUMP_CHARGE_FRAMES,0,1));
        var _jbw=124;var _jbh=18;var _jbx=x-_jbw/2;var _jby=y-138;
        var _jpulse=0.5+0.5*sin(global.game_timer/4);
        if(_double_full)scr_cut_glow(x,_jby+_jbh/2,52+8*_jpulse,make_color_rgb(255,224,140),0.36+0.2*_jpulse);
        draw_set_color(make_color_rgb(8,14,20));
        draw_roundrect_ext(_jbx+3,_jby+4,_jbx+_jbw+3,_jby+_jbh+4,8,8,false);
        draw_set_color(_double_full?make_color_rgb(255,224,140):make_color_rgb(58,72,80));
        draw_roundrect_ext(_jbx,_jby,_jbx+_jbw,_jby+_jbh,8,8,false);
        draw_sprite_ext(spr_jump_charge,0,_jbx+2,_jby+2,(_jbw-4)/120,(_jbh-4)/16,0,c_white,1);
        var _jfw=(_jbw-8)*_double_fill;
        if(_jfw>0) {
            draw_set_color(_accent);draw_rectangle(_jbx+4,_jby+4,_jbx+4+_jfw,_jby+_jbh-4,false);
            draw_set_color(merge_colour(_accent,c_white,0.4));
            draw_rectangle(_jbx+4,_jby+4,_jbx+4+_jfw,_jby+_jbh-10,false);
        }
        draw_set_color(make_color_rgb(10,16,22));
        for(var _st=1;_st<4;_st++) {
            var _jtx=_jbx+4+(_jbw-8)*_st/4;
            draw_rectangle(_jtx,_jby+4,_jtx+1,_jby+_jbh-4,false);
        }
        if(_double_full) {
            draw_set_color(make_color_rgb(255,250,218));
            draw_triangle(_jbx+_jbw-9,_jby+_jbh/2,_jbx+_jbw-17,_jby+5,_jbx+_jbw-17,_jby+_jbh-5,false);
        }
        draw_set_color(c_white);
    }
    if (global.game_state == "play") {
        var _preview = scr_get_build_target(last_move,sign(vy),aim_x,aim_y);
        var _px = _preview.bx;
        var _py = _preview.by;
        var _pcol = (player_number==0 ? make_color_rgb(80,220,215) : make_color_rgb(247,181,77));
        var _can_place = (_preview.valid && material_count > 0);
        var _preview_color=(_can_place? _pcol:make_color_rgb(215,85,85));
        draw_set_alpha(_can_place ? 0.22 : 0.10);
        draw_set_color(_preview_color);draw_rectangle(_px+3,_py+3,_px+60,_py+60,false);
        draw_set_alpha(_can_place ? 0.9 : 0.55);
        draw_set_color(_preview_color);
        draw_rectangle(_px,_py,_px+63,_py+63,true);
        draw_rectangle(_px+3,_py+3,_px+60,_py+60,true);
        var _tick=12;
        draw_line_width(_px,_py+_tick,_px,_py,3);draw_line_width(_px,_py,_px+_tick,_py,3);
        draw_line_width(_px+64-_tick,_py,_px+64,_py,3);draw_line_width(_px+64,_py,_px+64,_py+_tick,3);
        draw_line_width(_px,_py+64-_tick,_px,_py+64,3);draw_line_width(_px,_py+64,_px+_tick,_py+64,3);
        draw_line_width(_px+64-_tick,_py+64,_px+64,_py+64,3);draw_line_width(_px+64,_py+64-_tick,_px+64,_py+64,3);
        draw_set_alpha(1);
    }
    if(build_flash>0) {
        draw_set_alpha(build_flash/10);
        draw_set_color(_index==0?make_color_rgb(80,220,215):make_color_rgb(247,181,77));
        draw_rectangle(build_flash_x+2,build_flash_y+2,build_flash_x+62,build_flash_y+62,true);
        draw_set_alpha(1);
    }
    for(var _j=0;_j<min(material_count,8);_j++) {
        var _ix=x+(_j-(min(material_count,8)-1)/2)*9;
        draw_triangle(_ix,y-107,_ix-3,y-103,_ix+3,y-103,false);
        draw_triangle(_ix,y-99,_ix-3,y-103,_ix+3,y-103,false);
    }
    draw_set_color(c_white);
}
