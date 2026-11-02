if(global.game_state!="play" && global.game_state!="pause")exit;
// Sheets: spr_skel_spawn_sheet / spr_skel_cast_sheet, 128x112 cells, body centre x=56, feet y=108.
var _cw=128,_ch=112,_ax=56,_ay=108;
draw_set_alpha(0.3);draw_set_color(c_black);draw_ellipse(x-22,y-3,x+22,y+4,false);draw_set_alpha(1);
var _left=(face>=0?x-_ax:x+_ax);
var _top=y-_ay;
if(state==0) {
    // Materialise: sparks, burst, golden ring, dark rune.
    var _order=[3,2,1,0];
    var _f=_order[min(3,anim_t div 9)];
    draw_sprite_part_ext(spr_skel_spawn_sheet,0,_f*_cw,0,_cw,_ch,round(_left),round(_top),face,1,c_white,1);
} else {
    var _f=0;
    if(state==2) _f=(cast_t<18?1:(cast_t<30?2:3));
    var _bob=(state==1?round(sin(phase*2)*1):0);
    draw_sprite_part_ext(spr_skel_cast_sheet,0,_f*_cw,0,_cw,_ch,round(_left),round(_top+_bob),face,1,c_white,1);
}
draw_set_color(c_white);
