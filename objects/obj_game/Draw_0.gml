draw_set_color(make_color_rgb(39,35,49));draw_rectangle(0,0,room_width,room_height,false);
for(var _i=0;_i<18;_i++) {
    var _x=_i*84;draw_set_color(make_color_rgb(52+_i mod 3*6,43,51));
    draw_rectangle(_x,560+(_i mod 4)*110,_x+54,1408,false);
}
draw_set_color(make_color_rgb(151,118,79));
for(var _j=0;_j<5;_j++) {
    var _y=1216-_j*192;
    draw_circle(672,_y-50,10,true);
    draw_triangle(665,_y-75,679,_y-75,672,_y-84,false);
}
if(global.game_state=="ending") {
    var _amount=clamp(ending_timer/180,0,1);
    draw_set_color(make_color_rgb(108,185,108));
    for(var _k=0;_k<instance_number(obj_build_block);_k++) {
        var _b=instance_find(obj_build_block,_k);
        draw_line_width(_b.x+8,_b.y,_b.x+8,_b.y-22*_amount,3);
        draw_ellipse(_b.x+5,_b.y-20*_amount,_b.x+20,_b.y-10*_amount,false);
    }
}
draw_set_color(c_white);
