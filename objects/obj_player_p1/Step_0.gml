var move_dir = keyboard_check(ord("D")) - keyboard_check(ord("A"));
if (move_dir != 0) facing = sign(move_dir);
x += move_dir * move_speed;
x = clamp(x, 20, room_width - 20);

if (y >= ground_y && keyboard_check_pressed(ord("W"))) {
    vy = jump_speed;
}

vy += gravity_speed;
y += vy;
if (y >= ground_y) {
    y = ground_y;
    vy = 0;
}
