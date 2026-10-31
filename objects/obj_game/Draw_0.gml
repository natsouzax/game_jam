var _floor=scr_floor_y();
var _finish=220;
var _sum_y=0;
var _count=0;
for (var _pi=0; _pi<2; _pi++) {
    var _actor=instance_find((_pi==0?obj_player_p1:obj_player_p2),0);
    if (_actor!=noone && _actor.active_player && !_actor.dead) {
        _sum_y+=_actor.y;
        _count++;
    }
}
var _mean_y=(_count>0?_sum_y/_count:camera_y+384);
var _climb=clamp((_floor-_mean_y)/max(1,_floor-_finish),0,1);
var _altitude=_climb;
if (room==Room2) _altitude=lerp(0.72,1,_climb);
altitude=_altitude;

var _tick=global.game_timer;
var _vy=camera_y;
var _sky_top=[
    make_color_rgb(48,35,49),
    make_color_rgb(72,84,112),
    make_color_rgb(22,34,66),
    make_color_rgb(7,11,28),
    make_color_rgb(50,54,98)
];
var _sky_bottom=[
    make_color_rgb(126,83,70),
    make_color_rgb(168,164,166),
    make_color_rgb(58,76,116),
    make_color_rgb(20,27,52),
    make_color_rgb(180,158,132)
];
var _phase=_altitude*4;
var _band=min(3,floor(_phase));
var _blend=_phase-_band;
_blend=_blend*_blend*(3-2*_blend);
var _ct=merge_color(_sky_top[_band],_sky_top[_band+1],_blend);
var _cb=merge_color(_sky_bottom[_band],_sky_bottom[_band+1],_blend);
for (var _row=0; _row<24; _row++) {
    draw_set_color(merge_color(_ct,_cb,_row/23));
    draw_rectangle(0,_vy+_row*32,room_width,_vy+(_row+1)*32,false);
}

var _sun_fade=1-clamp((_altitude-0.22)/0.28,0,1);
if (_sun_fade>0) {
    var _sun_y=_vy+560+_altitude*260;
    draw_set_alpha(0.85*_sun_fade);
    draw_set_color(make_color_rgb(255,186,110));
    draw_circle(980,_sun_y,34+_altitude*10,false);
    draw_set_alpha(0.18*_sun_fade);
    draw_circle(980,_sun_y,70+_altitude*18,false);
}
draw_set_alpha(1);

