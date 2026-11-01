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

function scr_save_game(_p1,_p2) {
    var _g=instance_find(obj_game,0);
    var _blocks=[];
    for(var _i=0;_i<instance_number(obj_build_block);_i++) {
        var _b=instance_find(obj_build_block,_i);
        if(_b!=noone && !_b.is_checkpoint) {
            array_push(_blocks,{x:_b.x,y:_b.y,builder:_b.builder_number});
        }
    }
    var _save={
        player_count:global.player_count,
        solo_character:global.solo_character,
        p1x:_p1.x,p1y:_p1.y,p1lives:_p1.player_lives,p1stock:_p1.material_count,
        p2x:_p2.x,p2y:_p2.y,p2lives:_p2.player_lives,p2stock:_p2.material_count,
        camera_y:(_g!=noone?_g.camera_y:room_height-768),
        altitude:(_g!=noone?_g.altitude:0),
        level_saved:global.level_saved,
        blocks:_blocks
    };
    var _sf=file_text_open_write("save.json");
    file_text_write_string(_sf,json_stringify(_save));
    file_text_close(_sf);
}
function scr_clear_save() {
    if (file_exists("save.json")) file_delete("save.json");
    if (file_exists("settings.json")) { /* keep settings */ }
    scr_sfx(sfx_ui_back);
}
function scr_load_game() {
    if (!file_exists("save.json")) { scr_sfx(sfx_ui_back); return; }
    var _f=file_text_open_read("save.json");
    var _s=file_text_read_string(_f);
    file_text_close(_f);
    var _d=json_parse(_s);
    global.game_state="play"; global.game_timer=0;
    if (variable_struct_exists(_d,"player_count")) global.player_count=_d.player_count;
    if (variable_struct_exists(_d,"solo_character")) global.solo_character=_d.solo_character;
    if (variable_struct_exists(_d,"level_saved") && is_array(_d.level_saved)) global.level_saved=_d.level_saved;
    for(var _bi=instance_number(obj_build_block)-1;_bi>=0;_bi--) {
        var _old_b=instance_find(obj_build_block,_bi);
        if(_old_b!=noone && !_old_b.is_checkpoint) instance_destroy(_old_b);
    }
    if (variable_struct_exists(_d,"blocks") && is_array(_d.blocks)) {
        for(var _k=0;_k<array_length(_d.blocks);_k++) {
            var _bd=_d.blocks[_k];
            var _nb=instance_create_layer(_bd.x,_bd.y,"Instances_1",obj_build_block);
            _nb.builder_number=_bd.builder;
        }
    }
    var _p1=instance_find(obj_player_p1,0); var _p2=instance_find(obj_player_p2,0);
    if (_p1!=noone) {
        _p1.active_player=(global.player_count==2 || global.solo_character==0);
        _p1.dead=false;
        if (variable_struct_exists(_d,"p1x")) { _p1.x=_d.p1x; _p1.y=_d.p1y; _p1.respawn_x=_d.p1x; _p1.respawn_y=_d.p1y; }
        if (variable_struct_exists(_d,"p1stock")) _p1.material_count=_d.p1stock;
        if (variable_struct_exists(_d,"p1lives")) _p1.player_lives=max(1,_d.p1lives);
    }
    if (_p2!=noone) {
        _p2.active_player=(global.player_count==2 || global.solo_character==1);
        _p2.dead=false;
        if (variable_struct_exists(_d,"p2x")) { _p2.x=_d.p2x; _p2.y=_d.p2y; _p2.respawn_x=_d.p2x; _p2.respawn_y=_d.p2y; }
        if (variable_struct_exists(_d,"p2stock")) _p2.material_count=_d.p2stock;
        if (variable_struct_exists(_d,"p2lives")) _p2.player_lives=max(1,_d.p2lives);
    }
    var _g=instance_find(obj_game,0);
    if (_g!=noone && variable_struct_exists(_d,"camera_y")) { _g.camera_y=_d.camera_y; camera_set_view_pos(_g.cam,0,_g.camera_y); }
    if (variable_struct_exists(_d,"altitude")) global.last_save_altitude=_d.altitude;
    scr_screen_music("play");
    scr_sfx(sfx_ui_confirm);
}
function scr_settings_load() {
    if (!variable_global_exists("audio_muted")) global.audio_muted = false;
    if (!file_exists("settings.json")) return;
    var _f=file_text_open_read("settings.json");
    var _s=file_text_read_string(_f);
    file_text_close(_f);
    var _d=json_parse(_s);
    if (variable_struct_exists(_d,"music_on")) {
        global.audio_music_on=_d.music_on;
        if(!global.audio_music_on) scr_music_stop();
    }
    if (variable_struct_exists(_d,"volume")) {
        global.audio_volume=clamp(_d.volume,0,1);
        if(variable_global_exists("audio_enabled") && global.audio_enabled) audio_master_gain(global.audio_muted?0:global.audio_volume);
    }
    if (variable_struct_exists(_d,"fullscreen") && !global.qa && !global.boot_test) {
        global.settings_fullscreen=_d.fullscreen;
        window_set_fullscreen(_d.fullscreen);
    }
}
function scr_settings_save() {
    var _d={music_on:global.audio_music_on,volume:global.audio_volume,fullscreen:window_get_fullscreen()};
    var _f=file_text_open_write("settings.json");
    file_text_write_string(_f,json_stringify(_d));
    file_text_close(_f);
}
function scr_begin_intro() {
    global.player_count=(global.menu_mode==0?1:2);
    global.intro_seen=[false,false,false];
    global.level_saved=[false,false,false,false];
    global.auto_save_timer=3600;
    for(var _i=0;_i<2;_i++) {
        var _p=instance_find((_i==0?obj_player_p1:obj_player_p2),0);
        _p.active_player=(global.player_count==2 || _i==global.solo_character);
        if(global.player_count==1 && _p.active_player){_p.x=(_i==0?270:1096);_p.respawn_x=_p.x;_p.facing=1;}
    }
    global.game_state="intro";global.game_timer=0;
    global.intro_scene=0;
    scr_screen_music("intro");scr_sfx(sfx_intro_whoosh);
}

