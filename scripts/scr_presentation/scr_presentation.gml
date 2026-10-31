// Presentation and participant selection; physics remains in scr_mvp.
function scr_actor_pose(_actor,_pose,_x,_feet,_height,_facing,_alpha=1) {
    // Measured alpha bounds, not uniform cells. Source PNG is preserved unchanged.
    static _poses=[
        [[143,73,318,395],[491,73,689,395],[842,73,1039,395],[1179,49,1376,355]],
        [[152,444,356,758],[498,443,700,758],[843,443,1050,758],[1194,432,1395,722]],
        [[156,809,335,948],[491,797,678,948],[849,809,1034,948],[1180,778,1428,956]]
    ];
    var _r=_poses[_actor][_pose];var _w=_r[2]-_r[0];var _h=_r[3]-_r[1];
    var _scale=_height/(_poses[_actor][0][3]-_poses[_actor][0][1]);
    draw_sprite_part_ext(spr_juntos_atlas,0,_r[0],_r[1],_w,_h,
        round(_x-_facing*_w*_scale/2),round(_feet-_h*_scale),_scale*_facing,_scale,c_white,_alpha);
}

function scr_menu_idle(_actor,_x,_feet,_height,_facing) {
    // Tiny breathing cycle, offset between characters so the menu stays alive.
    var _time=global.game_timer+_actor*31;
    var _breath=sin(_time*0.075);
    scr_actor_pose(_actor,0,_x+round(sin(_time*0.038)),_feet+round(sin(_time*0.075+1)*1.5),
        _height+_breath*3,_facing);
}

// Final cutscene, 4780 frames at 60 FPS. 2D cinematic pass: parallax depth, additive light, particles, letterbox.
function scr_cut_ease(_x) {
    _x=clamp(_x,0,1);
    return _x*_x*(3-2*_x);
}

function scr_cut_rand(_n) {
    var _v=sin(_n*12.9898)*43758.5453;
    return _v-floor(_v);
}

// Soft light: stacked additive discs, no texture needed.
function scr_cut_glow(_x,_y,_r,_col,_alpha) {
    if(_alpha<=0)return;
    gpu_set_blendmode(bm_add);
    draw_set_color(_col);
    for(var _i=0;_i<16;_i++) {
        draw_set_alpha(_alpha*(0.012+0.006*_i));
        draw_circle(_x,_y,_r*(1-_i*0.06),false);
    }
    draw_set_alpha(1);
    gpu_set_blendmode(bm_normal);
}

// Deterministic drifting specks (embers, dust, fireflies) so no particle state is stored.
function scr_cut_motes(_t,_count,_x0,_y0,_w,_h,_col,_speed,_seed,_a) {
    if(_a<=0)return;
    gpu_set_blendmode(bm_add);
    draw_set_color(_col);
    for(var _i=0;_i<_count;_i++) {
        var _n=_i+_seed*97;
        var _ph=_t*_speed/300+scr_cut_rand(_n);
        _ph=_ph-floor(_ph);
        var _x=_x0+scr_cut_rand(_n+1.3)*_w+sin(_t/40+_i)*14;
        var _y=_y0+_h-_ph*_h;
        var _sz=(_i mod 3==0?3:2);
        draw_set_alpha(sin(_ph*pi)*0.85*_a);
        draw_rectangle(_x,_y,_x+_sz,_y+_sz,false);
    }
    draw_set_alpha(1);
    gpu_set_blendmode(bm_normal);
}

function scr_cut_shadow(_x,_y,_w,_alpha) {
    draw_set_alpha(_alpha);draw_set_color(make_color_rgb(10,12,20));
    draw_ellipse(_x-_w/2,_y-_w*0.07,_x+_w/2,_y+_w*0.07,false);
    draw_set_alpha(1);
}

function scr_cut_actor(_which,_x,_feet,_height,_face=1) {
    var _moving=(global.game_state=="ending") &&
        ((ending_timer<85) || (ending_timer>=440 && ending_timer<780));
    var _pose=(_moving?1+(ending_timer div 14) mod 2:0);
    scr_cut_shadow(_x,_feet,_height*0.62,0.38);
    var _step=(_moving?round(abs(sin(ending_timer/7))*3):0);
    scr_actor_pose(_which,_pose,_x,_feet-_step,_height,_face);
}

function scr_cut_civilian(_id,_x,_feet,_height,_lean=0) {
    static _parts=[[120,180,275,700],[470,45,335,825],[920,190,285,690],[1320,25,345,845]];
    var _r=_parts[_id];var _scale=_height/_r[3];
    var _bob=(_lean==0?0:round(3*sin(ending_timer/9+_id)));
    scr_cut_shadow(_x+_lean,_feet,_r[2]*_scale*0.8,0.34);
    draw_sprite_part_ext(spr_cut_people,0,_r[0],_r[1],_r[2],_r[3],
        round(_x-_r[2]*_scale*0.5+_lean),round(_feet-_height+_bob),_scale,_scale,c_white,1);
}

function scr_cut_plant(_x,_y,_size,_glow=0) {
    var _sway=sin(ending_timer/22+_x*0.05)*_size*0.06;
    if(_glow>0)scr_cut_glow(_x,_y-_size*0.6,_size*1.5+18,make_color_rgb(190,255,160),_glow);
    draw_set_color(make_color_rgb(58,41,36));draw_ellipse(_x-_size*0.45-9,_y-4,_x+_size*0.45+9,_y+7,false);
    draw_set_color(make_color_rgb(88,60,46));draw_ellipse(_x-_size*0.3-5,_y-5,_x+_size*0.3+5,_y+2,false);
    var _tx=_x+_sway*2;var _ty=_y-_size;
    draw_set_color(make_color_rgb(69,128,76));draw_line_width(_x,_y-2,_tx,_ty,max(2,round(_size*0.09)));
    draw_set_color(make_color_rgb(86,158,92));
    draw_triangle(_x+_sway,_y-_size*0.5,_x-_size*0.95+_sway,_y-_size*0.9,_x-_size*0.2+_sway,_y-_size*0.28,false);
    draw_triangle(_tx,_y-_size*0.78,_x+_size*0.95+_sway*2,_y-_size*1.18,_x+_size*0.25+_sway,_y-_size*0.46,false);
    draw_set_color(make_color_rgb(168,224,130));
    draw_triangle(_tx,_ty+2,_tx-_size*0.3,_ty-_size*0.28,_tx+1,_ty-_size*0.05,false);
    draw_triangle(_tx,_ty+2,_tx+_size*0.3,_ty-_size*0.22,_tx-1,_ty-_size*0.05,false);
    draw_line_width(_x+_sway,_y-_size*0.5,_x-_size*0.55+_sway,_y-_size*0.7,1);
}

function scr_cut_chunk(_x,_y,_w,_h) {
    draw_set_color(make_color_rgb(30,34,43));draw_rectangle(_x,_y-_h,_x+_w,_y,false);
    draw_set_color(make_color_rgb(58,64,78));draw_rectangle(_x,_y-_h,_x+_w,_y-_h*0.62,false);
    draw_set_color(make_color_rgb(170,104,70));draw_rectangle(_x,_y-_h,_x+_w,_y-_h+max(1,_h*0.08),false);
}

