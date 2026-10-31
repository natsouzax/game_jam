
function scr_player_init(_index) {
    player_number = _index; body_half_width = 16; body_height = 70;
    move_speed = 4; jump_speed = -11; gravity_speed = 0.48;
    x = 570 + _index * 150; y = 1408; vy = 0; facing = (_index == 0 ? 1 : -1);
    material_count = 0; collected_total = 0; built_total = 0; recoveries = 0;
    respawn_x = x; respawn_y = y; grounded = true; invulnerable = 0;
    enemy_hits=0;fall_hits=0;last_move=0;shared_uses=0;last_support=noone;recovery_valid=true;reset_blocks_total=0;section_resets=0;
    checkpoint_level = 0; depth = -10; qa_jump_cooldown = 0; qa_target=noone;
}
// Section 0 is ground-to-first-checkpoint; each next section is 192 px high.
function scr_tower_section_at_y(_top) {
    return max(0, floor((1408 - _top - 1) / 192));
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
    // The tower is shared: reset both builders' blocks in the active checkpoint section.
    var _reset=scr_reset_section_blocks(checkpoint_level);
    reset_blocks_total+=_reset.removed; section_resets++;
    x=respawn_x; y=respawn_y; vy=0; grounded=true;
    invulnerable=100; recoveries++; qa_target=noone; last_support=noone;
    recovery_valid=recovery_valid && material_count==_stock_before && _reset.scope_ok;
}
function scr_player_tick(_move, _jump, _build) {
    if (global.game_state != "play") return;
    last_move=_move;
    if (invulnerable > 0) invulnerable--;
    if (_move != 0) facing = sign(_move);
    repeat (abs(_move * move_speed)) {
        var _nx = x + sign(_move);
        if (scr_world_aabb_solid(_nx-body_half_width,y-body_height,_nx+body_half_width,y,true)) break;
        x = _nx;
    }
    x = clamp(x,32,room_width-32);
    grounded = scr_world_aabb_solid(x-body_half_width,y,x+body_half_width,y+1);
    if (_jump && grounded) vy = jump_speed;
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
        material_count++; collected_total++; instance_destroy(_m);
    }
    if (_build && material_count > 0) {
        var _bx = (facing>0 ? ceil((x+body_half_width)/32)*32 : floor((x-body_half_width)/32)*32-32);
        var _by = floor((y+0.5)/32)*32-32;
        var _other_player = instance_find((player_number==0 ? obj_player_p2 : obj_player_p1),0);
        var _occupied_by_partner = (_other_player != noone && _other_player.x+16>_bx && _other_player.x-16<_bx+32 && _other_player.y>_by && _other_player.y-70<_by+32);
        if (_bx>=32 && _bx+32<=room_width-32 && _by>=64 && !_occupied_by_partner && !scr_world_aabb_solid(_bx,_by,_bx+32,_by+32)) {
            var _new_block=instance_create_layer(_bx,_by,"Instances_1",obj_build_block);
            _new_block.builder_number=player_number;
            material_count--; built_total++;
        }
    }
    if (grounded) {
        for (var _i=0;_i<instance_number(obj_build_block);_i++) {
            var _s=instance_find(obj_build_block,_i);
            if(abs(y-_s.y)<2 && x>_s.x-12 && x<_s.x+_s.solid_width+12 && _s.builder_number>=0 && _s.builder_number!=player_number && last_support!=_s) {shared_uses++;last_support=_s;}
            if (_s.is_checkpoint && abs(y-_s.y)<2 && x>_s.x+8 && x<_s.x+_s.solid_width-8 && _s.level_id>checkpoint_level) {
                checkpoint_level=_s.level_id; respawn_x=x; respawn_y=_s.y;
            }
        }
    }
    if (y > respawn_y+160 || y > room_height+64) {fall_hits++;scr_player_recover();}
}
function scr_player_render(_sprite, _index) {
    if (invulnerable > 0 && (invulnerable div 5) mod 2 == 0) return;
    var _rects = (_index == 0 ? [[0,30,290,430],[299,29,577,407],[596,30,887,430],[890,29,1183,430],[1186,30,1472,429],[1491,29,1756,427],[590,440,920,871]] : [[33,33,275,422],[315,35,566,421],[628,35,887,421],[888,33,1166,421],[1215,33,1464,429],[1515,37,1742,423],[590,440,915,859]]);
    var _moving = (player_number==0 ? keyboard_check(ord("A"))||keyboard_check(ord("D")) : keyboard_check(vk_left)||keyboard_check(vk_right));
    var _frame=0;
    if (!grounded) _frame=6;
    else if (_moving) _frame=floor(current_time/110) mod 6;
    if(_index==0 && grounded && !_moving) {
        _sprite=spr_player1_idle;
        _rects=[[219, 90, 522, 627], [699, 90, 1008, 627], [219, 673, 522, 1207], [699, 673, 1002, 1207]];
        _frame=floor(current_time/420) mod 4;
    }
    var _r=_rects[_frame];var _h=_r[3]-_r[1];var _w=_r[2]-_r[0];var _scale=86/_h;
    if(grounded && !_moving)_scale*=1+sin(current_time/400)*0.008;
    draw_sprite_part_ext(_sprite,0,_r[0],_r[1],_w,_h,x-facing*_w*_scale/2,y-_h*_scale,facing*_scale,_scale,c_white,1);
    draw_set_color(_index==0 ? make_color_rgb(80,220,215) : make_color_rgb(247,181,77));
    draw_triangle(x-6,y-101,x+6,y-101,x,y-94,false);
    for(var _j=0;_j<min(material_count,8);_j++) {
        var _ix=x+(_j-(min(material_count,8)-1)/2)*9;
        draw_triangle(_ix,y-114,_ix-3,y-110,_ix+3,y-110,false);
        draw_triangle(_ix,y-106,_ix-3,y-110,_ix+3,y-110,false);
    }
    draw_set_color(c_white);
}
function scr_qa_input() {
    var _move=0;var _jump=false;var _build=false;
    if(global.qa_recovery_test && player_number==0 && checkpoint_level>=1 && fall_hits==0)return [1,grounded,false];
    if(global.qa_recovery_test && player_number==1 && checkpoint_level>=2 && enemy_hits==0) {
        var _enemy=instance_find(obj_enemy,0);
        if(_enemy!=noone)return [sign(_enemy.x-x),grounded,false];
    }
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
        && _fixed==5 && instance_number(obj_build_block)==6 && _p1.recovery_valid && _p2.recovery_valid;
    return {passed:_ok,section_one_removed:_p1.reset_blocks_total,section_zero_removed:_p2.reset_blocks_total,
        fixed_platforms:_fixed,later_section_preserved:instance_exists(_later),both_builders_removed:_section_one_ok,
        inventories_preserved:_p1.material_count==3 && _p2.material_count==2,checkpoint_return:_p1.y==1216 && _p2.y==1408};
}
