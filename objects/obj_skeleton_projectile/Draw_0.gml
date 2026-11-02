if(global.game_state!="play" && global.game_state!="pause")exit;
// spr_skel_orb_sheet: 80x48 cells, orb centred at (40,24); frames 2-3 carry a trail that points back along the flight.
var _cw=80,_ch=48;
var _f=(life>165?0:(life>155?1:2+((life div 4) mod 2)));
var _rot=point_direction(0,0,vx,vy);
var _a=-_cw*0.5;var _b=-_ch*0.5;
var _ox=_a*dcos(_rot)+_b*dsin(_rot);
var _oy=-_a*dsin(_rot)+_b*dcos(_rot);
draw_sprite_general(spr_skel_orb_sheet,0,_f*_cw,0,_cw,_ch,x+_ox,y+_oy,1,1,_rot,c_white,c_white,c_white,c_white,1);