function scr_cut_rubble(_x,_y,_scale) {
    var _s=_scale;
    scr_cut_shadow(_x+38*_s,_y,90*_s,0.3);
    scr_cut_chunk(_x,_y,46*_s,24*_s);
    scr_cut_chunk(_x+34*_s,_y,40*_s,34*_s);
    scr_cut_chunk(_x+14*_s,_y-22*_s,30*_s,20*_s);
}

// The deity: a hovering robe of light with a halo. Arm snaps (frame ~125), then points to the seedling.
function scr_cut_deity(_t) {
    var _fade=scr_cut_ease(_t/55)*scr_cut_ease((360-_t)/44);
    if(_fade<=0)return;
    var _cx=683;var _cy=205+round(6*sin(_t/20));
    var _gold=make_color_rgb(255,214,140);var _pale=make_color_rgb(255,244,204);var _sleeve=make_color_rgb(255,232,178);
    scr_cut_glow(_cx,_cy+10,150,_gold,_fade*0.55);
    gpu_set_blendmode(bm_add);draw_set_color(make_color_rgb(255,226,160));draw_set_alpha(_fade*0.05);
    for(var _r=0;_r<10;_r++) {
        var _a=_r*36+_t*0.35;
        draw_triangle(_cx,_cy,_cx+lengthdir_x(440,_a-3),_cy+lengthdir_y(440,_a-3),_cx+lengthdir_x(440,_a+3),_cy+lengthdir_y(440,_a+3),false);
    }
    draw_set_alpha(1);gpu_set_blendmode(bm_normal);
    // Robe: horizontal slices that widen and sway, fading toward the hem.
    draw_primitive_begin(pr_trianglestrip);
    for(var _s=0;_s<=22;_s++) {
        var _half=14+_s*2.6+sin(_t/14-_s*0.5)*(1+_s*0.35);
        var _sway=sin(_t/18-_s*0.28)*_s*0.9;
        var _rc=merge_colour(_pale,make_color_rgb(255,196,120),_s/22);
        var _ra=_fade*(1-_s/24);
        draw_vertex_colour(_cx-_half+_sway,_cy+10+_s*8,_rc,_ra);
        draw_vertex_colour(_cx+_half+_sway,_cy+10+_s*8,_rc,_ra);
    }
    draw_primitive_end();
    draw_set_alpha(_fade);draw_set_color(_pale);
    draw_ellipse(_cx-36,_cy-4,_cx+36,_cy+40,false);
    draw_circle(_cx,_cy-24,26,false);
    draw_set_color(make_color_rgb(255,226,170));draw_circle(_cx,_cy-24,19,false);
    gpu_set_blendmode(bm_add);draw_set_color(_gold);draw_set_alpha(_fade*0.7);
    draw_circle(_cx,_cy-24,46+sin(_t/12)*2,true);draw_circle(_cx,_cy-24,47+sin(_t/12)*2,true);
    draw_set_alpha(1);gpu_set_blendmode(bm_normal);
    // Arms: right raises for the snap, both open empty (he can show the city but will not rebuild it), then he points at them.
    var _po=scr_cut_ease((_t-205)/20);
    var _pp=scr_cut_ease((_t-244)/20);
    var _ex=lerp(lerp(_cx+78,_cx+76,_po),_cx+84,_pp);var _ey=lerp(lerp(_cy-20,_cy+32,_po),_cy+54,_pp);
    var _hx=lerp(lerp(_cx+105,_cx+112,_po),_cx+120,_pp);var _hy=lerp(lerp(_cy-62,_cy+76,_po),_cy+122,_pp);
    var _lo=_po*(1-_pp);
    var _lex=lerp(_cx-62,_cx-76,_lo);var _ley=lerp(_cy+70,_cy+34,_lo);
    var _lhx=lerp(_cx-52,_cx-112,_lo);var _lhy=lerp(_cy+112,_cy+76,_lo);
    if(_t>=118 && _t<132){_hx+=(_t mod 2==0?3:-3);_hy+=(_t mod 2==0?-2:2);}
    draw_set_alpha(_fade);draw_set_color(_sleeve);
    draw_line_width(_cx-34,_cy+8,_lex,_ley,15);draw_line_width(_lex,_ley,_lhx,_lhy,11);
    draw_line_width(_cx+34,_cy+8,_ex,_ey,15);draw_line_width(_ex,_ey,_hx,_hy,11);
    draw_circle(_hx,_hy,8,false);draw_circle(_lhx,_lhy,8,false);
    draw_set_alpha(1);
    // Snap: expanding ring and a star burst at the raised hand.
    var _k=_t-125;
    if(_k>=0 && _k<50) {
        gpu_set_blendmode(bm_add);draw_set_color(make_color_rgb(255,242,197));
        draw_set_alpha(1-_k/50);
        for(var _o=0;_o<3;_o++)draw_circle(_hx,_hy,_k*9+_o,true);
        if(_k<22)for(var _a2=0;_a2<8;_a2++) {
            var _ang=_a2*45+_k*2;
            draw_line_width(_hx+lengthdir_x(14,_ang),_hy+lengthdir_y(14,_ang),_hx+lengthdir_x(40+_k*4,_ang),_hy+lengthdir_y(40+_k*4,_ang),4);
        }
        draw_set_alpha(1);gpu_set_blendmode(bm_normal);
    }
    // Pointing: first at the left player, then the right one, then the seedling they must tend.
    if(_t>=250) {
        var _txs=[470,930,697];var _tys=[585,585,672];
        var _ti=(_t<284?0:(_t<318?1:2));
        var _from=max(_ti-1,0);
        var _sw=(_ti==0?1:scr_cut_ease((_t-(_ti==1?284:318))/10));
        var _tx=lerp(_txs[_from],_txs[_ti],_sw);var _ty=lerp(_tys[_from],_tys[_ti],_sw);
        var _b=scr_cut_ease((_t-250)/16)*_fade;
        gpu_set_blendmode(bm_add);draw_set_color(make_color_rgb(255,226,160));
        draw_set_alpha(_b*(0.12+0.03*sin(_t/6)));
        draw_triangle(_hx-4,_hy,_tx-30,_ty,_tx+30,_ty,false);
        draw_set_alpha(1);gpu_set_blendmode(bm_normal);
        scr_cut_glow(_tx,_ty-20,56,_gold,_b*0.5);
    }
    scr_cut_motes(_t,28,_cx-150,_cy-130,300,460,_gold,1.1,1,_fade);
}

// Small deity silhouette: mode 0 points out of the screen at the viewer, mode 1 stands with open arms.
function scr_cut_deity_icon(_x,_y,_s,_a,_mode) {
    if(_a<=0)return;
    var _gold=make_color_rgb(255,214,140);var _pale=make_color_rgb(255,244,204);
    scr_cut_glow(_x,_y,150*_s,_gold,_a*0.6);
    draw_set_alpha(_a);draw_set_color(_pale);
    draw_circle(_x,_y-60*_s,16*_s,false);
    draw_triangle(_x,_y-40*_s,_x-34*_s,_y+70*_s,_x+34*_s,_y+70*_s,false);
    draw_ellipse(_x-22*_s,_y-44*_s,_x+22*_s,_y-18*_s,false);
    if(_mode==0) {
        draw_line_width(_x+14*_s,_y-30*_s,_x+4*_s,_y+4*_s,9*_s);
        draw_circle(_x+3*_s,_y+8*_s,10*_s,false);
        gpu_set_blendmode(bm_add);draw_set_alpha(_a*0.5);draw_circle(_x+3*_s,_y+8*_s,20*_s,false);gpu_set_blendmode(bm_normal);
    } else {
        draw_line_width(_x-16*_s,_y-30*_s,_x-50*_s,_y-8*_s,9*_s);
        draw_line_width(_x+16*_s,_y-30*_s,_x+50*_s,_y-8*_s,9*_s);
    }
    draw_set_alpha(1);
}

