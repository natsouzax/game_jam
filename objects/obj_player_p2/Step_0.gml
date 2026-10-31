if(global.qa) {var _input=scr_qa_input();scr_player_tick(_input[0],_input[1],_input[2]);}
else scr_player_tick(keyboard_check(vk_right)-keyboard_check(vk_left),keyboard_check_pressed(vk_up),keyboard_check_pressed(vk_enter));
