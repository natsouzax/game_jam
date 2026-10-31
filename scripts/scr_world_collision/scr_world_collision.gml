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
