if(global.game_state!="play")exit;
// Three hovering poses, then two attack poses; the source has five unequal cells.
var _frame=(state==0?(global.game_timer div 9) mod 3:3+(global.game_timer div 7) mod 2);
scr_blue_enemy_draw(_frame,x,y);
draw_set_color(make_color_rgb(232,168,122));
for(var _h=0;_h<hp;_h++)draw_rectangle(x-8+_h*6,y-39,x-4+_h*6,y-35,false);
draw_set_color(c_white);
