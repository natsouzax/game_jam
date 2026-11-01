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
    if(global.game_timer>30)scr_draw_skip_x();
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
    if(global.game_timer>60)scr_draw_skip_x();
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
        if(_p.dead) {
            draw_set_color(make_color_rgb(242,90,108));
            draw_line_width(_hud_x+21,38,_hud_x+37,54,4);
            draw_line_width(_hud_x+37,38,_hud_x+21,54,4);
        }
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
        if(!_p.dead && global.player_count==2 && _p.player_lives==3) {
            var _mate=instance_find((_j==0?obj_player_p2:obj_player_p1),0);
            if(_mate!=noone && _mate.dead) {
                var _pulse=0.55+0.45*sin(global.game_timer*0.12);
                draw_set_alpha(_pulse);draw_set_color(make_color_rgb(255,218,128));
                draw_circle(_hud_x+163,45,12,true);
                draw_line_width(_hud_x+157,45,_hud_x+169,45,2);
                draw_line_width(_hud_x+163,39,_hud_x+163,51,2);
                draw_set_alpha(1);
            }
        }
    }
    draw_set_color(make_color_rgb(150,168,162));
    draw_rectangle(1320,726,1325,743,false);draw_rectangle(1331,726,1336,743,false);
} else if(_state=="gameover") scr_draw_gameover();
else if(_state=="ending") {
    scr_draw_ending(ending_timer);
    if(ending_timer>30 && ending_timer<4600)scr_draw_skip_x();
}
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