function scr_cut_game(_t) {
    var _vision=(_t>=145 && _t<205);
    var _drift=round(-sin(_t/260)*14);
    draw_sprite_stretched(_vision?spr_cut_restored:spr_cut_ruins,0,-24+_drift,-14,1414,796);
    if(_vision) {
        // The flash briefly shows a possible restored city; the image returns unchanged.
        var _vf=scr_cut_ease((_t-145)/15)*scr_cut_ease((205-_t)/15);
        draw_set_alpha(0.12*_vf);draw_set_color(make_color_rgb(255,214,150));draw_rectangle(0,0,1366,768,false);draw_set_alpha(1);
        scr_cut_glow(897,330,280,make_color_rgb(255,190,110),_vf*0.6);
        scr_cut_motes(_t,44,0,100,1366,620,make_color_rgb(255,226,160),2.5,2,_vf);
    } else scr_cut_motes(_t,24,0,260,1366,440,make_color_rgb(255,186,120),0.5,3,0.45);
    var _cleared=clamp((_t-440)/500,0,1);
    var _plant_size=12+12*scr_cut_ease((_t-318)/60)+_cleared*8;
    if(!_vision) {
        if(_cleared<0.9)scr_cut_rubble(645+_cleared*135,681,1.1);
        if(_cleared<0.7)scr_cut_rubble(715+_cleared*140,688,0.85);
    }
    var _pg=0.6*scr_cut_ease((_t-318)/30)*(1-0.6*scr_cut_ease((_t-330)/200));
    scr_cut_plant(697,676,_plant_size,_pg);
    var _arrival=scr_cut_ease(_t/85);
    var _left=lerp(230,470,_arrival);var _right=lerp(1130,930,_arrival);
    if(_t>=440)_left=lerp(470,578,scr_cut_ease((_t-440)/140));
    if(_t>=530)_right=lerp(930,821,scr_cut_ease((_t-530)/140));
    var _working=(_t>=440 && _t<780);
    scr_cut_actor(0,_left,680-(_working?round(3*sin(_t/12)):0),150,1);
    scr_cut_actor(1,_right,680-(_working?round(3*sin(_t/12+2)):0),150,-1);
    if(_working) {
        // Rubble is thrown in arcs to both sides of the seedling.
        for(var _d=0;_d<6;_d++) {
            var _ph=_t*0.012+_d/6;_ph=_ph-floor(_ph);
            var _side=(_d mod 2==0?-1:1);
            var _bx=700+_side*_ph*200;var _by=670-sin(_ph*pi)*100+_ph*14;
            draw_set_color(make_color_rgb(50,56,66));draw_rectangle(_bx,_by,_bx+7+(_d mod 3)*2,_by+6,false);
            draw_set_color(make_color_rgb(150,96,66));draw_rectangle(_bx,_by,_bx+7+(_d mod 3)*2,_by+1,false);
        }
        scr_cut_motes(_t,14,560,560,280,120,make_color_rgb(190,160,130),1.4,4,0.5);
    }
    scr_cut_deity(_t);
    if((_t>=130 && _t<145) || (_t>=205 && _t<219)) {
        draw_set_alpha(_t<145?(_t-130)/15:(219-_t)/14);
        draw_set_color(c_white);draw_rectangle(0,0,1366,768,false);draw_set_alpha(1);
    }
}

// Seated viewer: starts as a dark silhouette in the chair, regains colour, leans toward a neighbour, then stands and leaves.
function scr_cut_seated(_id,_cx,_feet,_rise,_alpha,_warm,_lean) {
    static _parts=[[120,180,275,700],[470,45,335,825],[920,190,285,690],[1320,25,345,845]];
    var _r=_parts[_id];var _scale=0.29;
    var _e=scr_cut_ease(_rise);
    var _top0=(_id==1||_id==3?392:408);
    var _top=lerp(_top0,_feet-_r[3]*_scale,_e);
    var _src_h=_r[3]*lerp(0.42,1,_e);
    var _tint=merge_colour(make_color_rgb(34,32,44),c_white,max(_e,_warm));
    var _n=10;
    for(var _k=0;_k<_n;_k++) {
        var _edge=clamp((_k/_n-0.6)/0.4,0,1);
        var _a=_alpha*(1-(1-_e)*_edge);
        if(_a<=0)continue;
        var _shear=round(_lean*(1-_e)*(1-_k/_n));
        draw_sprite_part_ext(spr_cut_people,0,_r[0],_r[1]+_src_h*_k/_n,_r[2],_src_h/_n+0.5,
            round(_cx-_r[2]*_scale/2)+_shear,round(_top+_src_h*_k/_n*_scale),_scale,_scale,_tint,_a);
    }
}

// Room: the game on the TV ends; the four players look at one another, understand, and leave one by one.
function scr_cut_room(_t) {
    var _pull=scr_cut_ease((_t-780)/310);
    draw_sprite_stretched(spr_cut_room,0,0,0,1366,768);
    scr_cut_glow(685,235,340,make_color_rgb(110,150,210),0.26*_pull*(0.92+0.08*sin(_t/5))*(1-0.8*scr_cut_ease((_t-1000)/120)));
    var _sx=482*_pull;var _sy=115*_pull;var _sw=lerp(1366,407,_pull);var _sh=lerp(768,225,_pull);
    draw_set_color(make_color_rgb(10,12,18));draw_rectangle(_sx-4,_sy-4,_sx+_sw+4,_sy+_sh+4,false);
    draw_surface_stretched(global.cutscene_surface,_sx,_sy,_sw,_sh);
    if(_t>=925){draw_set_alpha((0.38+0.3*scr_cut_ease((_t-1000)/100))*scr_cut_ease((_t-925)/30));draw_set_color(make_color_rgb(12,22,29));draw_rectangle(482,115,889,340,false);draw_set_alpha(1);}
    scr_cut_deity_icon(685,235,1.1,0.7*scr_cut_ease((_t-1450)/50)*scr_cut_ease((1720-_t)/60),0);
    scr_cut_motes(_t,18,0,200,1366,500,make_color_rgb(255,200,130),0.3,5,0.5*_pull);
    var _chairs=[238,522,845,1135];
    var _goal=[-160,-160,1520,1520];
    var _starts=[1580,1610,1640,1670];
    // [who, direction, from, to]: each glance is held for a while, the room stays silent.
    var _glances=[[0,1,1150,1330],[1,-1,1190,1330],[2,1,1260,1400],[3,-1,1300,1400],
                  [1,1,1400,1560],[2,-1,1430,1560],[0,1,1480,1560],[3,-1,1480,1560]];
    var _alpha=scr_cut_ease((_pull-0.6)/0.3);
    var _warm=scr_cut_ease((_t-1000)/250);
    var _pulse=scr_cut_ease((_t-1540)/40)*scr_cut_ease((1700-_t)/80);
    for(var _p=0;_p<4;_p++) {
        var _lean=0;
        for(var _g=0;_g<8;_g++)if(_glances[_g][0]==_p)
            _lean+=_glances[_g][1]*scr_cut_ease((_t-_glances[_g][2])/50)*scr_cut_ease((_glances[_g][3]-_t)/50)*10;
        var _rise=clamp((_t-_starts[_p])/80,0,1);
        var _walk=scr_cut_ease((_t-_starts[_p])/170);
        var _x=lerp(_chairs[_p],_goal[_p],_walk);
        var _bob=(_rise>0 && _walk<1?round(abs(sin(_t/6))*3):0);
        if(_pulse>0 && _rise<1)scr_cut_glow(_x+_lean,410,90,make_color_rgb(255,214,150),0.4*_pulse);
        scr_cut_seated(_p,_x,656-_bob,_rise,_alpha,_warm,_lean);
    }
}

