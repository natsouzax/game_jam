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
function scr_player_recover() {
    var _stock_before=material_count;
    var _reset=scr_reset_section_blocks(checkpoint_level);
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
    vy=0; grounded=scr_world_aabb_solid(x-body_half_width,y,x+body_half_width,y+1);
    charge=0; _hthrust=0; _jump_was_held=false; _charge_dir=0; jump_held=false; _hjump_cooldown=0;
    invulnerable=100; recoveries++; qa_target=noone; last_support=noone;
    recovery_valid=recovery_valid && material_count==_stock_before && _reset.scope_ok;
}
function scr_player_die() {
    if (!active_player) return;
    player_lives--;
    if (player_lives > 0) {
        scr_player_recover();
        invulnerable = 120;
    } else {
        // A defeated teammate ends the attempt for the pair and for solo.
        scr_begin_gameover();
    }
}
function scr_player_tick(_move, _jump, _build, _jump_held=false) {
    if (!active_player || global.game_state != "play") return;
    last_move=_move;
    if (invulnerable > 0) invulnerable--;
    if (_move != 0) facing=sign(_move);
    grounded=scr_world_aabb_solid(x-body_half_width,y,x+body_half_width,y+1);
    // Normal jump is immediate. Only the separate dash key can accumulate charge.
    var _charging=_jump_held && grounded && !_jump;
    var _release=_jump_was_held && !_jump_held && grounded;
    jump_held=_charging;
    if (_charging) {
        charge=min(charge+1,150);
        if (_move!=0) _charge_dir=sign(_move);
    }
    if (_jump && grounded) {
        vy=jump_speed;charge=0;_hthrust=0;_charge_dir=0;
        scr_sfx(sfx_jump,0.04);
    } else if (_release && charge>0) {
        var _ratio=charge/150;
        vy=jump_speed-6*_ratio;
        if (charge>=150) {
            _hdir=(_charge_dir!=0?_charge_dir:facing);
            _hthrust=30;vy=-12;facing=_hdir;
        }
        charge=0;_charge_dir=0;scr_sfx(sfx_jump,0.04);
    }
    if (!grounded) {charge=0;_charge_dir=0;}
    _jump_was_held=_charging;
    var _dir=(_hthrust>0?_hdir:sign(_move));
    var _speed=(_charging?0:(_hthrust>0?_hthrust:abs(_move)*move_speed));
    repeat(round(_speed)) {
        var _nx=x+_dir;
        if(scr_world_aabb_solid(_nx-body_half_width,y-body_height,_nx+body_half_width,y,true))break;
        x=_nx;
    }
    _hthrust=max(0,_hthrust-0.5);
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
        var _bx = (facing>0 ? ceil((x+body_half_width)/64)*64 : floor((x-body_half_width)/64)*64-64);
        var _by = floor((y+0.5)/64)*64-64;
        var _other_player = instance_find((player_number==0 ? obj_player_p2 : obj_player_p1),0);
        var _occupied_by_partner = (_other_player != noone && _other_player.active_player && _other_player.x+16>_bx && _other_player.x-16<_bx+64 && _other_player.y>_by && _other_player.y-70<_by+64);
        if (_bx>=64 && _bx+64<=room_width-64 && _by>=64 && !_occupied_by_partner && !scr_world_aabb_solid(_bx,_by,_bx+64,_by+64)) {
            var _new_block=instance_create_layer(_bx,_by,"Instances_1",obj_build_block);
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
    if(!active_player || (global.game_state!="play" && global.game_state!="ending"))return;
    if (invulnerable > 0 && (invulnerable div 5) mod 2 == 0) return;
    var _frame=0;
    if(jump_held) _frame=0;
    else if(!grounded)_frame=3;
    else if(last_move!=0) {var _cycle=[0,1,0,2];_frame=_cycle[(global.game_timer div 7) mod 4];}
    if(grounded && last_move==0 && !jump_held) scr_menu_idle(_index,x,y,80,facing);
    else scr_actor_pose(_index,_frame,x,y,80,facing);
    draw_set_color(_index==0 ? make_color_rgb(80,220,215) : make_color_rgb(247,181,77));
    draw_triangle(x-6,y-94,x+6,y-94,x,y-87,false);
    if (grounded && jump_held && charge > 0) {
        var _c = min(charge,150)/150;
        var _bw = 120; var _bh = 14; var _bx = x - _bw/2; var _by = y - 134;
        draw_sprite_ext(spr_jump_charge, 0, _bx, _by, 1, 1, 0, c_white, 0.9);
        var _col = make_color_rgb(95+160*_c, 205-70*_c, 125);
        draw_set_color(_col); draw_rectangle(_bx+2,_by+2,_bx+2 + (_bw-4)*_c,_by+_bh-2,false);
        draw_set_color(c_white);
    }
    for(var _j=0;_j<min(material_count,8);_j++) {
        var _ix=x+(_j-(min(material_count,8)-1)/2)*9;
        draw_triangle(_ix,y-107,_ix-3,y-103,_ix+3,y-103,false);
        draw_triangle(_ix,y-99,_ix-3,y-103,_ix+3,y-103,false);
    }
    draw_set_color(c_white);
}