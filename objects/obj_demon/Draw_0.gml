if(global.game_state!="play" && global.game_state!="pause")exit;
var _frame=(global.game_timer div 8) mod 4;
scr_demon_draw(_frame,x,y);
draw_set_color(make_color_rgb(255,150,80));
for(var _h=0;_h<hp;_h++)draw_rectangle(x-8+_h*6,y-58,x-4+_h*6,y-54,false);
draw_set_color(c_white);
