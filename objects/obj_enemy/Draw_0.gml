if(global.game_state!="play")exit;
switch(kind) {
    case 0: {
        var _duck_bob=round(abs(sin(global.game_timer*0.35))*2);
        var _duck_dir=walk_dir;
        draw_set_color(make_color_rgb(232,190,84));
        draw_ellipse(x-18,y-10-_duck_bob,x+16,y+18-_duck_bob,false);
        draw_set_color(make_color_rgb(248,222,145));
        draw_circle(x+_duck_dir*13,y-14-_duck_bob,9,true);
        draw_set_color(make_color_rgb(235,138,52));
        draw_triangle(x+_duck_dir*20,y-16-_duck_bob,x+_duck_dir*29,y-12-_duck_bob,x+_duck_dir*20,y-8-_duck_bob,false);
        draw_rectangle(x-2,y+16-_duck_bob,x+3,y+32-_duck_bob,false);
        draw_rectangle(x+8,y+16-_duck_bob,x+13,y+32-_duck_bob,false);
        draw_set_color(make_color_rgb(35,28,30));
        draw_circle(x+_duck_dir*16,y-17-_duck_bob,2,false);
        break;
    }
    case 1: {
        var _bat_flap=sin(global.game_timer*0.45)*10;
        draw_set_color(make_color_rgb(72,50,88));
        draw_triangle(x-4,y-2,x-34,y-10-_bat_flap,x-10,y+10,false);
        draw_triangle(x+4,y-2,x+34,y-10-_bat_flap,x+10,y+10,false);
        draw_ellipse(x-11,y-13,x+11,y+12,false);
        draw_set_color(make_color_rgb(196,120,180));
        draw_circle(x-5,y-6,2,false);
        draw_circle(x+5,y-6,2,false);
        draw_set_color(make_color_rgb(240,240,220));
        draw_triangle(x-4,y+8,x-1,y+16,x+1,y+8,false);
        break;
    }
    case 2:
        scr_actor_pose(2,(global.game_timer div 12) mod 3,x,y+30,draw_height,cos(phase)>=0?1:-1);
        break;
    case 3: {
        var _star_pulse=0.7+0.3*sin(global.game_timer*0.2);
        draw_set_alpha(0.3);
        draw_set_color(make_color_rgb(255,236,160));
        draw_circle(x,y,22*_star_pulse,false);
        draw_set_alpha(0.45);
        for(var _trail=1;_trail<=3;_trail++) draw_circle(x+sin(phase*6+_trail)*3,y-_trail*14,6-_trail,false);
        draw_set_alpha(1);
        draw_set_color(make_color_rgb(255,214,90));
        draw_triangle(x,y-22,x-6,y-4,x+6,y-4,false);
        draw_triangle(x,y+22,x-6,y+4,x+6,y+4,false);
        draw_triangle(x-22,y,x-4,y-6,x-4,y+6,false);
        draw_triangle(x+22,y,x+4,y-6,x+4,y+6,false);
        draw_circle(x,y,9,false);
        draw_set_color(make_color_rgb(255,250,220));
        draw_circle(x-2,y-2,4,false);
        break;
    }
    case 4: {
        var _metal_drift=sin(phase*2)*3;
        draw_set_color(make_color_rgb(120,128,136));
        draw_rectangle(x-16+_metal_drift,y-12,x+2+_metal_drift,y+10,false);
        draw_rectangle(x+2+_metal_drift,y-2,x+18+_metal_drift,y+18,false);
        draw_set_color(make_color_rgb(170,178,186));
        draw_rectangle(x-14+_metal_drift,y-10,x+_metal_drift,y-6,false);
        draw_rectangle(x+4+_metal_drift,y,x+16+_metal_drift,y+4,false);
        draw_set_color(make_color_rgb(64,70,78));
        draw_circle(x-9+_metal_drift,y-2,2,false);
        draw_circle(x+9+_metal_drift,y+10,2,false);
        draw_set_color(make_color_rgb(220,110,70));
        draw_rectangle(x-3+_metal_drift,y+20,x+3+_metal_drift,y+25,false);
        break;
    }
}
draw_set_color(c_white);
