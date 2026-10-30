p1_x += (keyboard_check(ord("D")) - keyboard_check(ord("A"))) * move_speed;
p2_x += (keyboard_check(vk_right) - keyboard_check(vk_left)) * move_speed;
p1_x = clamp(p1_x, 20, room_width - 20);
p2_x = clamp(p2_x, 20, room_width - 20);
if (p1_y >= ground_y && keyboard_check_pressed(ord("W"))) p1_vy = jump_speed;
if (p2_y >= ground_y && keyboard_check_pressed(vk_up)) p2_vy = jump_speed;
p1_vy += gravity_speed;
p2_vy += gravity_speed;
p1_y += p1_vy;
p2_y += p2_vy;
if (p1_y > ground_y) { p1_y = ground_y; p1_vy = 0; }
if (p2_y > ground_y) { p2_y = ground_y; p2_vy = 0; }