function scr_menu_input(_direction,_confirm,_back,_vertical=0,_escape=false) {
    // Stage 0: Title screen with three buttons: Iniciar Jogo (0), Carregar Jogo (1), Ajustes (2).
    // Note: _vertical is +1 when pressing W/Up and -1 when pressing S/Down.
    if(global.menu_stage==0) {
        if(_vertical!=0) {
            var _next_title=clamp(global.title_choice-_vertical,0,3);
            if(_next_title!=global.title_choice) {
                global.title_choice=_next_title;
                scr_sfx(sfx_ui_move);
            }
        }
        if(_confirm) {
            scr_sfx(sfx_ui_confirm);
            if(global.title_choice==0) { global.menu_stage=1; global.menu_mode=1; }
            else if(global.title_choice==1) { scr_load_game(); }
            else if(global.title_choice==2) { global.menu_stage=3; global.settings_index=0; }
            else { scr_clear_save(); }
        }
        return;
    }
    // Stage 3: Settings menu (Musica, Som, Tela Cheia).
    if(global.menu_stage==3) {
        if(_vertical!=0) {
            var _next_set=clamp(global.settings_index-_vertical,0,2);
            if(_next_set!=global.settings_index) {
                global.settings_index=_next_set;
                scr_sfx(sfx_ui_move);
            }
        }
        if(_direction!=0) {
            if(global.settings_index==0) {
                scr_audio_music_toggle();
                scr_settings_save();
                scr_sfx(sfx_ui_confirm);
            } else if(global.settings_index==1) {
                scr_audio_volume(0.1*_direction);
                scr_settings_save();
                scr_sfx(sfx_ui_move);
            } else if(global.settings_index==2) {
                window_set_fullscreen(!window_get_fullscreen());
                scr_settings_save();
                scr_sfx(sfx_ui_confirm);
            }
        }
        if(_confirm || _escape) { global.menu_stage=0; scr_sfx(sfx_ui_back); scr_settings_save(); }
        return;
    }
    // Stage 1: Mode selection (0 = 1 Jogador on left, 1 = 2 Jogadores on right).
    // A/Left (_direction = -1) selects left (0); D/Right (_direction = +1) selects right (1).
    if(global.menu_stage==1) {
        if(_direction!=0) {
            var _next_mode=clamp(global.menu_mode+_direction,0,1);
            if(_next_mode!=global.menu_mode) {
                global.menu_mode=_next_mode;
                scr_sfx(sfx_ui_move);
            }
        }
        if(_confirm) {
            scr_sfx(sfx_ui_confirm);
            if(global.menu_mode==0) {
                global.menu_stage=2; // character selection
            } else {
                scr_begin_intro();
            }
        }
        if(_back || _escape) { global.menu_stage=0; scr_sfx(sfx_ui_back); }
        return;
    }
    // Stage 2: Character selection for solo (0 = Ciano on left, 1 = Ambar on right).
    if(global.menu_stage==2) {
        if(_direction!=0) {
            var _next_char=clamp(global.solo_character+_direction,0,1);
            if(_next_char!=global.solo_character) {
                global.solo_character=_next_char;
                scr_sfx(sfx_ui_move);
            }
        }
        if(_confirm) { scr_sfx(sfx_ui_confirm); scr_begin_intro(); }
        if(_back || _escape) { global.menu_stage=1; scr_sfx(sfx_ui_back); }
        return;
    }
}

