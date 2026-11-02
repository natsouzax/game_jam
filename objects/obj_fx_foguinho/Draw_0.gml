if(global.game_state!="play" && global.game_state!="pause")exit;
// Frame 1 = burst, 2 = shards flying, 3 = fading sparks; each holds 9 ticks.
var _f=min(2,age div 9);
var _s=0.24+_f*0.03;
draw_sprite_part_ext(spr_foguinho_explosion,0,_f*480,0,480,480,round(x-240*_s),round(y-240*_s),_s,_s,c_white,(_f==2?1-(age-18)/9:1));
draw_set_alpha(1);draw_set_color(c_white);
