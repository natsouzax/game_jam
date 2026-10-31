// The background is drawn in the camera's view with a four-pixel visual grid.
// Progress follows the actual mean height of the active players, not room bands.
var _sum_y=0, _players=0;
for (var _pi=0; _pi<2; _pi++) {
    var _actor=instance_find(_pi==0 ? obj_player_p1 : obj_player_p2,0);
    if (_actor!=noone && _actor.active_player) { _sum_y+=_actor.y; _players++; }
}
var _height=clamp((1408-(_players>0 ? _sum_y/_players : camera_y+600))/960,0,1);
var _phase=_height*4;
var _band=min(3,floor(_phase));
var _blend=clamp(_phase-_band,0,1);
_blend=_blend*_blend*(3-2*_blend);
var _top=[make_color_rgb(53,42,58),make_color_rgb(69,80,105),make_color_rgb(28,39,69),make_color_rgb(12,18,39),make_color_rgb(47,54,89)];
var _bottom=[make_color_rgb(126,87,77),make_color_rgb(132,131,139),make_color_rgb(63,73,102),make_color_rgb(26,34,59),make_color_rgb(151,150,164)];
var _ct=merge_color(_top[_band],_top[_band+1],_blend);
var _cb=merge_color(_bottom[_band],_bottom[_band+1],_blend);
var _vy=camera_y;
// A stepped gradient keeps the image crisp rather than filtering the pixels.
for (var _row=0; _row<24; _row++) {
    draw_set_color(merge_color(_ct,_cb,_row/23));
    draw_rectangle(0,_vy+_row*32,1366,_vy+(_row+1)*32,false);
}
var _ruins=1-clamp((_height-0.12)/0.28,0,1);
var _clouds=clamp((_height-0.10)/0.14,0,1)*(1-clamp((_height-0.39)/0.18,0,1));
var _stars=clamp((_height-0.38)/0.18,0,1);
var _divine=clamp((_height-0.76)/0.20,0,1);
var _tick=global.game_timer;
// Distant skyline and drifting smoke, behind the playable tower.
if (_ruins>0) {
    draw_set_alpha(_ruins);
    // Broken roofs, exposed floors and scattered rubble form a ruined skyline.
    for (var _building=0; _building<20; _building++) {
        var _bx=_building*76-20, _bh=92+(_building*53 mod 168), _base=_vy+768;
        var _roof=_base-_bh;
        draw_set_color(make_color_rgb(43+(_building mod 3)*5,37,45));
        draw_rectangle(_bx,_roof+24,_bx+56,_base,false);
        draw_rectangle(_bx,_roof+12,_bx+16,_roof+28,false);
        draw_rectangle(_bx+32,_roof,_bx+48,_roof+28,false);
        draw_rectangle(_bx+36,_roof-20,_bx+40,_roof+4,false);
        draw_set_color(make_color_rgb(84,65,65));
        for (var _w=0; _w<4; _w++) {
            var _wy=_roof+40+_w*36;
            if (_wy<_base-12) {
                draw_rectangle(_bx+8,_wy,_bx+16,_wy+12,false);
                if ((_building+_w) mod 3!=0) draw_rectangle(_bx+36,_wy,_bx+44,_wy+12,false);
            }
        }
        draw_set_color(make_color_rgb(28,29,37));
        draw_rectangle(_bx+20,_roof+28,_bx+24,_roof+48,false);
        draw_rectangle(_bx+20,_roof+44,_bx+36,_roof+48,false);
        draw_rectangle(_bx-8,_base-12,_bx+12,_base,false);
        draw_rectangle(_bx+52,_base-20,_bx+68,_base,false);
    }
    // Low-contrast smoke columns and embers remain behind the action.
    for (var _plume=0; _plume<5; _plume++) {
        var _px=100+_plume*288, _drift=4*floor((_tick/28+_plume*13) mod 24);
        draw_set_alpha(_ruins*0.32);
        draw_set_color(make_color_rgb(44,38,44));
        for (var _puff=0; _puff<5; _puff++) {
            var _py=_vy+704-_puff*40-(_drift mod 40);
            var _offset=4*floor(sin(_puff+_plume)*3);
            draw_rectangle(_px+_offset-_puff*4,_py,_px+_offset+32+_puff*4,_py+20,false);
            draw_rectangle(_px+_offset+4-_puff*4,_py-8,_px+_offset+24+_puff*4,_py+24,false);
        }
        draw_set_alpha(_ruins*0.55);
        draw_set_color(make_color_rgb(171,88,56));
        draw_rectangle(_px+8,_vy+748,_px+36,_vy+756,false);
        draw_rectangle(_px+16,_vy+740,_px+24,_vy+752,false);
    }
    draw_set_alpha(_ruins*0.6);
    draw_set_color(make_color_rgb(131,105,99));
    for (var _s=0; _s<11; _s++) {
        var _sx=(_s*137+floor(_tick/9)) mod 1400-20;
        var _sy=_vy+440+((_s*67-floor(_tick/12)) mod 240+240) mod 240;
        draw_rectangle(_sx,_sy,_sx+12,_sy+4,false);
        draw_rectangle(_sx+4,_sy-4,_sx+20,_sy,false);
    }
}
// Sparse stars remain behind objects; brightness changes without moving the grid.
if (_stars>0) {
    for (var _st=0; _st<75; _st++) {
        var _starx=4*((_st*103+17) mod 341), _stary=_vy+4*((_st*71+31) mod 183);
        var _twinkle=0.35+0.45*(0.5+0.5*sin(_tick*0.035+_st*2));
        draw_set_alpha(_stars*_twinkle*(1-_divine*0.55));
        draw_set_color((_st mod 7==0)?make_color_rgb(219,198,165):make_color_rgb(166,179,194));
        draw_rectangle(_starx,_stary,_starx+4,_stary+4,false);
        if (_st mod 13==0) draw_rectangle(_starx-4,_stary+1,_starx+8,_stary+3,false);
    }
}
// Chunky, slowly drifting cloud banks and the impossible luminous sea above space.
var _cloud_alpha=max(_clouds*0.45,_divine*0.8);
if (_cloud_alpha>0) {
    draw_set_alpha(_cloud_alpha);
    for (var _c=0; _c<16; _c++) {
        var _cx=4*floor((((_c*113+floor(_tick/15)) mod 1560)-100)/4);
        var _cy=_vy+4*floor((430+(_c*61 mod 260))/4);
        var _col=merge_color(make_color_rgb(143,148,156),make_color_rgb(228,212,185),_divine);
        draw_set_color(_col);
        draw_rectangle(_cx,_cy,_cx+116,_cy+20,false);
        draw_rectangle(_cx+20,_cy-12,_cx+88,_cy+20,false);
        draw_rectangle(_cx+36,_cy-20,_cx+68,_cy+20,false);
        if (_divine>0) {
            draw_set_alpha(_divine*0.35);
            draw_set_color(make_color_rgb(255,239,196));
            draw_rectangle(_cx+20,_cy-12,_cx+88,_cy-8,false);
            draw_set_alpha(_cloud_alpha);
        }
    }
}
draw_set_alpha(1);
draw_set_color(make_color_rgb(151,118,79));
for(var _j=0;_j<5;_j++) {
    var _y=1216-_j*192;
    draw_circle(672,_y-50,10,true);
    draw_triangle(665,_y-75,679,_y-75,672,_y-84,false);
}
if(global.game_state=="ending") {
    var _amount=clamp((ending_timer-500)/120,0,1);
    draw_set_color(make_color_rgb(108,185,108));
    for(var _k=0;_k<instance_number(obj_build_block);_k++) {
        var _b=instance_find(obj_build_block,_k);
        draw_line_width(_b.x+8,_b.y,_b.x+8,_b.y-22*_amount,3);
        draw_ellipse(_b.x+5,_b.y-20*_amount,_b.x+20,_b.y-10*_amount,false);
    }
}
draw_set_color(c_white);

