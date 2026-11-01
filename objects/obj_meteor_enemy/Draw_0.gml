if(global.game_state!="play")exit;
draw_set_color(make_color_rgb(120,100,80));
draw_ellipse(x-18,y-14,x+18,y+14,false);
draw_set_color(make_color_rgb(80,60,40));
draw_ellipse(x-18,y-14,x+18,y+14,true);
draw_set_color(make_color_rgb(180,140,100));
draw_circle(x-4,y-6,3,false);draw_circle(x+4,y-6,3,false);
draw_set_color(c_white);