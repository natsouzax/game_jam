if(global.game_state!="play" && global.game_state!="pause")exit;
// Dark ooze creature: 4-frame walk cycle (spr_slime_sheet, 176x148 per cell, faces right).
var _cw=176, _ch=148, _s=0.5;
var _t=global.game_timer;
var _frame=((_t+anim_seed) div 9) mod 4;
var _breathe=sin(_t*0.18+anim_seed);
var _sx=_s*(1-0.025*_breathe), _sy=_s*(1+0.04*_breathe);
var _feet=y+2;
var _face=(dir<0?-1:1);
// Spawn: the slime claws its way up out of the ground (only the top part is visible, growing each frame).
if(spawn_t>0) {
    var _k=1-spawn_t/spawn_total;
    var _e=_k*_k*(3-2*_k);
    var _vis=max(10,round(_ch*_e));
    // Rises in four hunched stages: bump, head, shoulders, full body.
    var _stage=min(3,floor(_k*4));
    var _fr=(_stage>=2?2:0);
    var _w=_s*(0.8+0.2*_e);
    var _left0=x-_face*_cw*_w*0.5;
    draw_sprite_part_ext(spr_slime_sheet,0,_fr*_cw,0,_cw,_vis,round(_left0),round(_feet+2-_vis*_w),_face*_w,_w,c_white,1);
    // dirt and ooze specks kicked up around the hole
    draw_set_color(make_color_rgb(34,40,30));
    for(var _d=0;_d<8;_d++) {
        var _dx=random_range(-34,34)*(0.5+_e);
        var _dy=-random_range(2,10+40*_e)*(_d mod 2==0?1:0.5);
        draw_rectangle(round(x+_dx),round(_feet+_dy),round(x+_dx)+2,round(_feet+_dy)+2,false);
    }
    draw_set_color(c_white);
    exit;
}
// soft ground shadow
draw_set_alpha(0.32);draw_set_color(c_black);
draw_ellipse(x-36,_feet-4,x+36,_feet+6,false);
draw_set_alpha(1);
// faint toxic aura behind the body
gpu_set_blendmode(bm_add);
draw_set_alpha(0.10+0.04*_breathe);draw_set_color(make_color_rgb(70,190,150));
draw_ellipse(x-44,_feet-_ch*_sy*0.85,x+44,_feet+2,false);
draw_set_alpha(1);
gpu_set_blendmode(bm_normal);
// sprite (flipped when walking left)
var _left=x-_face*_cw*_sx*0.5;
draw_sprite_part_ext(spr_slime_sheet,0,_frame*_cw,0,_cw,_ch,round(_left),round(_feet+2-_ch*_sy),_face*_sx,_sy,c_white,1);
draw_set_color(c_white);
