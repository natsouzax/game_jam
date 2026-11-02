if(global.game_state!="play" && global.game_state!="pause")exit;
if(spawn_t>0) {
    // Cracked rock shakes and fades while the flame grows out of it.
    var _k=1-spawn_t/spawn_total;
    var _sh=(1-_k)*2;
    var _rs=0.1+0.04*_k;
    draw_sprite_ext(spr_foguinho_rock,0,round(x+random_range(-_sh,_sh)),round(y+random_range(-_sh,_sh)),_rs,_rs,0,c_white,1-_k*_k);
    if(_k>0.4) {
        draw_set_alpha((_k-0.4)/0.6);
        scr_blue_enemy_draw(0,x,y);
        draw_set_alpha(1);
    }
    exit;
}
// Three hovering poses, then two attack poses; the source has five unequal cells.
var _frame=(state==0?(global.game_timer div 9) mod 3:3+(global.game_timer div 7) mod 2);
scr_blue_enemy_draw(_frame,x,y);
draw_set_color(make_color_rgb(232,168,122));
for(var _h=0;_h<hp;_h++)draw_rectangle(x-8+_h*6,y-39,x-4+_h*6,y-35,false);
draw_set_color(c_white);