// One quiet good deed per person, drawn in yard coordinates; the caller crops and zooms.
function scr_cut_deed(_d,_l) {
    var _gold=make_color_rgb(255,214,150);
    draw_sprite_stretched(spr_cut_yard,0,0,0,1366,768);
    scr_cut_motes(_l,18,0,300,1366,400,make_color_rgb(255,190,120),0.4,6+_d,0.45);
    var _p=clamp(_l/470,0,1);
    if(_d==0) {
        // Sweeping the plaza: rubble ahead of the broom, a warm clean strip and sprouts behind it.
        var _x=lerp(300,780,_p);
        for(var _i=0;_i<6;_i++){var _rx=380+_i*90;if(_rx>_x+30)scr_cut_rubble(_rx,700,0.4);}
        gpu_set_blendmode(bm_add);draw_set_color(_gold);draw_set_alpha(0.1);draw_rectangle(270,672,_x,706,false);draw_set_alpha(1);gpu_set_blendmode(bm_normal);
        for(var _s=0;_s<6;_s++){var _sx=400+_s*85;if(_sx<_x-30)scr_cut_plant(_sx,706,4+22*scr_cut_ease((_x-30-_sx)/140),0.3);}
        scr_cut_civilian(1,_x,692,200,4);
        var _bx=_x+58+sin(_l/9)*26;
        draw_set_color(make_color_rgb(120,86,52));draw_line_width(_x+26,692-95,_bx,686,4);
        draw_set_color(make_color_rgb(206,170,98));draw_rectangle(_bx-12,682,_bx+12,692,false);
        scr_cut_motes(_l,10,_x+20,630,90,70,make_color_rgb(200,170,140),1.6,11,0.6);
        scr_cut_glow(_x,640,220,_gold,0.3*scr_cut_ease((_p-0.85)/0.15));
    } else if(_d==1) {
        // Bringing a lantern to a neighbour who is alone by the bench.
        var _gx=lerp(560,1040,scr_cut_ease(_l/230));
        var _mx=1190;
        var _hand=scr_cut_ease((_l-250)/60);
        var _lx=lerp(_gx+24,_mx-32,_hand);var _ly=lerp(665-92,650-78,_hand);
        scr_cut_shadow(_mx,650,100,0.34);
        scr_actor_pose(0,0,_mx,650,150,-1);
        scr_cut_civilian(3,_gx,665,200,(_l<230?4:0));
        draw_set_color(make_color_rgb(70,56,48));draw_rectangle(_lx-6,_ly-8,_lx+6,_ly+8,false);
        draw_set_color(_gold);draw_rectangle(_lx-4,_ly-6,_lx+4,_ly+5,false);
        scr_cut_glow(_lx,_ly,lerp(26,170,scr_cut_ease((_l-300)/150))*(0.95+0.05*sin(_l/4)),_gold,0.85);
    } else if(_d==2) {
        // Planting a row of seedlings along the shared bed, one every ~70 frames.
        var _i=clamp(floor((_l-30)/70),0,5);
        var _w=clamp(((_l-30)-_i*70)/70,0,1);
        var _prev=(_i==0?380:470+(_i-1)*88-40);
        var _gx=lerp(_prev,470+_i*88-40,scr_cut_ease(_w*2.2));
        for(var _q=0;_q<6;_q++) {
            var _g=scr_cut_ease((_l-(30+_q*70+35))/170);
            if(_g>0)scr_cut_plant(470+_q*88,588,5+30*_g,0.3*_g);
        }
        var _dip=(_w>0.5 && _w<0.9 && _l<30+6*70?round(7*sin((_w-0.5)/0.4*pi)):0);
        scr_cut_civilian(2,_gx,662+_dip,150,(_w<0.45?3:0));
    } else {
        // Watering the flowers beside the old tree; they bloom as the water reaches them.
        var _px=250;var _py=540;
        var _bloom=scr_cut_ease((_l-60)/320);
        scr_cut_civilian(0,_px,_py,130,0);
        draw_set_color(make_color_rgb(110,134,150));draw_rectangle(_px-34,_py-84,_px-14,_py-68,false);
        draw_triangle(_px-34,_py-80,_px-46,_py-76,_px-34,_py-72,false);
        draw_set_color(make_color_rgb(150,176,196));draw_line_width(_px-16,_py-82,_px-4,_py-92,3);
        if(_l>30 && _l<470) {
            gpu_set_blendmode(bm_add);draw_set_color(make_color_rgb(150,200,255));draw_set_alpha(0.8);
            for(var _k=0;_k<10;_k++) {
                var _ph=_l*0.02+_k/10;_ph=_ph-floor(_ph);
                var _wx=lerp(_px-46,150,_ph);var _wy=lerp(_py-76,442,_ph*_ph);
                draw_rectangle(_wx,_wy,_wx+2,_wy+5,false);
            }
            draw_set_alpha(1);gpu_set_blendmode(bm_normal);
        }
        scr_cut_plant(150,442,6+28*_bloom,0.35*_bloom);
        if(_bloom>0.6) {
            var _fa=scr_cut_ease((_bloom-0.6)/0.4);
            var _ty=442-(6+28*_bloom);
            draw_set_color(make_color_rgb(255,170,200));draw_circle(150-11,_ty+4,4*_fa,false);draw_circle(150+12,_ty-4,4*_fa,false);
            draw_set_color(make_color_rgb(255,226,130));draw_circle(150,_ty-6,4*_fa,false);
            scr_cut_motes(_l,16,100,330,100,130,make_color_rgb(255,214,170),1.4,12,_fa);
        }
    }
    var _fx=[780,1100,680,160];var _fy=[640,560,570,420];
    scr_cut_glow(_fx[_d],_fy[_d],220,_gold,0.3*scr_cut_ease((_l-400)/70));
}

// Closing wide shot: the city slowly heals while the four stand apart, each in their own spot.
function scr_cut_montage(_m) {
    var _z=lerp(1.3,1,scr_cut_ease(_m/500));
    var _bx=683-683*_z;var _by=768-768*_z;
    draw_sprite_stretched(spr_cut_ruins,0,_bx,_by,1366*_z,768*_z);
    var _heal=scr_cut_ease((_m-60)/420);
    draw_set_alpha(_heal);draw_sprite_stretched(spr_cut_restored,0,_bx,_by,1366*_z,768*_z);draw_set_alpha(1);
    scr_cut_glow(_bx+897*_z,_by+330*_z,300*_z,make_color_rgb(255,190,110),0.4*_heal);
    scr_cut_motes(_m,40,0,100,1366,620,make_color_rgb(255,226,160),0.8,9,_heal);
    scr_cut_deity_icon(_bx+897*_z,_by+300*_z,0.5*_z,0.55*scr_cut_ease((_m-300)/80)*scr_cut_ease((640-_m)/60),1);
    var _ids=[1,3,2,0];var _xs=[250,520,830,1110];var _hs=[160,160,120,118];
    for(var _i=0;_i<4;_i++) {
        if(scr_cut_ease((_m-40-_i*30)/60)<=0)continue;
        scr_cut_civilian(_ids[_i],683+(_xs[_i]-683)*_z,768+(665-768)*_z,_hs[_i]*_z,0);
    }
}

