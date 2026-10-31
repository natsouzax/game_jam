draw_set_color(is_checkpoint?make_color_rgb(88,105,103):make_color_rgb(117,84,65));
draw_rectangle(x,y,x+solid_width-1,y+solid_height-1,false);
draw_set_color(make_color_rgb(189,151,105));draw_rectangle(x,y,x+solid_width-1,y+3,false);
if(is_checkpoint) {
    draw_set_color(make_color_rgb(117,205,169));draw_circle(x+24,y-9,8,true);draw_circle(x+solid_width-24,y-9,8,true);
} else {draw_set_color(make_color_rgb(68,58,56));draw_rectangle(x+3,y+6,x+solid_width-4,y+solid_height-4,true);}
draw_set_color(c_white);
