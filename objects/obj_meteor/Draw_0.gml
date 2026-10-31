if(global.game_state!="play" && global.game_state!="pause")exit;
var _trail=min(8,age);
if(kind==0) {
    for(var _i=1;_i<=_trail;_i++) {
        draw_set_alpha(0.28*(1-_i/(_trail+2)));
        draw_set_color(make_color_rgb(255,224,120));
        draw_circle(x-drift*_i*2,y-fall_speed*_i*0.9,radius*(1-_i/(_trail+3)),false);
    }
    draw_set_alpha(0.45);
    draw_set_color(make_color_rgb(255,214,90));
    draw_circle(x,y,radius*1.6,false);
    draw_set_alpha(1);
    draw_set_color(make_color_rgb(255,214,90));
    draw_triangle(x,y-radius*1.6,x-radius*0.55,y,x+radius*0.55,y,false);
    draw_triangle(x,y+radius*1.6,x-radius*0.55,y,x+radius*0.55,y,false);
    draw_triangle(x-radius*1.6,y,x,y-radius*0.55,x,y+radius*0.55,false);
    draw_triangle(x+radius*1.6,y,x,y-radius*0.55,x,y+radius*0.55,false);
    draw_circle(x,y,radius*0.45,false);
    draw_set_color(make_color_rgb(255,250,220));
    draw_circle(x-2,y-2,radius*0.2,false);
} else {
    var _glow=0.75+0.25*sin(global.game_timer/4);
    for(var _i=1;_i<=_trail;_i++) {
        draw_set_alpha(0.24*(1-_i/(_trail+2))*_glow);
        draw_set_color(merge_color(make_color_rgb(255,236,164),make_color_rgb(214,72,38),_i/_trail));
        draw_circle(x-drift*_i*2,y-fall_speed*_i*0.85,radius*(1-_i/(_trail+3)),false);
    }
    draw_set_alpha(0.35*_glow);
    draw_set_color(make_color_rgb(255,146,64));
    draw_circle(x,y,radius*1.5,false);
    draw_set_alpha(1);
    draw_set_color(make_color_rgb(94,76,72));
    draw_circle(x,y,radius,false);
    draw_set_color(make_color_rgb(132,108,96));
    draw_triangle(x-radius*0.9,y-radius*0.35,x-radius*0.15,y-radius*0.95,x+radius*0.35,y-radius*0.15,false);
    draw_set_color(make_color_rgb(66,52,54));
    draw_triangle(x+radius*0.9,y+radius*0.3,x+radius*0.1,y+radius*0.9,x-radius*0.45,y+radius*0.2,false);
    draw_set_color(make_color_rgb(255,170,74));
    draw_line_width(x-radius*0.5,y+radius*0.15,x+radius*0.2,y-radius*0.2,3);
    draw_line_width(x+radius*0.2,y-radius*0.2,x+radius*0.55,y+radius*0.25,3);
}
draw_set_alpha(1);
draw_set_color(c_white);