// Cinematic frame: vignette and animated letterbox bars.
function scr_cut_post(_t) {
    draw_set_color(make_color_rgb(8,10,18));
    for(var _i=0;_i<14;_i++) {
        draw_set_alpha(0.026*(14-_i));
        var _o=_i*14;
        draw_rectangle(0,_o,1366,_o+14,false);
        draw_rectangle(0,768-_o-14,1366,768-_o,false);
        draw_rectangle(_o,0,_o+14,768,false);
        draw_rectangle(1366-_o-14,0,1366-_o,768,false);
    }
    draw_set_alpha(1);
    var _bars=round(52*scr_cut_ease(_t/50)*scr_cut_ease((4570-_t)/40));
    if(_bars>0) {
        draw_set_color(make_color_rgb(6,8,13));
        draw_rectangle(0,0,1366,_bars,false);
        draw_rectangle(0,768-_bars,1366,768,false);
    }
}

// English narration: [start frame, voice length in frames, sound, caption]. Starts follow the beats of the cutscene.
function scr_cut_lines() {
    static _lines=[
        [15,170,narr_01,"A god came to see the ruins."],
        [210,306,narr_02,"He could show them a better world. But he would not build it for them."],
        [525,205,narr_03,"So they began, one stone at a time."],
        [745,191,narr_04,"And the seedling was finally free to grow."],
        [945,257,narr_05,"The game was over. The screen went dark."],
        [1210,133,narr_06,"They looked at one another."],
        [1350,229,narr_07,"And they understood: nobody was coming to save them."],
        [1590,237,narr_08,"If the world was going to change, it would have to be them."],
        [1880,214,narr_09,"One began by cleaning the street in front of home."],
        [2400,202,narr_10,"One carried light to a neighbour who was alone."],
        [2920,212,narr_11,"One planted seeds where there was only bare earth."],
        [3440,212,narr_12,"One watered the flowers no one else remembered."],
        [3960,251,narr_13,"No one came to save the world. They did."],
        [4240,291,narr_14,"Small acts, one person at a time. Together."]
    ];
    return _lines;
}

// Plays each narration line on its start frame (called once per step during the ending).
function scr_cut_voice(_t) {
    if(!global.audio_enabled)return;
    var _lines=scr_cut_lines();
    for(var _i=0;_i<array_length(_lines);_i++)
        if(_lines[_i][0]==_t)audio_play_sound(_lines[_i][2],10,false);
}

function scr_cut_voice_stop() {
    if(!global.audio_enabled)return;
    var _lines=scr_cut_lines();
    for(var _i=0;_i<array_length(_lines);_i++)audio_stop_sound(_lines[_i][2]);
}

// Captions mirror the voice in the lower letterbox bar; set global.cut_captions=false (obj_game Create) to hide them.
function scr_cut_caption(_t) {
    if(variable_global_exists("cut_captions") && !global.cut_captions)return;
    var _lines=scr_cut_lines();
    for(var _i=0;_i<array_length(_lines);_i++) {
        var _c=_lines[_i];
        var _from=_c[0];var _to=_c[0]+_c[1]+25;
        if(_t<_from || _t>_to)continue;
        var _a=scr_cut_ease((_t-_from)/25)*scr_cut_ease((_to-_t)/25);
        draw_set_halign(fa_center);draw_set_valign(fa_middle);
        draw_set_alpha(_a);
        draw_set_color(make_color_rgb(6,8,13));draw_text_transformed(684,744,_c[3],1.6,1.6,0);
        draw_set_color(make_color_rgb(245,232,201));draw_text_transformed(683,743,_c[3],1.6,1.6,0);
        draw_set_alpha(1);draw_set_halign(fa_left);draw_set_valign(fa_top);
    }
}

// Timeline: 0-780 game on screen, 780-1820 room, 1820-3900 four deeds (520 each), 3900-4600 closing, then the card.
function scr_draw_ending(_t) {
    if(!variable_global_exists("cutscene_surface") || !surface_exists(global.cutscene_surface))global.cutscene_surface=surface_create(1366,768);
    if(_t<4600) {
        var _fade=0;
        if(_t<1820) {
            surface_set_target(global.cutscene_surface);draw_clear_alpha(c_black,1);scr_cut_game(min(_t,1000));surface_reset_target();
            if(_t<780) {
                // Slow dolly-out at the start, push-in on the seedling, then pull back for the room.
                var _zoom=1+0.42*min(scr_cut_ease((_t-310)/90),scr_cut_ease((780-_t)/180));
                _zoom=max(_zoom,1+0.1*(1-scr_cut_ease(_t/260)));
                var _src_w=1366/_zoom;var _src_h=768/_zoom;
                draw_surface_part_ext(global.cutscene_surface,(1366-_src_w)/2,768-_src_h,
                    _src_w,_src_h,0,0,_zoom,_zoom,c_white,1);
            } else scr_cut_room(_t);
            if(_t>=1770)_fade=scr_cut_ease((_t-1770)/50);
        } else if(_t<3900) {
            var _d=(_t-1820) div 520;var _l=(_t-1820) mod 520;
            surface_set_target(global.cutscene_surface);draw_clear_alpha(c_black,1);scr_cut_deed(_d,_l);surface_reset_target();
            var _cx=[540,1090,680,270];var _cy=[600,540,570,470];
            var _dz=lerp(1.35,1.65,scr_cut_ease(_l/520));
            var _sw=1366/_dz;var _sh=768/_dz;
            draw_surface_part_ext(global.cutscene_surface,clamp(_cx[_d]-_sw/2,0,1366-_sw),clamp(_cy[_d]-_sh/2,0,768-_sh),
                _sw,_sh,0,0,_dz,_dz,c_white,1);
            if(_l<50)_fade=1-scr_cut_ease(_l/50);
            if(_l>470)_fade=scr_cut_ease((_l-470)/50);
        } else {
            var _m=_t-3900;
            scr_cut_montage(_m);
            if(_m<50)_fade=1-scr_cut_ease(_m/50);
            if(_t>=4500)_fade=scr_cut_ease((_t-4500)/70);
        }
        scr_cut_post(_t);
        scr_cut_caption(_t);
        draw_set_alpha(clamp(_fade,0,1));draw_set_color(make_color_rgb(14,19,27));draw_rectangle(0,0,1366,768,false);draw_set_alpha(1);
    } else {
        var _c=scr_cut_ease((_t-4600)/70);
        draw_set_color(make_color_rgb(14,19,27));draw_rectangle(0,0,1366,768,false);
        scr_cut_glow(683,384,300,make_color_rgb(255,206,130),0.45*_c);
        scr_cut_motes(_t,34,300,150,766,520,make_color_rgb(255,226,160),0.7,8,_c);
        draw_set_halign(fa_center);draw_set_valign(fa_middle);
        draw_set_alpha(_c);draw_set_color(make_color_rgb(245,224,166));
        var _ts=lerp(3.6,4,_c);
        draw_text_transformed(683,360,"TOGETHER",_ts,_ts,0);
        if(_t>=4630)scr_cut_plant(683,486,6+30*scr_cut_ease((_t-4640)/100),0.5*scr_cut_ease((_t-4640)/100));
        draw_set_alpha(1);
        draw_set_halign(fa_left);draw_set_valign(fa_top);
    }
    draw_set_color(c_white);draw_set_alpha(1);
}

