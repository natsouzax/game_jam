var _state=global.game_state;
if(_state=="title")scr_draw_title_menu();
else if(_state=="intro")scr_draw_intro();
else if(_state=="play") {
    for(var _j=0;_j<2;_j++) {
        var _p=instance_find((_j==0?obj_player_p1:obj_player_p2),0);
        if(!_p.active_player)continue;
        var _hud_x=(global.player_count==1?40:40+_j*54);
        draw_set_color(_j==0?make_color_rgb(80,220,215):make_color_rgb(247,181,77));
        draw_circle(_hud_x,36,13,false);
        for(var _li=0;_li<_p.player_lives;_li++) { draw_set_color(c_red); draw_circle(_hud_x-6+_li*6,16,3,false); }
        if(_p.dead) { draw_set_color(c_gray); draw_text(_hud_x-10,48,string(ceil(_p.respawn_timer/60))); }
        if(_p.y<camera_y+60)draw_triangle(_hud_x,55,_hud_x-8,68,_hud_x+8,68,false);
    }
} else if(_state=="gameover") scr_draw_gameover();
else if(_state=="ending") scr_draw_ending(ending_timer);
draw_set_alpha(1);draw_set_color(c_white);
if(global.qa_regression) {
    if(qa_regression_stage==1)screen_save("qa_regression_play.png");
    if(qa_regression_stage==2)screen_save("qa_regression_menu.png");
} else if(global.qa)scr_qa_capture();
