if(global.game_state!="play")exit;
draw_set_color(make_color_rgb(120,200,100));
draw_ellipse(x-16,y-12,x+16,y+8,false);
draw_set_color(make_color_rgb(80,150,70));
draw_ellipse(x-16,y-12,x+16,y+8,true);
draw_set_color(make_color_rgb(200,240,180));
draw_circle(x-6,y-4,3,false);draw_circle(x+6,y-4,3,false);
draw_set_color(c_white);