function scr_begin_intro() {
    global.player_count=(global.menu_mode==0?1:2);
    global.intro_seen=[false,false,false];
    for(var _i=0;_i<2;_i++) {
        var _p=instance_find((_i==0?obj_player_p1:obj_player_p2),0);
        _p.active_player=(global.player_count==2 || _i==global.solo_character);
        if(global.player_count==1 && _p.active_player){_p.x=(_i==0?270:1096);_p.respawn_x=_p.x;_p.facing=1;}
    }
    global.game_state="intro";global.game_timer=0;
    global.intro_scene=0;
    scr_screen_music("intro");scr_sfx(sfx_intro_whoosh);
}

function scr_menu_input(_direction,_confirm,_back,_vertical=0) {
    if(global.menu_stage==2) {
        if(_vertical!=0) {
            global.settings_index=1-global.settings_index;
            scr_sfx(sfx_ui_move);
        }
        if(_direction!=0) {
            if(global.settings_index==0) {
                scr_audio_music_toggle();
                scr_sfx(sfx_ui_confirm);
            } else {
                scr_audio_volume(0.1*_direction);
                scr_sfx(sfx_ui_move);
            }
        }
        if(_confirm) {global.menu_stage=0;scr_sfx(sfx_ui_back);}
        return;
    }
    if(_back && global.menu_stage==1){global.menu_stage=0;scr_sfx(sfx_ui_back);return;}
    if(_back && global.menu_stage==0){global.menu_stage=2;global.settings_index=0;scr_sfx(sfx_ui_confirm);return;}
    if(_direction!=0) {
        scr_sfx(sfx_ui_move);
        if(global.menu_stage==0)global.menu_mode=1-global.menu_mode;
        else global.solo_character=1-global.solo_character;
    }
    if(_confirm) {
        if(global.menu_stage==0 && global.menu_mode==0){global.menu_stage=1;scr_sfx(sfx_ui_confirm);}
        else {scr_sfx(sfx_ui_confirm);scr_begin_intro();}
    }
}

function scr_player_controls() {
    if(!active_player)return;
    if(dead)return;
    if(global.qa) {var _input=scr_qa_input();scr_player_tick(_input[0],_input[1],_input[2],false);}
    else if(global.player_count==1 || player_number==0) {
        var _mv = keyboard_check(ord("D"))-keyboard_check(ord("A"));
        var _jp = keyboard_check_pressed(ord("W"));
        var _jh = keyboard_check(ord("W"));
        var _bl = keyboard_check_pressed(ord("E"));
        scr_player_tick(_mv,_jp,_bl,_jh);
    } else {
        var _mv2 = keyboard_check(vk_right)-keyboard_check(vk_left);
        var _jp2 = keyboard_check_pressed(vk_up);
        var _jh2 = keyboard_check(vk_up);
        var _bl2 = keyboard_check_pressed(vk_enter);
        scr_player_tick(_mv2,_jp2,_bl2,_jh2);
    }
}

function scr_ui_panel(_l,_t,_r,_b,_selected) {
    draw_set_color(make_color_rgb(13,18,27));draw_rectangle(_l+7,_t+7,_r+7,_b+7,false);
    draw_set_color(_selected?make_color_rgb(232,190,106):make_color_rgb(68,79,88));draw_rectangle(_l,_t,_r,_b,false);
    draw_set_color(_selected?make_color_rgb(43,57,65):make_color_rgb(27,37,47));draw_rectangle(_l+4,_t+4,_r-4,_b-4,false);
    if(_selected) {
        draw_set_color(make_color_rgb(255,222,151));
        draw_triangle((_l+_r)/2-10,_b+25,(_l+_r)/2+10,_b+25,(_l+_r)/2,_b+14,false);
    }
}

function scr_ui_person(_x,_y,_color) {
    draw_set_color(_color);draw_rectangle(_x-7,_y-28,_x+7,_y-14,false);
    draw_rectangle(_x-10,_y-10,_x+10,_y+10,false);
    draw_rectangle(_x-8,_y+10,_x-2,_y+22,false);draw_rectangle(_x+2,_y+10,_x+8,_y+22,false);
}

function scr_draw_settings() {
    var _l=390;var _t=206;var _r=976;var _b=610;
    draw_set_color(make_color_rgb(13,18,27));draw_rectangle(_l+7,_t+7,_r+7,_b+7,false);
    draw_set_color(make_color_rgb(232,190,106));draw_rectangle(_l,_t,_r,_b,false);
    draw_set_color(make_color_rgb(33,44,53));draw_rectangle(_l+4,_t+4,_r-4,_b-4,false);
    draw_set_halign(fa_center);draw_set_valign(fa_middle);
    draw_set_color(make_color_rgb(245,232,201));draw_circle((_l+_r)/2,_t+48,19,true);
    draw_circle((_l+_r)/2,_t+48,8,true);
    for(var _gear=0;_gear<8;_gear++) {
        var _angle=_gear*45;
        draw_line_width((_l+_r)/2+lengthdir_x(22,_angle),_t+48+lengthdir_y(22,_angle),
            (_l+_r)/2+lengthdir_x(28,_angle),_t+48+lengthdir_y(28,_angle),5);
    }
    draw_set_color(make_color_rgb(77,93,96));draw_rectangle(_l+42,_t+87,_r-42,_t+91,false);
    var _ry=_t+157;
    for(var _row=0;_row<2;_row++) {
        var _cy=_t+157+_row*100;
        draw_set_color(global.settings_index==_row?make_color_rgb(234,196,112):make_color_rgb(75,93,99));
        draw_rectangle(_l+39,_cy-35,_r-39,_cy+35,false);
        draw_set_color(global.settings_index==_row?make_color_rgb(48,67,70):make_color_rgb(30,43,51));
        draw_rectangle(_l+43,_cy-31,_r-43,_cy+31,false);
    }
    if(global.settings_index==0) {
        draw_set_color(make_color_rgb(255,222,151));
        draw_triangle(_l+34,_ry,_l+46,_ry-8,_l+46,_ry+8,false);
    }
    draw_set_color(global.settings_index==0?make_color_rgb(255,222,151):make_color_rgb(200,208,204));
    draw_circle(_l+76,_ry+9,10,false);
    draw_line_width(_l+85,_ry+8,_l+85,_ry-28,6);
    draw_line_width(_l+85,_ry-28,_l+107,_ry-32,6);
    draw_set_halign(fa_right);
    draw_set_color(global.audio_music_on?make_color_rgb(165,220,170):make_color_rgb(205,119,105));
    draw_roundrect(_r-124,_ry-19,_r-47,_ry+19,false);
    draw_set_color(make_color_rgb(27,38,44));
    draw_circle(global.audio_music_on?_r-69:_r-102,_ry,14,false);
    _ry=_t+257;
    if(global.settings_index==1) {
        draw_set_color(make_color_rgb(255,222,151));
        draw_triangle(_l+34,_ry,_l+46,_ry-8,_l+46,_ry+8,false);
    }
    draw_set_color(global.settings_index==1?make_color_rgb(255,222,151):make_color_rgb(200,208,204));
    draw_rectangle(_l+64,_ry-8,_l+77,_ry+8,false);
    draw_triangle(_l+77,_ry-8,_l+96,_ry-22,_l+96,_ry+22,false);
    var _bar_l=_l+220;var _bar_r=_r-85;var _seg=10;var _gap=8;
    var _sw=(_bar_r-_bar_l-_gap*(_seg-1))/_seg;
    var _filled=round(global.audio_volume*_seg);
    for(var _s=0;_s<_seg;_s++) {
        var _sx=_bar_l+_s*(_sw+_gap);
        draw_set_color(_s<_filled?make_color_rgb(232,190,106):make_color_rgb(56,68,78));
        draw_rectangle(_sx,_ry-10,_sx+_sw,_ry+10,false);
    }
    draw_set_color(make_color_rgb(150,166,160));
    draw_triangle(_l+44,_b-41,_l+58,_b-51,_l+58,_b-31,false);
    draw_triangle(_r-44,_b-41,_r-58,_b-51,_r-58,_b-31,false);
    draw_line_width((_l+_r)/2+15,_b-40,(_l+_r)/2-15,_b-40,4);
    draw_line_width((_l+_r)/2-15,_b-40,(_l+_r)/2-5,_b-50,4);
    draw_line_width((_l+_r)/2-15,_b-40,(_l+_r)/2-5,_b-30,4);
    draw_set_halign(fa_left);draw_set_valign(fa_top);draw_set_color(c_white);
}