var _ruins=1-clamp((_altitude-0.10)/0.28,0,1);
if (_ruins>0) {
    draw_set_alpha(_ruins);
    var _base=_floor;
    for (var _building=0; _building<20; _building++) {
        var _bx=_building*76-20;
        var _bh=92+(_building*53 mod 168);
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
    for (var _plume=0; _plume<5; _plume++) {
        var _px=100+_plume*288;
        var _drift=4*floor((_tick/28+_plume*13) mod 24);
        draw_set_alpha(_ruins*0.32);
        draw_set_color(make_color_rgb(44,38,44));
        for (var _puff=0; _puff<5; _puff++) {
            var _py=_base-64-_puff*40-(_drift mod 40);
            var _offset=4*floor(sin(_puff+_plume)*3);
            draw_rectangle(_px+_offset-_puff*4,_py,_px+_offset+32+_puff*4,_py+20,false);
            draw_rectangle(_px+_offset+4-_puff*4,_py-8,_px+_offset+24+_puff*4,_py+24,false);
        }
        draw_set_alpha(_ruins*0.55);
        draw_set_color(make_color_rgb(171,88,56));
        draw_rectangle(_px+8,_base-20,_px+36,_base-12,false);
        draw_rectangle(_px+16,_base-28,_px+24,_base-16,false);
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

var _stars=clamp((_altitude-0.36)/0.18,0,1);
if (_stars>0) {
    for (var _st=0; _st<90; _st++) {
        var _starx=4*((_st*103+17) mod 341);
        var _stary=_vy+4*((_st*71+31) mod 183);
        var _twinkle=0.35+0.45*(0.5+0.5*sin(_tick*0.035+_st*2));
        draw_set_alpha(_stars*_twinkle*(1-clamp((_altitude-0.76)/0.20,0,1)*0.45));
        draw_set_color((_st mod 7==0)?make_color_rgb(219,198,165):make_color_rgb(166,179,194));
        draw_rectangle(_starx,_stary,_starx+4,_stary+4,false);
        if (_st mod 13==0) draw_rectangle(_starx-4,_stary+1,_starx+8,_stary+3,false);
    }
}

var _clouds=clamp((_altitude-0.10)/0.14,0,1)*(1-clamp((_altitude-0.40)/0.18,0,1));
var _divine=clamp((_altitude-0.76)/0.20,0,1);
var _cloud_alpha=max(_clouds*0.5,_divine*0.85);
if (_cloud_alpha>0) {
    var _cloud_base=lerp(430,120,_divine);
    for (var _c=0; _c<16; _c++) {
        var _cx=4*floor((((_c*113+floor(_tick/15)) mod 1560)-100)/4);
        var _cy=_vy+4*floor((_cloud_base+(_c*61 mod 260))/4);
        var _col=merge_color(make_color_rgb(143,148,156),make_color_rgb(232,214,186),_divine);
        draw_set_alpha(_cloud_alpha);
        draw_set_color(_col);
        draw_rectangle(_cx,_cy,_cx+116,_cy+20,false);
        draw_rectangle(_cx+20,_cy-12,_cx+88,_cy+20,false);
        draw_rectangle(_cx+36,_cy-20,_cx+68,_cy+20,false);
        if (_divine>0) {
            draw_set_alpha(_divine*0.35);
            draw_set_color(make_color_rgb(255,239,196));
            draw_rectangle(_cx+20,_cy-12,_cx+88,_cy-8,false);
            draw_rectangle(_cx+36,_cy-20,_cx+68,_cy-16,false);
        }
    }
}
draw_set_alpha(1);

var _space=clamp((_altitude-0.55)/0.20,0,1)*(1-_divine*0.65);
if (_space>0) {
    draw_set_alpha(_space*0.12);
    draw_set_color(make_color_rgb(64,72,140));
    for (var _n=0; _n<5; _n++) {
        var _nx=4*floor((_n*280-120+sin(_tick/300+_n)*40)/4);
        var _ny=_vy+80+_n*130;
        draw_rectangle(_nx,_ny,_nx+320,_ny+28,false);
        draw_rectangle(_nx+40,_ny-12,_nx+280,_ny+40,false);
    }
    draw_set_alpha(_space*0.18);
    draw_set_color(make_color_rgb(96,74,130));
    for (var _n2=0; _n2<4; _n2++) {
        var _nx2=4*floor((_n2*330+60-sin(_tick/340+_n2)*50)/4);
        var _ny2=_vy+200+_n2*110;
        draw_rectangle(_nx2,_ny2,_nx2+260,_ny2+20,false);
    }
    draw_set_alpha(1);
}

var _planet=clamp((_altitude-0.60)/0.15,0,1)*(1-clamp((_altitude-0.92)/0.08,0,1));
if (_planet>0) {
    var _px2=1090;
    var _py2=_vy+190;
    draw_set_alpha(_planet*0.8);
    draw_set_color(make_color_rgb(38,46,84));
    draw_circle(_px2,_py2,64,false);
    draw_set_color(make_color_rgb(58,70,116));
    draw_circle(_px2-8,_py2-8,54,false);
    draw_set_alpha(_planet*0.45);
    draw_set_color(make_color_rgb(86,102,150));
    draw_rectangle(_px2-58,_py2-18,_px2+58,_py2-10,false);
    draw_rectangle(_px2-50,_py2+8,_px2+50,_py2+16,false);
    draw_rectangle(_px2-38,_py2+30,_px2+38,_py2+36,false);
    draw_set_alpha(1);
}

if (_divine>0) {
    gpu_set_blendmode(bm_add);
    draw_set_color(make_color_rgb(255,226,160));
    for (var _r=0; _r<6; _r++) {
        var _a=sin(_tick/90+_r*1.7)*4;
        draw_set_alpha(_divine*0.05);
        draw_triangle(683+_a,_vy-60,380+_r*120,_vy+520,460+_r*120,_vy+520,false);
    }
    draw_set_alpha(_divine*0.20);
    draw_circle(683,_vy+80,120+sin(_tick/40)*4,false);
    draw_set_color(make_color_rgb(255,232,170));
    for (var _m=0; _m<18; _m++) {
        var _ph=_tick*0.004+_m*0.13; _ph=_ph-floor(_ph);
        var _mx=4*floor((120+((_m*97) mod 1120)+sin(_tick/70+_m)*10)/4);
        var _my=_vy+4*floor((720-_ph*640)/4);
        draw_set_alpha(_divine*(0.20+0.25*sin(_ph*pi)));
        draw_rectangle(_mx,_my,_mx+4,_my+4,false);
    }
    draw_set_alpha(1);
    gpu_set_blendmode(bm_normal);
}
draw_set_alpha(1);

if (global.game_state == "ending") {
    var _amount = clamp(ending_timer / 180, 0, 1);
    draw_set_color(make_color_rgb(108,185,108));
    for (var _k = 0; _k < instance_number(obj_build_block); _k++) {
        var _b = instance_find(obj_build_block, _k);
        draw_line_width(_b.x + 8, _b.y, _b.x + 8, _b.y - 22 * _amount, 3);
        draw_ellipse(_b.x + 5, _b.y - 20 * _amount, _b.x + 20, _b.y - 10 * _amount, false);
    }
}
draw_set_alpha(1);
draw_set_color(c_white);

// The ground strip comes from the room layer; the foreground chasm is drawn over it in Draw GUI.

