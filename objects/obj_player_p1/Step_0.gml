if(global.qa) {var _input=scr_qa_input();scr_player_tick(_input[0],_input[1],_input[2]);}
else scr_player_tick(keyboard_check(ord("D"))-keyboard_check(ord("A")),keyboard_check_pressed(ord("W")),keyboard_check_pressed(ord("E")));
