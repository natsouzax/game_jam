var _top=(is_checkpoint?make_color_rgb(110,155,142):make_color_rgb(189,151,105));
var _face=(is_checkpoint?make_color_rgb(56,83,80):make_color_rgb(117,84,65));
draw_set_color(make_color_rgb(20,24,31));draw_rectangle(x+4,y+4,x+solid_width-1,y+solid_height-1,false);
draw_set_color(_face);draw_rectangle(x,y,x+solid_width-5,y+solid_height-5,false);
draw_set_color(_top);draw_rectangle(x,y,x+solid_width-5,y+3,false);
draw_set_color(merge_colour(_face,c_black,0.24));draw_rectangle(x+solid_width-9,y+4,x+solid_width-5,y+solid_height-5,false);
draw_set_color(merge_colour(_top,c_white,0.24));draw_rectangle(x+3,y+4,x+solid_width-10,y+6,false);
if(is_checkpoint) {
    draw_set_color(make_color_rgb(117,205,169));draw_circle(x+24,y-9,8,true);draw_circle(x+solid_width-24,y-9,8,true);
    draw_set_color(make_color_rgb(208,249,207));draw_rectangle(x+21,y-12,x+26,y-7,false);draw_rectangle(x+solid_width-27,y-12,x+solid_width-22,y-7,false);
} else {
    draw_set_color(make_color_rgb(68,58,56));draw_rectangle(x+5,y+9,x+solid_width-11,y+solid_height-9,false);
    draw_set_color(make_color_rgb(145,112,83));
    for(var _seam=x+16;_seam<x+solid_width-12;_seam+=24) draw_rectangle(_seam,y+10,_seam+2,y+solid_height-10,false);
    draw_set_color(make_color_rgb(210,172,119));
    draw_rectangle(x+7,y+8,x+11,y+12,false);draw_rectangle(x+solid_width-15,y+8,x+solid_width-11,y+12,false);
    if(crack_until>=global.game_timer) {
        draw_set_color(make_color_rgb(245,209,119));
        draw_line_width(x+11,y+8,x+28,y+23,3);
        draw_line_width(x+28,y+23,x+21,y+38,3);
        draw_line_width(x+28,y+23,x+48,y+39,3);
        draw_rectangle(x-2,y-2,x+solid_width+1,y+solid_height+1,true);
    }
}
draw_set_color(c_white);