function scr_draw_title_menu() {
    draw_sprite_stretched(ChatGPT_Image_31_Oct_2026__02_56_25,0,0,-80,1366,1020);
    draw_set_alpha(0.76);draw_set_color(make_color_rgb(13,22,31));draw_rectangle(0,0,1366,768,false);draw_set_alpha(1);
    // Rebuilding motif: three ascending blocks and a tiny sprout behind the title.
    draw_set_color(make_color_rgb(64,82,84));
    for(var _i=0;_i<7;_i++)draw_rectangle(516+_i*45,115-abs(3-_i)*12,550+_i*45,142,false);
    draw_set_halign(fa_center);draw_set_valign(fa_middle);
    draw_set_color(make_color_rgb(9,17,24));draw_text_transformed(688,207,"TOGETHER",4.5,4.5,0);
    draw_set_color(make_color_rgb(242,211,151));draw_text_transformed(683,200,"TOGETHER",4.5,4.5,0);
    if(global.menu_stage<2) {
        for(var _c=0;_c<2;_c++) {
            var _cx=497+_c*372;var _selected=(global.menu_stage==0?global.menu_mode:global.solo_character)==_c;
            scr_ui_panel(_cx-153,318,_cx+153,616,_selected);
            if(global.menu_stage==0) {
                if(_c==0) {
                    scr_menu_idle(global.solo_character,_cx,545,142,1);
                    scr_ui_person(_cx,360,make_color_rgb(189,212,212));
                } else {
                    scr_menu_idle(0,_cx-60,545,132,1);scr_menu_idle(1,_cx+60,545,132,-1);
                    scr_ui_person(_cx-17,360,make_color_rgb(80,220,215));scr_ui_person(_cx+17,360,make_color_rgb(247,181,77));
                }
            } else {
                scr_menu_idle(_c,_cx,552,170,1);
                draw_set_color(_c==0?make_color_rgb(80,220,215):make_color_rgb(247,181,77));
                draw_rectangle(_cx-35,350,_cx+35,356,false);
            }
        }
        // Direction triangles and one confirm glyph. Controls are documented outside the game.
        draw_set_color(make_color_rgb(189,207,198));
        draw_triangle(288,452,306,438,306,466,false);draw_triangle(1078,452,1060,438,1060,466,false);
        draw_circle(683,690,20,true);draw_triangle(678,680,678,700,691,690,false);
        if(global.menu_stage==1) {
            draw_line_width(330,692,354,692,3);draw_line_width(330,692,338,684,3);draw_line_width(330,692,338,700,3);
        }
        // A framed gear beside the main confirmation gives settings a clear place.
        var _gx=1110;var _gy=688;
        draw_set_color(make_color_rgb(9,17,24));draw_rectangle(_gx-37,_gy-31,_gx+41,_gy+39,false);
        draw_set_color(make_color_rgb(232,190,106));draw_rectangle(_gx-40,_gy-35,_gx+36,_gy+35,false);
        draw_set_color(make_color_rgb(30,42,50));draw_rectangle(_gx-35,_gy-30,_gx+31,_gy+30,false);
        draw_set_color(make_color_rgb(218,230,211));draw_circle(_gx,_gy,15,true);draw_circle(_gx,_gy,6,true);
        for(var _tooth=0;_tooth<8;_tooth++) {
            var _a=_tooth*45;draw_line_width(_gx+lengthdir_x(18,_a),_gy+lengthdir_y(18,_a),
                _gx+lengthdir_x(23,_a),_gy+lengthdir_y(23,_a),4);
        }
    } else scr_draw_settings();
    draw_set_halign(fa_left);draw_set_valign(fa_top);draw_set_color(c_white);
}

function scr_draw_artifact(_x,_y,_open) {
    draw_set_color(make_color_rgb(37,28,31));draw_rectangle(_x-52,_y-28,_x+52,_y+32,false);
    draw_set_color(make_color_rgb(194,133,51));draw_rectangle(_x-48,_y-24,_x+48,_y+28,false);
    draw_set_color(make_color_rgb(255,216,116));draw_rectangle(_x-48,_y-24-_open*26,_x+48,_y-13-_open*26,false);
    draw_rectangle(_x-40,_y-18,_x-32,_y+24,false);draw_rectangle(_x+32,_y-18,_x+40,_y+24,false);
    draw_rectangle(_x-7,_y-10,_x+7,_y+7,false);
}

