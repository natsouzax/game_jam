var _state=global.game_state;
if(_state=="play"||_state=="pause"||_state=="gameover"||_state=="ending")scr_draw_void();
if(_state=="studio") {
    draw_set_color(c_black);draw_rectangle(0,0,1366,768,false);
    var _fade=min(1,global.game_timer/30,(150-global.game_timer)/30);
    draw_set_alpha(max(0,_fade));draw_set_color(c_white);
    draw_set_halign(fa_center);draw_set_valign(fa_middle);
    draw_text_transformed(683,384,"Lusitanos Games",2.1,2.1,0);
    draw_set_halign(fa_left);draw_set_valign(fa_top);draw_set_alpha(1);
    draw_set_alpha(0.55);draw_set_color(make_color_rgb(8,13,20));draw_rectangle(1288,700,1352,752,false);draw_set_alpha(1);
    draw_set_color(c_white);draw_triangle(1310,715,1310,737,1326,726,false);
    draw_set_halign(fa_left);draw_set_valign(fa_top);
} else if(_state=="video") {
    draw_set_color(c_black);draw_rectangle(0,0,1366,768,false);
    if(global.boot_video_started) {
        var _video_frame=video_draw();
        if(_video_frame[0]==0 && array_length(_video_frame)>1 && surface_exists(_video_frame[1]))
            draw_surface_stretched(_video_frame[1],0,0,1366,768);
        if(_video_frame[0]==-1)global.boot_video_error=true;
    }
    draw_set_alpha(0.55);draw_set_color(make_color_rgb(8,13,20));draw_rectangle(1288,700,1352,752,false);draw_set_alpha(1);
    draw_set_color(c_white);draw_triangle(1310,715,1310,737,1326,726,false);
    draw_set_halign(fa_left);draw_set_valign(fa_top);
} else if(_state=="title")scr_draw_title_menu();
else if(_state=="intro")scr_draw_intro();
else if(_state=="play" || _state=="pause") {
    for(var _j=0;_j<2;_j++) {
        var _p=instance_find((_j==0?obj_player_p1:obj_player_p2),0);
        if(!_p.active_player)continue;
        var _hud_x=(global.player_count==1?24:24+_j*184);
        var _accent=(_j==0?make_color_rgb(80,220,215):make_color_rgb(247,181,77));
        draw_set_color(make_color_rgb(12,20,28));draw_rectangle(_hud_x+4,20,_hud_x+180,82,false);
        draw_set_color(_accent);draw_rectangle(_hud_x,16,_hud_x+176,78,false);
        draw_set_color(make_color_rgb(28,40,49));draw_rectangle(_hud_x+4,20,_hud_x+172,74,false);
        draw_set_color(_accent);draw_circle(_hud_x+29,46,16,false);
        for(var _li=0;_li<3;_li++) {
            var _hx=_hud_x+76+_li*29;var _hy=44;
            draw_set_color(_li<_p.player_lives?make_color_rgb(242,90,108):make_color_rgb(72,82,89));
            draw_circle(_hx-6,_hy-4,7,false);draw_circle(_hx+6,_hy-4,7,false);
            draw_triangle(_hx-13,_hy,_hx+13,_hy,_hx,_hy+13,false);
            if(_li<_p.player_lives) {
                draw_set_color(make_color_rgb(255,170,169));draw_rectangle(_hx-8,_hy-8,_hx-4,_hy-5,false);
            }
        }
        if(_p.y<camera_y+60) {draw_set_color(_accent);draw_triangle(_hud_x+29,81,_hud_x+19,94,_hud_x+39,94,false);}
    }
    draw_set_halign(fa_right);draw_set_valign(fa_bottom);
    draw_set_color(make_color_rgb(150,168,162));
    draw_text_transformed(1342,746,"ESC  PAUSA",0.9,0.9,0);
    draw_set_halign(fa_left);draw_set_valign(fa_top);
} else if(_state=="gameover") scr_draw_gameover();
else if(_state=="ending") scr_draw_ending(ending_timer);
if(_state=="pause")scr_draw_pause();
draw_set_alpha(1);draw_set_color(c_white);
if(global.qa_regression) {
    if(qa_regression_stage==1)screen_save("qa_regression_play.png");
    if(qa_regression_stage==2)screen_save("qa_regression_menu.png");
} else if(global.qa)scr_qa_capture();
if(global.boot_test) {
    if(_state=="studio" && global.game_timer==75)screen_save("boot_studio.png");
    if(_state=="video" && global.game_timer==180)screen_save("boot_video.png");
    if(_state=="title" && global.game_timer==30)screen_save("boot_menu.png");
}
