if(global.game_state!="play" && global.game_state!="pause")exit;
// Foguinho spawner: cracked rock (spr_foguinho_rock, centred on x,y) with a slow pulse and tilt.
var _t=global.game_timer+real(id)*3;
var _s=0.105+sin(_t*0.08)*0.006;
draw_sprite_ext(spr_foguinho_rock,0,round(x),round(y-6),_s,_s,sin(_t*0.04)*4,c_white,1);
draw_set_color(c_white);