function scr_draw_intro() {
    var _t=global.game_timer;var _scene=min(2,_t div 240);var _local=_t mod 240;
    draw_set_color(make_color_rgb(20,25,35));draw_rectangle(0,0,1366,768,false);
    draw_sprite_stretched(ChatGPT_Image_31_Oct_2026__02_56_25,0,0,-105,1366,1020);
    draw_set_alpha(_scene==0?0.25:0.62);draw_set_color(make_color_rgb(14,23,34));draw_rectangle(0,0,1366,768,false);draw_set_alpha(1);
    // Letterbox frames; each scene tells one beat without captions.
    if(_scene==0) {
        // Ruins, survivors and a faint golden artifact. No invented dialogue.
        scr_draw_artifact(830,600,0);
        scr_actor_pose(0,(_local<150?1+(_local div 14) mod 2:0),lerp(230,650,min(1,_local/150)),650,104,1);
        scr_actor_pose(1,(_local<150?1+(_local div 14) mod 2:0),lerp(140,560,min(1,_local/150)),650,104,1);
        draw_set_alpha(0.25+0.2*sin(_t/16));draw_set_color(make_color_rgb(255,217,130));draw_circle(830,570,55,true);draw_set_alpha(1);
    } else if(_scene==1) {
        var _open=clamp((_local-25)/100,0,1);scr_draw_artifact(683,608,_open);
        draw_set_alpha(_open*0.25);draw_set_color(make_color_rgb(255,223,139));draw_triangle(635,585,731,585,683,170,false);draw_set_alpha(1);
        scr_actor_pose(0,0,520,650,104,1);scr_actor_pose(1,0,845,650,104,-1);
        var _radius=24+_open*45;
        draw_set_color(make_color_rgb(255,225,156));draw_circle(683,310,_radius,true);draw_circle(683,310,_radius-8,true);
        draw_triangle(662,340,704,340,683,270,false);
        for(var _r=0;_r<8;_r++) {
            var _angle=_r*45+_t/3;
            draw_line_width(683+lengthdir_x(_radius+12,_angle),310+lengthdir_y(_radius+12,_angle),683+lengthdir_x(_radius+26,_angle),310+lengthdir_y(_radius+26,_angle),3);
        }
    } else {
        // A shared ascending path, falling material, and two people working on it.
        draw_set_color(make_color_rgb(244,218,151));draw_circle(683,167,40,true);draw_triangle(666,184,700,184,683,140,false);
        for(var _b=0;_b<7;_b++) {
            var _bx=570+(_b mod 2)*64;var _by=602-_b*49;
            draw_set_color(make_color_rgb(110,123,111));draw_rectangle(_bx,_by,_bx+64,_by+49,false);
            draw_set_color(make_color_rgb(169,184,142));draw_rectangle(_bx+3,_by+3,_bx+61,_by+8,false);
        }
        scr_actor_pose(0,0,530,650,104,1);scr_actor_pose(1,3,745,565+sin(_local/18)*12,104,-1);
        var _my=255+(_local*2 mod 250);
        draw_set_color(make_color_rgb(181,128,239));draw_triangle(860,_my-13,847,_my,873,_my,false);draw_triangle(847,_my,873,_my,860,_my+13,false);
        draw_set_color(make_color_rgb(150,205,169));draw_line_width(790,590,790,350,4);draw_triangle(778,365,802,365,790,344,false);
    }
    draw_set_color(make_color_rgb(12,18,25));draw_rectangle(0,0,1366,70,false);draw_rectangle(0,698,1366,768,false);
    for(var _d=0;_d<3;_d++) {
        draw_set_color(_d==_scene?make_color_rgb(244,210,140):make_color_rgb(75,86,92));draw_rectangle(647+_d*28,730,663+_d*28,734,false);
    }
    // Small arrow is the skippable transition affordance.
    if(_t>60){draw_set_color(make_color_rgb(183,199,190));draw_triangle(1286,722,1286,742,1300,732,false);}
    var _fade=max(clamp((20-_local)/20,0,1),clamp((_local-220)/20,0,1));
    draw_set_alpha(_fade);draw_set_color(make_color_rgb(12,18,25));draw_rectangle(0,0,1366,768,false);draw_set_alpha(1);draw_set_color(c_white);
}

function scr_return_to_title() {
    global.game_state = "title";
    global.menu_stage = 0;
    global.menu_mode = 1;
    global.solo_character = 0;
    global.player_count = 2;
    global.game_timer = 0;
    global.restart_game = false;
    global.death_window_timer = 0;
    scr_cut_voice_stop();
    if(variable_global_exists("cutscene_surface") && surface_exists(global.cutscene_surface))surface_free(global.cutscene_surface);
    scr_music_stop();
    room_restart();
}

function scr_begin_gameover() {
    if (global.game_state == "gameover") return;
    global.game_state = "gameover";
    global.restart_game = false;
    global.gameover_choice = 0;
    global.gameover_timer = 0;
    with (obj_player_p1) { active_player = false; dead = true; }
    with (obj_player_p2) { active_player = false; dead = true; }
    // Cut every stacked death sting and the gameplay loop, then one cue plus the screen track.
    scr_audio_silence();
    scr_sfx(sfx_fall, 0, 0.65);
    scr_screen_music("gameover");
    window_set_cursor(cr_default);
}

function scr_gameover_button_rect(_index) {
    var _x = (_index == 0 ? 378 : 726);
    return [_x, 448, _x + 262, 568];
}

function scr_gameover_input(_timer) {
    if (_timer < 18) return;
    if (keyboard_check_pressed(vk_escape)) {
        scr_sfx(sfx_ui_back);
        scr_audio_silence();
        game_end();
        return;
    }
    var _mx = device_mouse_x_to_gui(0);
    var _my = device_mouse_y_to_gui(0);
    var _hover = -1;
    for (var _i = 0; _i < 2; _i++) {
        var _r = scr_gameover_button_rect(_i);
        if (point_in_rectangle(_mx, _my, _r[0], _r[1], _r[2], _r[3])) _hover = _i;
    }
    if (_hover != -1) window_set_cursor(cr_handpoint);
    else window_set_cursor(cr_default);
    if (_hover != -1 && _hover != global.gameover_choice) {
        global.gameover_choice = _hover;
        scr_sfx(sfx_ui_move);
    }
    var _dir = (keyboard_check_pressed(ord("D")) || keyboard_check_pressed(vk_right))
        - (keyboard_check_pressed(ord("A")) || keyboard_check_pressed(vk_left));
    if (_dir != 0) {
        var _next = clamp(global.gameover_choice + _dir, 0, 1);
        if (_next != global.gameover_choice) {
            global.gameover_choice = _next;
            scr_sfx(sfx_ui_move);
        }
    }
    var _click = mouse_check_button_pressed(mb_left) && _hover != -1;
    var _confirm = keyboard_check_pressed(ord("E")) || keyboard_check_pressed(vk_enter);
    if (!_click && !_confirm) return;
    if (_click) global.gameover_choice = _hover;
    scr_sfx(sfx_ui_confirm);
    if (global.gameover_choice == 0) scr_return_to_title();
    else {
        scr_audio_silence();
        game_end();
    }
}

function scr_draw_gameover() {
    draw_set_alpha(0.82);
    draw_set_color(make_color_rgb(12, 16, 24));
    draw_rectangle(0, 0, 1366, 768, false);
    draw_set_alpha(1);
    scr_actor_pose(0, 1, 500, 390, 96, 1, 0.72);
    scr_actor_pose(1, 1, 866, 390, 96, -1, 0.72);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(make_color_rgb(9, 17, 24));
    draw_text_transformed(688, 168, "FIM DE JOGO", 4, 4, 0);
    draw_set_color(make_color_rgb(232, 168, 122));
    draw_text_transformed(683, 162, "FIM DE JOGO", 4, 4, 0);
    var _labels = ["REPETIR", "ENCERRAR"];
    for (var _i = 0; _i < 2; _i++) {
        var _r = scr_gameover_button_rect(_i);
        scr_ui_panel(_r[0], _r[1], _r[2], _r[3], global.gameover_choice == _i);
        draw_set_color(global.gameover_choice == _i ? make_color_rgb(255, 222, 151) : make_color_rgb(189, 207, 198));
        draw_text_transformed((_r[0] + _r[2]) / 2, (_r[1] + _r[3]) / 2, _labels[_i], 2, 2, 0);
    }
    draw_set_color(make_color_rgb(189, 207, 198));
    draw_circle(683, 650, 18, true);
    draw_triangle(678, 640, 678, 660, 692, 650, false);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
}
