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

function scr_begin_intro() {
    global.player_count=(global.menu_mode==0?1:2);
    global.intro_seen=[false,false,false];
    for(var _i=0;_i<2;_i++) {
        var _p=instance_find((_i==0?obj_player_p1:obj_player_p2),0);
        _p.active_player=(global.player_count==2 || _i==global.solo_character);
        if(global.player_count==1 && _p.active_player){_p.x=672;_p.respawn_x=672;_p.facing=1;}
    }
    global.game_state="intro";global.game_timer=0;
    global.intro_scene=0;
    scr_music(mus_intro);scr_sfx(sfx_intro_whoosh);
}

function scr_menu_input(_direction,_confirm,_back) {
    if(_back && global.menu_stage==1){global.menu_stage=0;scr_sfx(sfx_ui_back);return;}
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
    if(global.qa) {var _input=scr_qa_input();scr_player_tick(_input[0],_input[1],_input[2]);}
    else if(global.player_count==1 || player_number==0)
        scr_player_tick(keyboard_check(ord("D"))-keyboard_check(ord("A")),keyboard_check_pressed(ord("W")),keyboard_check_pressed(ord("E")));
    else scr_player_tick(keyboard_check(vk_right)-keyboard_check(vk_left),keyboard_check_pressed(vk_up),keyboard_check_pressed(vk_enter));
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

function scr_draw_title_menu() {
    draw_sprite_stretched(ChatGPT_Image_31_Oct_2026__02_56_25,0,0,-80,1366,1020);
    draw_set_alpha(0.76);draw_set_color(make_color_rgb(13,22,31));draw_rectangle(0,0,1366,768,false);draw_set_alpha(1);
    // Rebuilding motif: three ascending blocks and a tiny sprout behind the title.
    draw_set_color(make_color_rgb(64,82,84));
    for(var _i=0;_i<7;_i++)draw_rectangle(516+_i*45,115-abs(3-_i)*12,550+_i*45,142,false);
    draw_set_halign(fa_center);draw_set_valign(fa_middle);
    draw_set_color(make_color_rgb(9,17,24));draw_text_transformed(688,207,"JUNTOS",6,6,0);
    draw_set_color(make_color_rgb(242,211,151));draw_text_transformed(683,200,"JUNTOS",6,6,0);
    for(var _c=0;_c<2;_c++) {
        var _cx=497+_c*372;var _selected=(global.menu_stage==0?global.menu_mode:global.solo_character)==_c;
        scr_ui_panel(_cx-153,318,_cx+153,616,_selected);
        if(global.menu_stage==0) {
            if(_c==0) {
                scr_actor_pose(global.solo_character,0,_cx,545,142,1);
                scr_ui_person(_cx,360,make_color_rgb(189,212,212));
            } else {
                scr_actor_pose(0,0,_cx-60,545,132,1);scr_actor_pose(1,0,_cx+60,545,132,-1);
                scr_ui_person(_cx-17,360,make_color_rgb(80,220,215));scr_ui_person(_cx+17,360,make_color_rgb(247,181,77));
            }
        } else {
            scr_actor_pose(_c,0,_cx,552,170,1);
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
