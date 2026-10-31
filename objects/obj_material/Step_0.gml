if (y < ground_y) {
    fall_speed = min(fall_speed + gravity_speed, 12);
    y = min(y + fall_speed, ground_y);
    if (y >= ground_y) fall_speed = 0;
}
