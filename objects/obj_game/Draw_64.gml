var _state=global.game_state;
if(_state=="title")scr_draw_title_menu();
else if(_state=="intro")scr_draw_intro();
else if(_state=="play") {
    // A shrinking link warns the pair before separation resets the climb.
    if(separation_timer>0) {
        draw_set_color(make_color_rgb(39,35,49));draw_rectangle(550,24,816,38,false);
        draw_set_color(make_color_rgb(241,160,89));
        draw_rectangle(554,28,554+258*(1-separation_timer/180),34,false);
    }
    for(var _j=0;_j<2;_j++) {
        var _p=instance_find((_j==0?obj_player_p1:obj_player_p2),0);
        if(!_p.active_player)continue;
        var _hud_x=(global.player_count==1?40:40+_j*54);
        draw_set_color(_j==0?make_color_rgb(80,220,215):make_color_rgb(247,181,77));
        draw_circle(_hud_x,36,13,false);
        if(_p.y<camera_y+60)draw_triangle(_hud_x,55,_hud_x-8,68,_hud_x+8,68,false);
    }
} else if(_state=="ending") scr_draw_ending(ending_timer);
if(!global.qa && global.audio_game_muted) {
    draw_set_color(make_color_rgb(13,18,27));draw_rectangle(1287,12,1351,57,false);
    draw_set_color(make_color_rgb(245,232,201));
    draw_rectangle(1300,29,1308,40,false);draw_triangle(1308,29,1321,20,1321,49,false);
    draw_line_width(1325,20,1340,49,4);
}
draw_set_alpha(1);draw_set_color(c_white);
if(global.qa)scr_qa_capture();
