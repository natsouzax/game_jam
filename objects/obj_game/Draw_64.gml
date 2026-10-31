var _state=global.game_state;
if(_state=="title" || _state=="intro") {
    draw_set_alpha(0.94);draw_set_color(make_color_rgb(26,27,38));draw_rectangle(0,0,1366,768,false);draw_set_alpha(1);
    draw_set_halign(fa_center);draw_set_valign(fa_middle);draw_set_color(make_color_rgb(239,211,148));
    draw_text_transformed(683,190,"JUNTOS",5,5,0);
    for(var _i=0;_i<2;_i++) {
        var _x=565+_i*236;
        draw_set_color((_i==0?global.ready_one:global.ready_two)?make_color_rgb(115,215,153):make_color_rgb(92,89,101));
        draw_circle(_x,420,42,false);draw_set_color(make_color_rgb(32,33,44));
        draw_triangle(_x-13,429,_x+13,429,_x,402,false);
    }
    if(_state=="intro") {
        draw_set_color(make_color_rgb(244,216,132));var _gy=340+sin(global.game_timer/20)*10;
        draw_circle(683,_gy,62,true);draw_circle(683,_gy,46,true);
        draw_triangle(658,_gy+30,708,_gy+30,683,_gy-45,false);
        draw_line_width(590,470,683,535,5);draw_line_width(776,470,683,535,5);
    }
    draw_set_halign(fa_left);draw_set_valign(fa_top);
} else if(_state=="play") {
    var _p1=instance_find(obj_player_p1,0);var _p2=instance_find(obj_player_p2,0);
    for(var _j=0;_j<2;_j++) {
        var _p=(_j==0?_p1:_p2);draw_set_color(_j==0?make_color_rgb(80,220,215):make_color_rgb(247,181,77));
        draw_circle(40+_j*44,36,12,false);
        if(_p.y<camera_y+60)draw_triangle(40+_j*44,55,32+_j*44,68,48+_j*44,68,false);
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
if(global.qa && (global.qa_frame==20 || global.qa_frame==300 || global.qa_frame mod 1800==0 || (global.game_state=="ending" && ending_timer==300)))screen_save("qa_"+string(global.qa_frame)+".png");