function scr_gamepad_for_player(_player_number) {
    if (_player_number == 0) {
        for (var _g=0; _g<12; _g++) if (gamepad_is_connected(_g)) return _g;
        return -1;
    }
    for (var _g2=1; _g2<12; _g2++) if (gamepad_is_connected(_g2)) return _g2;
    return -1;
}
function scr_gamepad_is_ps_layout(_gp) {
    var _d = gamepad_get_description(_gp);
    return (string_pos("Wireless", _d) > 0)
        || (string_pos("DualShock", _d) > 0)
        || (string_pos("DualSense", _d) > 0)
        || (string_pos("PS4", _d) > 0)
        || (string_pos("PS5", _d) > 0)
        || (string_pos("PLAYSTATION", _d) > 0)
        || (string_pos("Sony", _d) > 0);
}
function scr_gamepad_jump_btn(_gp) { return gp_face1; }
function scr_gamepad_build_btn(_gp) { return gp_face3; }
function scr_gamepad_back_btn(_gp) { return gp_face2; }
function scr_gamepad_menu_input() {
    var _gp = scr_gamepad_for_player(0);
    if (_gp < 0) {
        global.gp_prev_l=false; global.gp_prev_r=false;
        global.gp_prev_u=false; global.gp_prev_d=false;
        global.gp_prev_c=false; global.gp_prev_b=false;
        return [0,false,false,0];
    }
    var _ax = gamepad_axis_value(_gp, gp_axislh);
    var _ay = gamepad_axis_value(_gp, gp_axislv);
    var _l = gamepad_button_check(_gp, gp_padl) || (_ax < -0.6);
    var _r = gamepad_button_check(_gp, gp_padr) || (_ax > 0.6);
    var _u = gamepad_button_check(_gp, gp_padu) || (_ay < -0.6);
    var _d = gamepad_button_check(_gp, gp_padd) || (_ay > 0.6);
    var _c = gamepad_button_check(_gp, gp_face1);
    var _b = gamepad_button_check(_gp, gp_face2);
    var _dir = 0;
    if (_l && !global.gp_prev_l) _dir = -1;
    if (_r && !global.gp_prev_r) _dir = 1;
    var _vert = 0;
    if (_u && !global.gp_prev_u) _vert = 1;
    if (_d && !global.gp_prev_d) _vert = -1;
    var _confirm = _c && !global.gp_prev_c;
    var _back = _b && !global.gp_prev_b;
    global.gp_prev_l = _l; global.gp_prev_r = _r;
    global.gp_prev_u = _u; global.gp_prev_d = _d;
    global.gp_prev_c = _c; global.gp_prev_b = _b;
    return [_dir, _confirm, _back, _vert];
}
function scr_gamepad_confirm_pressed() {
    var _any = false;
    for (var _g=0; _g<12; _g++) {
        if (gamepad_is_connected(_g) && gamepad_button_check(_g, gp_face1)) { _any = true; break; }
    }
    var _pressed = _any && !global.gp_prev_confirm_any;
    global.gp_prev_confirm_any = _any;
    return _pressed;
}
function scr_player_controls() {
    if(global.qa_regression)return;
    if(!active_player)return;
    if(dead)return;
    if(global.pause_guard>0) { last_move=0; return; }
    if(global.qa) {var _input=scr_qa_input();scr_player_tick(_input[0],_input[1],_input[2],false,true); return;}
    var _mv = 0; var _jp = false; var _jp_hold = false; var _jh = false; var _bl = false;
    if(global.player_count==1 || player_number==0) {
        _mv = keyboard_check(ord("D"))-keyboard_check(ord("A"));
        _jp = keyboard_check_pressed(ord("W"));
        _jp_hold = keyboard_check(ord("W"));
        _jh = keyboard_check(ord("Q"));
        _bl = keyboard_check_pressed(ord("E"));
    } else {
        _mv = keyboard_check(vk_right)-keyboard_check(vk_left);
        _jp = keyboard_check_pressed(vk_up);
        _jp_hold = keyboard_check(vk_up);
        _jh = keyboard_check(vk_rshift);
        _bl = keyboard_check_pressed(vk_enter);
    }
    var _gp = scr_gamepad_for_player(player_number);
    var _use_gp = (_gp >= 0);
    if (_use_gp) {
        var _dz = 0.15;
        var _ax = gamepad_axis_value(_gp, gp_axislh);
        if (abs(_ax) > _dz) _mv = (_ax > 0) ? 1 : -1;
        if (gamepad_button_check(_gp, gp_padl)) _mv = -1;
        if (gamepad_button_check(_gp, gp_padr)) _mv = 1;
        var _now_jump = gamepad_button_check(_gp, scr_gamepad_jump_btn(_gp));
        var _now_build = gamepad_button_check(_gp, scr_gamepad_build_btn(_gp));
        if (_now_jump && !_gp_prev_jump) _jp = true;
        _jp_hold = _jp_hold || _now_jump;
        _jh = _jh || _now_jump;
        if (_now_build && !_gp_prev_build) _bl = true;
        _gp_prev_jump = _now_jump;
        _gp_prev_build = _now_build;
    }
    var _dbg_player = (global.player_count==1 ? global.solo_character : 0);
    if (player_number == _dbg_player) {
        global.dbg_mv = _mv; global.dbg_jp = _jp; global.dbg_jh = _jh; global.dbg_bl = _bl; global.dbg_gp = _gp;
    }
    scr_player_tick(_mv,_jp,_bl,_jh,_jp_hold);
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

function scr_ui_keycap(_x,_y,_label,_scale=1.1) {
    var _w=string_width(_label)*_scale+22;var _h=26;
    draw_set_halign(fa_center);draw_set_valign(fa_middle);
    draw_set_color(make_color_rgb(8,14,20));draw_roundrect(_x-_w/2+3,_y-_h/2+3,_x+_w/2+3,_y+_h/2+3,false);
    draw_set_color(make_color_rgb(232,190,106));draw_roundrect(_x-_w/2,_y-_h/2,_x+_w/2,_y+_h/2,false);
    draw_set_color(make_color_rgb(31,43,51));draw_roundrect(_x-_w/2+2,_y-_h/2+2,_x+_w/2-2,_y+_h/2-2,false);
    draw_set_color(make_color_rgb(245,232,201));
    draw_text_transformed(_x,_y+1,_label,_scale,_scale,0);
}

function scr_ui_hint(_x,_y,_key,_label,_scale=1.05) {
    var _kw=string_width(_key)*1.1+22;var _gap=10;var _lw=string_width(_label)*_scale;
    var _left=_x-(_kw+_gap+_lw)/2;
    scr_ui_keycap(_left+_kw/2,_y,_key,1.1);
    draw_set_halign(fa_left);draw_set_valign(fa_middle);
    draw_set_color(make_color_rgb(196,210,201));
    draw_text_transformed(_left+_kw+_gap,_y+1,_label,_scale,_scale,0);
}

function scr_draw_settings() {
    var _l=370;var _t=146;var _r=996;var _b=674;var _cx=(_l+_r)/2;
    draw_set_color(make_color_rgb(13,18,27));draw_rectangle(_l+7,_t+7,_r+7,_b+7,false);
    draw_set_color(make_color_rgb(232,190,106));draw_rectangle(_l,_t,_r,_b,false);
    draw_set_color(make_color_rgb(33,44,53));draw_rectangle(_l+4,_t+4,_r-4,_b-4,false);
    scr_cut_glow(_cx,_t+48,140,make_color_rgb(255,206,130),0.16);
    draw_set_halign(fa_center);draw_set_valign(fa_middle);
    var _hx=_cx-74;var _hy=_t+46;
    draw_set_color(make_color_rgb(245,232,201));draw_circle(_hx,_hy,19,true);
    draw_circle(_hx,_hy,8,true);
    for(var _gear=0;_gear<8;_gear++) {
        var _angle=_gear*45;
        draw_line_width(_hx+lengthdir_x(22,_angle),_hy+lengthdir_y(22,_angle),
            _hx+lengthdir_x(28,_angle),_hy+lengthdir_y(28,_angle),5);
    }
    draw_text_transformed(_cx+34,_hy,"AJUSTES",1.9,1.9,0);
    draw_set_color(make_color_rgb(77,93,96));draw_rectangle(_l+42,_t+84,_r-42,_t+88,false);
    for(var _row=0;_row<3;_row++) {
        var _cy=_t+148+_row*96;
        draw_set_color(global.settings_index==_row?make_color_rgb(234,196,112):make_color_rgb(75,93,99));
        draw_rectangle(_l+39,_cy-34,_r-39,_cy+34,false);
        draw_set_color(global.settings_index==_row?make_color_rgb(48,67,70):make_color_rgb(30,43,51));
        draw_rectangle(_l+43,_cy-30,_r-43,_cy+30,false);
        if(global.settings_index==_row) {
            draw_set_color(make_color_rgb(255,222,151));
            draw_triangle(_l+34,_cy,_l+46,_cy-8,_l+46,_cy+8,false);
        }
    }
    var _ry=_t+148;
    draw_set_color(global.settings_index==0?make_color_rgb(255,222,151):make_color_rgb(200,208,204));
    draw_circle(_l+76,_ry+9,10,false);
    draw_line_width(_l+85,_ry+8,_l+85,_ry-26,6);
    draw_line_width(_l+85,_ry-26,_l+107,_ry-30,6);
    draw_set_halign(fa_left);
    draw_set_color(global.settings_index==0?make_color_rgb(245,232,201):make_color_rgb(176,192,184));
    draw_text_transformed(_l+132,_ry,"MUSICA",1.2,1.2,0);
    draw_set_halign(fa_right);
    draw_set_color(global.audio_music_on?make_color_rgb(165,220,170):make_color_rgb(205,119,105));
    draw_text_transformed(_r-142,_ry,global.audio_music_on?"LIGADA":"DESLIGADA",0.95,0.95,0);
    draw_roundrect(_r-124,_ry-19,_r-47,_ry+19,false);
    draw_set_color(make_color_rgb(27,38,44));
    draw_circle(global.audio_music_on?_r-69:_r-102,_ry,14,false);
    _ry=_t+244;
    draw_set_color(global.settings_index==1?make_color_rgb(255,222,151):make_color_rgb(200,208,204));
    draw_rectangle(_l+64,_ry-8,_l+77,_ry+8,false);
    draw_triangle(_l+77,_ry-8,_l+96,_ry-22,_l+96,_ry+22,false);
    draw_set_halign(fa_left);
    draw_set_color(global.settings_index==1?make_color_rgb(245,232,201):make_color_rgb(176,192,184));
    draw_text_transformed(_l+132,_ry,"SOM",1.2,1.2,0);
    draw_set_halign(fa_right);
    draw_set_color(global.settings_index==1?make_color_rgb(255,222,151):make_color_rgb(189,207,198));
    draw_text_transformed(_l+210,_ry,string(round(global.audio_volume*100))+"%",1.0,1.0,0);
    var _bar_l=_l+230;var _bar_r=_r-85;var _seg=10;var _gap=8;
    var _sw=(_bar_r-_bar_l-_gap*(_seg-1))/_seg;
    var _filled=round(global.audio_volume*_seg);
    for(var _s=0;_s<_seg;_s++) {
        var _sx=_bar_l+_s*(_sw+_gap);
        draw_set_color(_s<_filled?make_color_rgb(232,190,106):make_color_rgb(56,68,78));
        draw_rectangle(_sx,_ry-10,_sx+_sw,_ry+10,false);
    }
    // Fullscreen row
    _ry=_t+340;
    draw_set_color(global.settings_index==2?make_color_rgb(255,222,151):make_color_rgb(200,208,204));
    draw_rectangle(_l+64,_ry-12,_l+94,_ry+12,true);
    draw_rectangle(_l+68,_ry-8,_l+90,_ry+8,false);
    draw_set_halign(fa_left);
    draw_set_color(global.settings_index==2?make_color_rgb(245,232,201):make_color_rgb(176,192,184));
    draw_text_transformed(_l+132,_ry,"TELA CHEIA",1.2,1.2,0);
    draw_set_halign(fa_right);
    draw_set_color(window_get_fullscreen()?make_color_rgb(165,220,170):make_color_rgb(205,119,105));
    draw_text_transformed(_r-142,_ry,window_get_fullscreen()?"LIGADA":"DESLIGADA",0.95,0.95,0);
    draw_roundrect(_r-124,_ry-19,_r-47,_ry+19,false);
    draw_set_color(make_color_rgb(27,38,44));
    draw_circle(window_get_fullscreen()?_r-69:_r-102,_ry,14,false);
    draw_set_color(make_color_rgb(77,93,96));draw_rectangle(_l+42,_b-76,_r-42,_b-72,false);
    scr_ui_hint(_l+150,_b-38,"W S","NAVEGAR");
    scr_ui_hint(_cx,_b-38,"A D","AJUSTAR");
    scr_ui_hint(_r-150,_b-38,"ESC","VOLTAR");
    draw_set_halign(fa_left);draw_set_valign(fa_top);draw_set_color(c_white);
}

function scr_draw_title_menu() {
    draw_sprite_stretched(ChatGPT_Image_31_Oct_2026__02_56_25,0,0,-80,1366,1020);
    draw_set_alpha(0.76);draw_set_color(make_color_rgb(13,22,31));draw_rectangle(0,0,1366,768,false);draw_set_alpha(1);
    scr_cut_glow(683,206,200,make_color_rgb(255,206,130),0.22);
    // Rebuilding motif: three ascending blocks and a tiny sprout behind the title.
    draw_set_color(make_color_rgb(64,82,84));
    for(var _i=0;_i<7;_i++)draw_rectangle(516+_i*45,115-abs(3-_i)*12,550+_i*45,142,false);
    draw_set_halign(fa_center);draw_set_valign(fa_middle);
    draw_set_color(make_color_rgb(9,17,24));draw_text_transformed(688,207,"TOGETHER",4.5,4.5,0);
    draw_set_color(make_color_rgb(242,211,151));draw_text_transformed(683,200,"TOGETHER",4.5,4.5,0);
    if(global.menu_stage==0) {
        draw_set_color(make_color_rgb(155,173,166));
        draw_text_transformed(683,270,"MENU PRINCIPAL",1.25,1.25,0);
        // Title screen with three buttons: Iniciar Jogo, Carregar Jogo, Ajustes.
        var _labels=["INICIAR JOGO","CARREGAR JOGO","AJUSTES","LIMPAR SAVE"];
        for(var _c=0;_c<4;_c++) {
            var _cx=683; var _cy=340+_c*80; var _selected=(global.title_choice==_c);
            if(_selected)scr_cut_glow(_cx, _cy, 120, make_color_rgb(232,190,106), 0.16);
            scr_ui_panel(_cx-195, _cy-36, _cx+195, _cy+36, _selected);
            draw_set_halign(fa_center);draw_set_valign(fa_middle);
            draw_set_color(_selected?make_color_rgb(255,222,151):make_color_rgb(148,166,158));
            draw_text_transformed(_cx,_cy,_labels[_c],1.25,1.25,0);
        }
        draw_set_alpha(0.55);draw_set_color(make_color_rgb(9,16,23));draw_rectangle(70,656,1296,760,false);draw_set_alpha(1);
        draw_set_alpha(0.45);draw_set_color(make_color_rgb(232,190,106));draw_line_width(70,656,1296,656,2);draw_set_alpha(1);
        scr_ui_hint(380,696,"W S","NAVEGAR");
        scr_ui_hint(683,696,"E","CONFIRMAR");
        scr_ui_hint(986,696,"ESC 3S","SAIR");
        if(file_exists("save.json")) {
            draw_set_halign(fa_center);draw_set_valign(fa_middle);
            draw_set_color(make_color_rgb(150,220,160));
            draw_text_transformed(683,628,"JOGO SALVO DISPONIVEL",0.9,0.9,0);
        }
    } else if(global.menu_stage<3) {
        draw_set_color(make_color_rgb(155,173,166));
        draw_text_transformed(683,270,global.menu_stage==1?"ESCOLHA COMO JOGAR":"ESCOLHA SEU PERSONAGEM",1.25,1.25,0);
        for(var _c=0;_c<2;_c++) {
            var _cx=497+_c*372;var _selected=(global.menu_stage==1?global.menu_mode:global.solo_character)==_c;
            if(_selected)scr_cut_glow(_cx,470,170,make_color_rgb(232,190,106),0.16);
            scr_ui_panel(_cx-153,318,_cx+153,616,_selected);
            if(global.menu_stage==1) {
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
            draw_set_halign(fa_center);draw_set_valign(fa_middle);
            draw_set_color(_selected?make_color_rgb(255,222,151):make_color_rgb(148,166,158));
            draw_text_transformed(_cx,592,
                (global.menu_stage==1?(_c==0?"1 JOGADOR":"2 JOGADORES"):(_c==0?"CIANO":"AMBAR")),
                1.15,1.15,0);
        }
        // Direction triangles and the footer explain the keys without glyph-only buttons.
        draw_set_color(make_color_rgb(189,207,198));
        draw_triangle(288,452,306,438,306,466,false);draw_triangle(1078,452,1060,438,1060,466,false);
        draw_set_alpha(0.55);draw_set_color(make_color_rgb(9,16,23));draw_rectangle(70,656,1296,760,false);draw_set_alpha(1);
        draw_set_alpha(0.45);draw_set_color(make_color_rgb(232,190,106));draw_line_width(70,656,1296,656,2);draw_set_alpha(1);
        scr_ui_hint(250,696,"A D","ESCOLHER");
        scr_ui_hint(683,696,"E",global.menu_stage==1?"CONFIRMAR":"JOGAR");
        scr_ui_hint(1078,696,"S / ESC","VOLTAR");
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
    global.last_menu_mode = global.menu_mode;
    global.last_solo_character = global.solo_character;
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
        scr_return_to_title();
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
    scr_gameover_select(global.gameover_choice);
}

function scr_gameover_select(_choice) {
    if (_choice==0) {
        // Retry: restart the selected mode cleanly, without carrying over the previous run.
        global.menu_mode = (global.player_count==1 ? 0 : 1);
        global.solo_character = (global.player_count==1 ? (variable_global_exists("last_solo_character") ? global.last_solo_character : 0) : 0);
        global.player_count = (global.menu_mode==0 ? 1 : 2);
        global.game_state="play";global.game_timer=0;global.retry_pending=false;
        global.death_window_timer=0;
        global.auto_save_timer=3600;
        global.last_save_altitude=0;
        scr_audio_silence();
        scr_screen_music("play");
        // Clear all constructed blocks for a fresh run.
        for(var _bi=instance_number(obj_build_block)-1;_bi>=0;_bi--) {
            var _b=instance_find(obj_build_block,_bi);
            if(_b!=noone && !_b.is_checkpoint) instance_destroy(_b);
        }
        var _game=instance_find(obj_game,0);
        if(_game!=noone) {
            _game.camera_y=room_height-768;
            camera_set_view_pos(_game.cam,0,_game.camera_y);
        }
        for(var _i=0;_i<2;_i++) {
            var _p=instance_find((_i==0?obj_player_p1:obj_player_p2),0);
            if(_p==noone)continue;
            _p.dead=false;
            _p.player_lives=3;
            _p.respawn_timer=0;
            _p.active_player=(global.player_count==2 || global.solo_character==_i);
            _p.respawn_x=(_i==0?270:1096);
            _p.respawn_y=scr_floor_y();
            _p.material_count=0;
            _p.built_total=0;
            _p.collected_total=0;
            _p.fall_hits=0;
            _p.enemy_hits=0;
            _p.recoveries=0;
            _p.reset_blocks_total=0;
            _p.checkpoint_level=0;
            _p.x=_p.respawn_x;
            _p.y=_p.respawn_y;
            _p.vy=0;
            _p.grounded=true;
            _p.invulnerable=0;
            _p.charge=0;
            _p._hthrust=0;
            _p._jump_was_held=false;
            _p._charge_dir=0;
            _p.jump_held=false;
            _p.qa_target=noone;
            _p.last_support=noone;
            _p.last_move=0;
            _p.facing=(_i==0?1:-1);
            if(_p.active_player) {
                with(_p) { invulnerable=120; }
            }
        }
        window_set_cursor(cr_default);
    } else scr_return_to_title();
}

function scr_draw_gameover() {
    draw_set_alpha(0.82);
    draw_set_color(make_color_rgb(12, 16, 24));
    draw_rectangle(0, 0, 1366, 768, false);
    draw_set_alpha(1);
    scr_actor_pose(0, 1, 500, 390, 96, 1, 0.72);
    scr_actor_pose(1, 1, 866, 390, 96, -1, 0.72);
    // Text-free retry arrow and house: keyboard or mouse selects either panel.
    for(var _i=0;_i<2;_i++) {
        var _r=scr_gameover_button_rect(_i);
        scr_ui_panel(_r[0],_r[1],_r[2],_r[3],global.gameover_choice==_i);
        var _cx=(_r[0]+_r[2])/2;var _cy=(_r[1]+_r[3])/2;
        draw_set_color(make_color_rgb(235,211,157));
        if(_i==0) {
            draw_circle(_cx,_cy,27,true);
            draw_triangle(_cx+12,_cy-32,_cx+32,_cy-26,_cx+20,_cy-12,false);
        } else {
            draw_triangle(_cx-34,_cy-4,_cx,_cy-32,_cx+34,_cy-4,false);
            draw_rectangle(_cx-24,_cy-4,_cx+24,_cy+28,false);
            draw_set_color(make_color_rgb(30,43,51));draw_rectangle(_cx-7,_cy+6,_cx+7,_cy+28,false);
        }
    }
    draw_set_color(c_white);
}

// Five measured poses share a baseline; remove the sheet matte while rendering.
function scr_blue_enemy_draw(_frame,_x,_y) {
    static _rects=[[32,24,156,192],[236,24,152,192],[420,24,156,192],[604,24,204,192],[812,24,212,192]];
    var _r=_rects[_frame];var _scale=0.4;
    shader_set(shd_blue_cutout);
    draw_sprite_part_ext(spr_foguinho,0,_r[0],_r[1],_r[2],_r[3],round(_x-_r[2]*_scale/2),round(_y-96*_scale),_scale,_scale,c_white,1);
    shader_reset();
}

// Four 256 px cells share a baseline; the source already carries transparency.
function scr_demon_draw(_frame,_x,_y) {
    static _scale=0.42;
    var _cell=256;
    var _left=round(_x-140*_scale);
    var _top=round(_y-120*_scale);
    draw_sprite_part_ext(spr_demon_sheet,0,(_frame mod 4)*_cell,0,_cell,254,_left,_top,_scale,_scale,c_white,1);
}

// Foreground chasm: the ground strip already carries the bank art, so the void is cut over it in GUI space.
function scr_draw_void() {
    var _floor=scr_floor_y()-camera_y;
    if(_floor>=768)return;
    var _l=540;var _r=826;var _bottom=768;

    draw_set_color(make_color_rgb(7,7,11));draw_rectangle(_l,_floor,_r,_bottom,false);
    draw_set_color(make_color_rgb(16,13,18));draw_rectangle(_l+24,_floor+16,_r-24,_bottom,false);
    draw_set_alpha(0.12);draw_set_color(make_color_rgb(132,72,48));draw_rectangle(_l+18,_floor+8,_r-18,_floor+74,false);draw_set_alpha(1);
    draw_set_alpha(0.45);draw_set_color(make_color_rgb(4,4,7));draw_rectangle(_l+30,_floor+70,_r-30,_bottom,false);draw_set_alpha(1);

    // Cross-section strata match the ground strip: stone lip, dirt, then dark rock.
    static _bands=[
        [4,15,13,14],[4,143,138,135],[8,100,95,92],[10,24,12,14],
        [12,97,60,51],[8,66,39,28],[10,89,53,37],[8,61,48,42],
        [18,36,31,40],[20,29,26,35],[18,20,18,24],[14,12,11,16]
    ];
    static _off=[0,3,1,5,2,6,0,4,2,5,1,3];
    var _y=_floor;
    for(var _i=0;_i<array_length(_bands);_i++) {
        var _b=_bands[_i];var _h=_b[0];var _o=_off[_i];
        var _lw=10+_o+(_i mod 2)*2;
        var _rw=10+_off[(_i+3) mod array_length(_off)]+((_i+1) mod 2)*2;
        draw_set_color(make_color_rgb(_b[1],_b[2],_b[3]));
        draw_rectangle(_l,_y,_l+_lw,_y+_h,false);
        draw_rectangle(_r-_rw,_y,_r,_y+_h,false);
        draw_set_color(make_color_rgb(9,8,12));
        draw_rectangle(_l+_lw-2,_y,_l+_lw,_y+_h,false);
        draw_rectangle(_r-_rw,_y,_r-_rw+2,_y+_h,false);
        _y+=_h;
    }

    // Broken lips overhanging the rim, using the same stone and dirt tones.
    static _chunks=[
        [0,0,16,4,143,138,135],[0,6,24,5,100,95,92],[0,14,12,8,97,60,51],
        [0,30,20,6,66,39,28],[0,46,14,10,89,53,37],
        [1,2,20,4,143,138,135],[1,9,12,6,100,95,92],[1,18,26,5,24,12,14],
        [1,34,16,8,97,60,51],[1,52,22,6,61,48,42]
    ];
    for(var _c=0;_c<array_length(_chunks);_c++) {
        var _ch=_chunks[_c];
        draw_set_color(make_color_rgb(_ch[4],_ch[5],_ch[6]));
        if(_ch[0]==0)draw_rectangle(_l-4,_floor+_ch[1],_l+_ch[2]-4,_floor+_ch[1]+_ch[3],false);
        else draw_rectangle(_r-_ch[2]+4,_floor+_ch[1],_r+4,_floor+_ch[1]+_ch[3],false);
    }

    // Rubble ledges and warm rim light give the cut depth.
    static _ledges=[[0.26,34,34,8],[0.68,74,44,9],[0.44,108,28,7]];
    for(var _li=0;_li<array_length(_ledges);_li++) {
        var _lg=_ledges[_li];
        var _lx=_l+(_r-_l)*_lg[0];var _ly=_floor+_lg[1];
        draw_set_color(make_color_rgb(17,15,20));draw_rectangle(_lx-_lg[2]/2,_ly,_lx+_lg[2]/2,_ly+_lg[3],false);
        draw_set_color(make_color_rgb(51,43,54));draw_rectangle(_lx-_lg[2]/2,_ly,_lx+_lg[2]/2,_ly+2,false);
        draw_set_alpha(0.30);draw_set_color(make_color_rgb(158,92,58));draw_rectangle(_lx-_lg[2]/2,_ly,_lx+_lg[2]/2,_ly+1,false);draw_set_alpha(1);
    }

    // Cracks and loose stones spread from the rim onto the banks.
    draw_set_alpha(0.65);draw_set_color(make_color_rgb(22,16,18));
    draw_line_width(_l-26,_floor+3,_l-6,_floor+12,2);
    draw_line_width(_l-38,_floor+9,_l-10,_floor+18,2);
    draw_line_width(_l-18,_floor+19,_l-4,_floor+28,2);
    draw_line_width(_r+26,_floor+2,_r+8,_floor+11,2);
    draw_line_width(_r+42,_floor+10,_r+12,_floor+17,2);
    draw_line_width(_r+22,_floor+20,_r+6,_floor+27,2);
    draw_set_alpha(1);
    static _stones=[[0,-40,3,8,5],[0,-58,11,4,4],[0,-24,17,6,3],[1,34,4,8,5],[1,56,13,5,4],[1,22,19,6,3]];
    for(var _s=0;_s<array_length(_stones);_s++) {
        var _st=_stones[_s];
        var _sx=(_st[0]==0?_l+_st[1]:_r+_st[1]);
        var _sy=_floor+_st[2];
        draw_set_color(make_color_rgb(17,13,16));draw_rectangle(_sx-1,_sy+_st[4]-1,_sx+_st[3]+1,_sy+_st[4]+1,false);
        draw_set_color(make_color_rgb(78,68,67));draw_rectangle(_sx,_sy,_sx+_st[3],_sy+_st[4],false);
        draw_set_color(make_color_rgb(122,111,105));draw_rectangle(_sx,_sy,_sx+_st[3],_sy+1,false);
    }

    // Low haze and slow embers rising out of the dark.
    for(var _m=0;_m<4;_m++) {
        draw_set_alpha(0.035+_m*0.03);draw_set_color(make_color_rgb(40,42,54));
        draw_rectangle(_l+8,_floor+88+_m*12,_r-8,_floor+100+_m*12,false);
    }
    draw_set_alpha(1);
    scr_cut_motes(global.game_timer,10,_l+20,_floor+20,_r-_l-40,110,make_color_rgb(255,178,104),0.35,17,0.28);

    draw_set_alpha(0.45);draw_set_color(make_color_rgb(198,124,78));
    draw_rectangle(_l,_floor,_l+14,_floor+2,false);
    draw_rectangle(_r-14,_floor,_r,_floor+2,false);
    draw_set_alpha(1);
    draw_set_color(c_white);
}

function scr_begin_pause() {
    global.game_state="pause";
    global.pause_index=0;
    global.pause_stage=0;
    global.pause_timer=0;
    global.pause_guard=0;
    scr_sfx(sfx_ui_back,0,0.8);
    window_set_cursor(cr_default);
}

function scr_resume_game() {
    global.game_state="play";
    global.pause_stage=0;
    global.pause_guard=3;
    scr_sfx(sfx_ui_confirm);
    window_set_cursor(cr_default);
}

function scr_pause_option_rect(_index) {
    var _l=466;var _r=900;var _top=252;var _h=62;var _gap=14;
    var _y=_top+_index*(_h+_gap);
    return [_l,_y,_r,_y+_h];
}

function scr_pause_select(_choice) {
    if(_choice==0) { scr_resume_game(); return; }
    if(_choice==1) {
        global.pause_stage=1;
        global.settings_index=0;
        scr_sfx(sfx_ui_confirm);
        return;
    }
    if(_choice==2) {
        global.game_state="play";
        global.game_timer=0;
        global.pause_stage=0;
        global.pause_guard=3;
        window_set_cursor(cr_default);
        scr_sfx(sfx_ui_confirm);
        // Reset players for the selected mode.
        for(var _i=0;_i<2;_i++) {
            var _p=instance_find((_i==0?obj_player_p1:obj_player_p2),0);
            if(_p==noone)continue;
            _p.dead=false;
            _p.player_lives=3;
            _p.active_player=(global.player_count==2 || global.solo_character==_i);
            _p.respawn_x=(_i==0?270:1096);
            _p.respawn_y=scr_floor_y();
            _p.x=_p.respawn_x;_p.y=_p.respawn_y;
            _p.vy=0;_p.grounded=true;
            _p.material_count=0;_p.built_total=0;_p.collected_total=0;
            _p.fall_hits=0;_p.enemy_hits=0;_p.recoveries=0;
            _p.reset_blocks_total=0;_p.checkpoint_level=0;
            _p.invulnerable=0;_p.charge=0;_p._hthrust=0;
            _p._jump_was_held=false;_p._charge_dir=0;_p.jump_held=false;
            _p.qa_target=noone;_p.last_support=noone;_p.last_move=0;
            _p.facing=(_i==0?1:-1);
        }
        // Clear blocks.
        for(var _bi=instance_number(obj_build_block)-1;_bi>=0;_bi--) {
            var _b=instance_find(obj_build_block,_bi);
            if(_b!=noone && !_b.is_checkpoint) instance_destroy(_b);
        }
        var _game=instance_find(obj_game,0);
        if(_game!=noone) { _game.camera_y=room_height-768; camera_set_view_pos(_game.cam,0,_game.camera_y); }
        return;
    }
    window_set_cursor(cr_default);
    scr_sfx(sfx_ui_back);
    scr_return_to_title();
}

function scr_pause_input() {
    if(global.pause_stage==1) {
        var _vert = (keyboard_check_pressed(ord("W")) || keyboard_check_pressed(vk_up))
            - (keyboard_check_pressed(ord("S")) || keyboard_check_pressed(vk_down));
        var _horiz = (keyboard_check_pressed(ord("D")) || keyboard_check_pressed(vk_right))
            - (keyboard_check_pressed(ord("A")) || keyboard_check_pressed(vk_left));
        if(_vert!=0) {
            var _next_ps=clamp(global.settings_index-_vert,0,2);
            if(_next_ps!=global.settings_index) {
                global.settings_index=_next_ps;
                scr_sfx(sfx_ui_move);
            }
        }
        if(_horiz!=0) {
            if(global.settings_index==0) {
                scr_audio_music_toggle();
                scr_settings_save();
                scr_sfx(sfx_ui_confirm);
            } else if(global.settings_index==1) {
                scr_audio_volume(0.1*_horiz);
                scr_settings_save();
                scr_sfx(sfx_ui_move);
            } else if(global.settings_index==2) {
                window_set_fullscreen(!window_get_fullscreen());
                scr_settings_save();
                scr_sfx(sfx_ui_confirm);
            }
        }
        if(keyboard_check_pressed(vk_escape)||keyboard_check_pressed(ord("E"))||keyboard_check_pressed(vk_enter)) {
            global.pause_stage=0;
            scr_settings_save();
            scr_sfx(sfx_ui_back);
        }
        return;
    }
    if(keyboard_check_pressed(vk_escape)||keyboard_check_pressed(ord("P"))) {
        scr_resume_game();
        return;
    }
    var _mx=device_mouse_x_to_gui(0);
    var _my=device_mouse_y_to_gui(0);
    var _hover=-1;
    for(var _i=0;_i<4;_i++) {
        var _r=scr_pause_option_rect(_i);
        if(point_in_rectangle(_mx,_my,_r[0],_r[1],_r[2],_r[3]))_hover=_i;
    }
    if(_hover!=-1)window_set_cursor(cr_handpoint);
    else window_set_cursor(cr_default);
    // Gamepad navigation for pause menu (manual edge detection).
    var _gp=scr_gamepad_for_player(0);
    var _gp_nav=0;
    if(_gp>=0) {
        var _gpy=gamepad_axis_value(_gp,gp_axislv);
        var _gp_up=gamepad_button_check(_gp,gp_padu)||(_gpy<-0.6);
        var _gp_down=gamepad_button_check(_gp,gp_padd)||(_gpy>0.6);
        if(_gp_up && !global.gp_prev_pu) _gp_nav=-1;
        if(_gp_down && !global.gp_prev_pd) _gp_nav=1;
        global.gp_prev_pu=_gp_up; global.gp_prev_pd=_gp_down;
    }
    var _nav=(keyboard_check_pressed(ord("S"))||keyboard_check_pressed(vk_down))-(keyboard_check_pressed(ord("W"))||keyboard_check_pressed(vk_up));
    if(_gp_nav!=0) _nav=_gp_nav;
    // Do not let mouse hover override keyboard/gamepad selection (prevents the
    // selector from snapping back to the last option while navigating).
    if(_nav!=0) {
        global.pause_index=(global.pause_index+_nav+4) mod 4;
        scr_sfx(sfx_ui_move);
    }
    var _click=mouse_check_button_pressed(mb_left) && _hover!=-1;
    var _confirm=keyboard_check_pressed(ord("E"))||keyboard_check_pressed(vk_enter);
    var _gp_confirm=false;
    if(_gp>=0) {
        var _gpc=gamepad_button_check(_gp,scr_gamepad_jump_btn(_gp));
        _gp_confirm=_gpc && !global.gp_prev_pc;
        global.gp_prev_pc=_gpc;
    }
    _confirm=_confirm||_gp_confirm;
    if(!_click && !_confirm)return;
    if(_click)global.pause_index=_hover;
    scr_pause_select(global.pause_index);
}

function scr_pause_icon(_kind,_x,_y,_col) {
    draw_set_color(_col);
    if(_kind==0) {
        draw_triangle(_x-7,_y-12,_x-7,_y+12,_x+11,_y,false);
    } else if(_kind==1) {
        draw_circle(_x,_y,11,true);
        draw_circle(_x,_y,4,true);
        for(var _i=0;_i<8;_i++) {
            var _a=_i*45;
            draw_line_width(_x+lengthdir_x(13,_a),_y+lengthdir_y(13,_a),_x+lengthdir_x(18,_a),_y+lengthdir_y(18,_a),3);
        }
    } else if(_kind==2) {
        draw_circle(_x,_y,12,true);
        draw_triangle(_x+3,_y-18,_x+17,_y-15,_x+10,_y-4,false);
    } else {
        draw_rectangle(_x-9,_y-13,_x+9,_y+13,true);
        draw_circle(_x+4,_y,2,false);
    }
}

function scr_draw_pause() {
    draw_set_alpha(0.74);
    draw_set_color(make_color_rgb(8,13,20));
    draw_rectangle(0,0,1366,768,false);
    draw_set_alpha(1);
    if(global.pause_stage==1) { scr_draw_settings(); return; }
    var _l=423;var _t=126;var _r=943;var _b=628;var _cx=683;
    draw_set_color(make_color_rgb(8,13,20));draw_rectangle(_l+9,_t+9,_r+9,_b+9,false);
    draw_set_color(make_color_rgb(232,190,106));draw_rectangle(_l,_t,_r,_b,false);
    draw_set_color(make_color_rgb(27,38,48));draw_rectangle(_l+4,_t+4,_r-4,_b-4,false);
    scr_cut_glow(_cx,_t+66,150+sin(global.pause_timer/20)*10,make_color_rgb(255,206,130),0.18);
    var _ix=_cx-92;var _iy=_t+64;
    draw_set_color(make_color_rgb(245,232,201));
    draw_roundrect(_ix-14,_iy-22,_ix-4,_iy+22,false);
    draw_roundrect(_ix+4,_iy-22,_ix+14,_iy+22,false);
    draw_set_halign(fa_center);draw_set_valign(fa_middle);
    draw_text_transformed(_cx+18,_iy,"PAUSA",2.0,2.0,0);
    draw_set_color(make_color_rgb(77,93,96));draw_rectangle(_l+46,_t+108,_r-46,_t+112,false);
    for(var _i=0;_i<4;_i++) {
        var _rect=scr_pause_option_rect(_i);
        var _orl=_rect[0];var _ort=_rect[1];var _orr=_rect[2];var _orb=_rect[3];
        var _sel=global.pause_index==_i;
        draw_set_color(make_color_rgb(10,15,22));draw_rectangle(_orl+4,_ort+4,_orr+4,_orb+4,false);
        draw_set_color(_sel?make_color_rgb(232,190,106):make_color_rgb(58,72,80));
        draw_rectangle(_orl,_ort,_orr,_orb,false);
        draw_set_color(_sel?make_color_rgb(43,57,65):make_color_rgb(24,34,43));
        draw_rectangle(_orl+3,_ort+3,_orr-3,_orb-3,false);
        var _cy=(_ort+_orb)/2;
        var _col=_sel?make_color_rgb(255,222,151):make_color_rgb(155,173,166);
        scr_pause_icon(_i,_orl+40,_cy,_col);
        draw_set_halign(fa_left);draw_set_valign(fa_middle);
        draw_set_color(_sel?make_color_rgb(245,232,201):make_color_rgb(168,184,176));
        draw_text_transformed(_orl+82,_cy+1,["CONTINUAR","AJUSTES","REINICIAR","SAIR PARA O MENU"][_i],1.15,1.15,0);
        if(_sel) {
            draw_set_color(make_color_rgb(255,222,151));
            draw_triangle(_orr-30,_cy,_orr-42,_cy-9,_orr-42,_cy+9,false);
        }
    }
    draw_set_color(make_color_rgb(77,93,96));draw_rectangle(_l+46,_b-66,_r-46,_b-62,false);
    scr_ui_hint(_l+112,_b-34,"W S","NAVEGAR");
    scr_ui_hint(_cx+12,_b-34,"E","CONFIRMAR");
    scr_ui_hint(_r-110,_b-34,"ESC","CONTINUAR");
    draw_set_halign(fa_left);draw_set_valign(fa_top);draw_set_color(c_white);
}
