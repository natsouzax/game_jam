var move_dir = keyboard_check(ord("D")) - keyboard_check(ord("A"));
if (move_dir != 0) facing = sign(move_dir);
for (var _mx = 0; _mx < ceil(abs(move_dir * move_speed)); _mx++) {
    var _next_x = x + sign(move_dir);
    if (scr_world_aabb_solid(_next_x - body_half_width, y - body_height, _next_x + body_half_width, y)) break;
    x = _next_x;
}
x = clamp(x, body_half_width, room_width - body_half_width);

// Recolha individual por contacto com a inst?ncia do material.
var _near_material = instance_nearest(x, y - body_height * 0.5, obj_material);
if (_near_material != noone
&& _near_material.x + 18 >= x - body_half_width
&& _near_material.x - 18 <= x + body_half_width
&& _near_material.y + 18 >= y - body_height
&& _near_material.y - 18 <= y) {
    material_count += 1;
    with (_near_material) instance_destroy();
}

// P1 gera uma pe?a por vez; a pr?xima cai ap?s o intervalo se a anterior foi recolhida.
if (instance_number(obj_material) == 0) {
    material_spawn_timer += 1;
    if (material_spawn_timer >= material_spawn_interval) {
        var _spawn_x = irandom_range(48, room_width - 48);
        instance_create_layer(_spawn_x, -32, "Instances_1", obj_material);
        material_spawn_timer = 0;
    }
} else {
    material_spawn_timer = 0;
}

// E coloca um bloco na c?lula livre ? frente, um n?vel acima dos p?s.
if (keyboard_check_pressed(ord("E")) && material_count > 0) {
    var _block_x;
    if (facing > 0) _block_x = ceil((x + body_half_width) / 32) * 32;
    else _block_x = floor((x - body_half_width) / 32) * 32 - 32;
    var _block_y = floor(y / 32) * 32 - 32;
    if (_block_x >= 0 && _block_x + 32 <= room_width && _block_y >= 0
    && !scr_world_aabb_solid(_block_x, _block_y, _block_x + 32, _block_y + 32)) {
        instance_create_layer(_block_x, _block_y, "Instances_1", obj_build_block);
        material_count -= 1;
    }
}

var _grounded = scr_world_aabb_solid(x - body_half_width, y - body_height, x + body_half_width, y + 1);
if (_grounded && keyboard_check_pressed(ord("W"))) vy = jump_speed;
vy += gravity_speed;
var _next_y = y + vy;
if (vy > 0) {
    var _surface_y = scr_world_landing_surface(x - body_half_width, x + body_half_width, y, _next_y);
    if (_surface_y != noone) {
        y = _surface_y;
        vy = 0;
    } else if (scr_world_aabb_solid(x - body_half_width, _next_y - body_height, x + body_half_width, _next_y)) {
        vy = 0;
    } else y = _next_y;
} else if (vy < 0) {
    if (scr_world_aabb_solid(x - body_half_width, _next_y - body_height, x + body_half_width, _next_y)) vy = 0;
    else y = _next_y;
}
