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
        if(_p.y<camera_y+60)draw_triangle(_hud_x,55,_hud_x-8,68,_hud_x+8,68,false);
    }
} else if(_state=="ending" && ending_timer>120) {
    var _fade=clamp((ending_timer-120)/100,0,1);
    draw_set_alpha(_fade);draw_set_color(make_color_rgb(27,32,39));draw_rectangle(0,0,1366,768,false);
    draw_set_alpha(1);draw_set_color(make_color_rgb(76,88,93));draw_rectangle(430,100,936,390,false);
    draw_set_color(make_color_rgb(129,191,153));draw_rectangle(447,118,919,366,false);
    draw_set_color(make_color_rgb(75,110,90));
    for(var _s=0;_s<7;_s++)draw_rectangle(580+(_s mod 2)*48,340-_s*29,628+(_s mod 2)*48,369-_s*29,false);
    draw_set_color(make_color_rgb(235,211,157));draw_circle(666,160,21,false);draw_circle(705,160,21,false);
    // Six original abstract team avatars watching their shared creation on a monitor.
    var _colors=[make_color_rgb(80,220,215),make_color_rgb(247,181,77),make_color_rgb(170,132,203),make_color_rgb(205,119,105),make_color_rgb(121,185,132),make_color_rgb(127,163,214)];
    for(var _a=0;_a<6;_a++) {
        var _ax=358+_a*130;var _ay=540+sin(ending_timer/24+_a)*3;
        draw_set_color(_colors[_a]);draw_rectangle(_ax-29,_ay,_ax+29,_ay+82,false);
        draw_set_color(make_color_rgb(220-_a*12,164-_a*9,120-_a*7));draw_rectangle(_ax-25,_ay-47,_ax+25,_ay-2,false);
        draw_rectangle(_ax-29,_ay-31,_ax+29,_ay-16,false);
        draw_set_color(make_color_rgb(38,36,42));draw_rectangle(_ax-26,_ay-51,_ax+26,_ay-36,false);
        if(_a mod 2==0)draw_rectangle(_ax-26,_ay-45,_ax-16,_ay-20,false);
        draw_rectangle(_ax-15,_ay-28,_ax-8,_ay-21,false);draw_rectangle(_ax+8,_ay-28,_ax+15,_ay-21,false);
        draw_rectangle(_ax-6,_ay-12,_ax+8,_ay-9,false);
        if(_a==0 || _a==3)draw_rectangle(_ax-20,_ay-28,_ax+20,_ay-24,false);
        draw_set_color(make_color_rgb(165,175,173));draw_roundrect(_ax-25,_ay+35,_ax+25,_ay+57,false);
        draw_set_color(make_color_rgb(45,49,58));draw_circle(_ax-12,_ay+45,5,false);draw_circle(_ax+12,_ay+45,5,false);
    }
    if(ending_timer>360) {
        draw_set_color(make_color_rgb(165,220,170));draw_circle(683,700,23,true);
        draw_triangle(704,679,711,698,691,693,false);
    }
}
draw_set_alpha(1);draw_set_color(c_white);
if(global.qa)scr_qa_capture();
