if(global.game_state!="play" && global.game_state!="pause" && global.game_state!="ending")exit;
// spr_god_sheet: 10 cells of 124x167. 0-5 walk cycle, 6/8/9 crouch, 7 jump (celebration).
var _cw=124,_ch=167,_s=0.5;
var _t=global.game_timer;
var _frame,_hop=0;
if(excited || reached) {
    _frame=7;_hop=-abs(sin(_t*0.12))*10;      // arms-up hop of joy
} else {
    _frame=(_t div 9) mod 6;                  // slow walk while pacing
}
// glow + shadow
gpu_set_blendmode(bm_add);
draw_set_alpha(0.16+0.05*sin(_t*0.06));draw_set_color(make_color_rgb(255,220,140));
draw_circle(x,y-40,46,false);draw_set_alpha(1);
gpu_set_blendmode(bm_normal);
draw_set_alpha(0.3);draw_set_color(c_black);draw_ellipse(x-18,y-3,x+18,y+3,false);draw_set_alpha(1);
var _left=x-face*_cw*_s*0.5;
draw_sprite_part_ext(spr_god_sheet,0,_frame*_cw,0,_cw,_ch,round(_left),round(y+2+_hop-_ch*_s),face*_s,_s,c_white,1);
draw_set_color(c_white);
