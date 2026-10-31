debug_timer -= 1;
if (debug_timer <= 0) {
    debug_timer = 60;
    var f = file_text_open_write("C:/Users/natan/GameMakerProjects/gameJam/build/debug.txt");
    file_text_write_string(f, "room=" + string(room_width) + "x" + string(room_height) + " win=" + string(window_get_width()) + "x" + string(window_get_height()) + " view=" + string(view_wview[0]) + "x" + string(view_hview[0]) + " port=" + string(view_wport[0]) + "x" + string(view_hport[0]) + " en=" + string(view_enabled) + "\n");
    file_text_write_string(f, "p1=" + string(instance_number(obj_player_p1)) + " p2=" + string(instance_number(obj_player_p2)) + " mat=" + string(instance_number(obj_material)) + "\n");
    with (obj_player_p1) file_text_write_string(f, "P1 " + string(x) + "," + string(y) + "\n");
    with (obj_player_p2) file_text_write_string(f, "P2 " + string(x) + "," + string(y) + "\n");
    with (obj_material) file_text_write_string(f, "M " + string(x) + "," + string(y) + "\n");
    file_text_close(f);
}
