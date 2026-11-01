function scr_world_aabb_solid(_left, _top, _right, _bottom, _skip_platforms=false) {
    var _count = instance_number(obj_world_solid);
    for (var _i = 0; _i < _count; _i++) {
        var _solid = instance_find(obj_world_solid, _i);
        if (_solid != noone
        && !(_skip_platforms && _solid.is_checkpoint)
        && _left < _solid.x + _solid.solid_width
        && _right > _solid.x
        && _top < _solid.y + _solid.solid_height
        && _bottom > _solid.y) return true;
    }
    return false;
}

function scr_world_landing_surface(_left, _right, _previous_bottom, _next_bottom) {
    var _surface = noone;
    var _count = instance_number(obj_world_solid);
    for (var _i = 0; _i < _count; _i++) {
        var _solid = instance_find(obj_world_solid, _i);
        if (_solid != noone
        && _right > _solid.x
        && _left < _solid.x + _solid.solid_width
        && _previous_bottom <= _solid.y
        && _next_bottom >= _solid.y
        && (_surface == noone || _solid.y < _surface)) _surface = _solid.y;
    }
    return _surface;
}

function scr_world_build_target(_player_x,_player_y,_move=0) {
    // While airborne, follow forward movement; otherwise keep the block underfoot.
    var _cell_x=floor(_player_x/64)*64;
    if(_move!=0) _cell_x+=sign(_move)*64;
    return [_cell_x,ceil(_player_y/64)*64];
}

function scr_world_build_is_attached(_x,_y) {
    for(var _i=0;_i<instance_number(obj_world_solid);_i++) {
        var _solid=instance_find(obj_world_solid,_i);
        if(_solid==noone) continue;
        var _overlap_x=(_x<_solid.x+_solid.solid_width && _x+64>_solid.x);
        var _overlap_y=(_y<_solid.y+_solid.solid_height && _y+64>_solid.y);
        var _touch_left=(_x+64==_solid.x && _overlap_y);
        var _touch_right=(_x==_solid.x+_solid.solid_width && _overlap_y);
        var _touch_top=(_y+64==_solid.y && _overlap_x);
        var _touch_bottom=(_y==_solid.y+_solid.solid_height && _overlap_x);
        var _touch_diag_tl=(_x+64==_solid.x && _y+64==_solid.y);
        var _touch_diag_tr=(_x==_solid.x+_solid.solid_width && _y+64==_solid.y);
        var _touch_diag_bl=(_x+64==_solid.x && _y==_solid.y+_solid.solid_height);
        var _touch_diag_br=(_x==_solid.x+_solid.solid_width && _y==_solid.y+_solid.solid_height);
        if(_touch_left || _touch_right || _touch_top || _touch_bottom
           || _touch_diag_tl || _touch_diag_tr || _touch_diag_bl || _touch_diag_br) return true;
    }
    return false;
}

function scr_world_block_at(_x,_y) {
    for(var _i=0;_i<instance_number(obj_build_block);_i++) {
        var _block=instance_find(obj_build_block,_i);
        if(_block!=noone && _x<_block.x+_block.solid_width && _x+64>_block.x
            && _y<_block.y+_block.solid_height && _y+64>_block.y) return _block;
    }
    return noone;
}
