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

function scr_world_support_y(_left,_right,_bottom) {
    var _best=noone;
    for(var _i=0;_i<instance_number(obj_world_solid);_i++) {
        var _solid=instance_find(obj_world_solid,_i);
        if(_solid==noone) continue;
        if(_right>_solid.x && _left<_solid.x+_solid.solid_width
        && abs(_solid.y-_bottom)<=2
        && (_best==noone || _solid.y<_best)) _best=_solid.y;
    }
    return _best;
}

function scr_world_build_is_attached(_x,_y) {
    // Any contact counts, including a single corner. Tolerance absorbs off-grid solids (e.g. the ground);
    // a full block of empty space (64 px) between them is not attached, so it would "fall".
    var _tol=6;
    for(var _i=0;_i<instance_number(obj_world_solid);_i++) {
        var _solid=instance_find(obj_world_solid,_i);
        if(_solid==noone) continue;
        var _sx2=_solid.x+_solid.solid_width;
        var _sy2=_solid.y+_solid.solid_height;
        // Boxes expanded by the tolerance overlap or touch => connected (side, top, bottom or diagonal corner).
        if(_x-_tol<=_sx2 && _x+64+_tol>=_solid.x && _y-_tol<=_sy2 && _y+64+_tol>=_solid.y) return true;
    }
    return false;
}

function scr_world_block_at(_x,_y) {
    for(var _i=0;_i<instance_number(obj_build_block);_i++) {
        var _block=instance_find(obj_build_block,_i);
        if(_block==noone) continue;
        var _bw=(_block.falling?64:_block.solid_width);var _bh=(_block.falling?64:_block.solid_height);
        if(_x<_block.x+_bw && _x+64>_block.x && _y<_block.y+_bh && _y+64>_block.y) return _block;
    }
    return noone;
}
