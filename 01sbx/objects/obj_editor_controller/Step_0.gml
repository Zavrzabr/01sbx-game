var _view_w = room_width * cam_zoom;
var _view_h = room_height * cam_zoom;

// ==========================================
// ЗУМ КОЛЕСИКОМ МЫШИ
// ==========================================
if (!is_gluing && !menu_open) {
    if (mouse_wheel_up())   cam_zoom = max(min_zoom, cam_zoom - 0.1);
    if (mouse_wheel_down()) cam_zoom = min(max_zoom, cam_zoom + 0.1);
}

_view_w = room_width * cam_zoom;
_view_h = room_height * cam_zoom;

var _shift_pressed  = keyboard_check(vk_shift);
var _option_pressed = keyboard_check(vk_alt);

// ==========================================
// КЛИКИ ПО КНОПКАМ ИНТЕРФЕЙСА И МЕНЮ (GUI)
// ==========================================

if (button_pressed_timer > 0) {
	button_pressed_timer--
}
function button_pressed(delay, change) {
	if (change) {
		button_pressed_timer = delay
	}
	if (!change && button_pressed_timer > 0) { return true } 
	else { return false }
}

var _gui_mx = device_mouse_x_to_gui(0);
var _gui_my = device_mouse_y_to_gui(0);

menu_target_x = menu_open ? (window_get_width() - menu_width) : window_get_width() + 3;
menu_current_x = lerp(menu_current_x, menu_target_x, menu_anim_speed);

if (keyboard_check_pressed(vk_escape)) {
    if (menu_open) {
        menu_open = false;
        exit;
    }
}
if (mouse_check_button_pressed(mb_left)) {

    if (_gui_mx >= btn_build_x && _gui_mx <= btn_build_x + 32 && _gui_my >= btn_build_y && _gui_my <= btn_build_y + 32) {
        editor_mode = "build";
        grab_edge = "none";
        is_gluing = false;
		button_pressed(15, true)
        

        if (current_time - btn_build_last_click < 250) {
            menu_open = !menu_open;
        }
        btn_build_last_click = current_time;
        exit;
    }
    
    if (_gui_mx >= btn_cam_x && _gui_mx <= btn_cam_x + 32 && _gui_my >= btn_cam_y && _gui_my <= btn_cam_y + 32) {
        editor_mode = "camera";
        grab_edge = "none";
        is_gluing = false;
        menu_open = false;
        exit;
    }
    
    if (menu_open && _gui_mx >= menu_current_x) {
        var _start_item_y = 40;
        var _item_height = 50;
        
        for (var i = 0; i < array_length(available_blocks); i++) {
            var _iy1 = _start_item_y + (i * _item_height);
            var _iy2 = _iy1 + 40;
            
            if (_gui_my >= _iy1 && _gui_my <= _iy2 && _gui_mx >= menu_current_x + 10 && _gui_mx <= window_get_width() - 10) {
                selected_block_index = i;
            }
        }
        exit;
    }
}

// ==========================================
// РЕЖИМ КАМЕРЫ ("camera")
// ==========================================
if (editor_mode == "camera") {
    if (mouse_check_button_pressed(mb_left)) {
        var _near_x1 = abs(mouse_x - world_x1) < (grab_margin * cam_zoom);
        var _near_x2 = abs(mouse_x - world_x2) < (grab_margin * cam_zoom);
        var _near_y1 = abs(mouse_y - world_y1) < (grab_margin * cam_zoom);
        var _near_y2 = abs(mouse_y - world_y2) < (grab_margin * cam_zoom);
        
        var _inside_x = (mouse_x >= world_x1 && mouse_x <= world_x2);
        var _inside_y = (mouse_y >= world_y1 && mouse_y <= world_y2);

        if (_near_x1 && _near_y1)      grab_edge = "top_left";
        else if (_near_x2 && _near_y2) grab_edge = "bottom_right";
        else if (_near_y1 && _inside_x) grab_edge = "top";
        else if (_near_y2 && _inside_x) grab_edge = "bottom";
        else if (_near_x1 && _inside_y) grab_edge = "left";
        else if (_near_x2 && _inside_y) grab_edge = "right";
        else {
            grab_edge = "camera";
            drag_mouse_x = window_mouse_get_x();
            drag_mouse_y = window_mouse_get_y();
        }
    }

    if (mouse_check_button(mb_left)) {
        if (grab_edge == "camera") {
            var _curr_win_x = window_mouse_get_x();
            var _curr_win_y = window_mouse_get_y();
            
            cam_x -= (_curr_win_x - drag_mouse_x) * cam_zoom;
            cam_y -= (_curr_win_y - drag_mouse_y) * cam_zoom;
            
            drag_mouse_x = _curr_win_x;
            drag_mouse_y = _curr_win_y;
        } else if (grab_edge != "none") {
            var _snapped_x = round(mouse_x / cell_size) * cell_size;
            var _snapped_y = round(mouse_y / cell_size) * cell_size;
            
            switch (grab_edge) {
                case "top_left":
                    world_x1 = min(_snapped_x, world_x2 - min_world_width);
                    world_y1 = min(_snapped_y, world_y2 - min_world_height);
                    break;
                case "bottom_right":
                    world_x2 = max(_snapped_x, world_x1 + min_world_width);
                    world_y2 = max(_snapped_y, world_y1 + min_world_height);
                    break;
                case "top":
                    world_y1 = min(_snapped_y, world_y2 - min_world_height);
                    break;
                case "bottom":
                    world_y2 = max(_snapped_y, world_y1 + min_world_height);
                    break;
                case "left":
                    world_x1 = min(_snapped_x, world_x2 - min_world_width);
                    break;
                case "right":
                    world_x2 = max(_snapped_x, world_x1 + min_world_width);
                    break;
            }
            update_grid_size();
        }
    }
    
    if (mouse_check_button_released(mb_left)) {
        grab_edge = "none";
    }
}

// ==========================================
// РЕЖИМ СТРОИТЕЛЬСТВА ("build")
// ==========================================
if (editor_mode == "build") {
    
    // Блокируем любое строительство/клей в мире, если мышь кликает внутри открытого меню
    var _mouse_in_menu = ((menu_open && _gui_mx >= menu_current_x) or editing_frequency or button_pressed(0, false));
    if (!_mouse_in_menu) {
        // МЕХАНИКА КЛЕЯ (SHIFT + ЛКМ)
        if (_shift_pressed && mouse_check_button_pressed(mb_left) && !_option_pressed) {
            is_gluing = true;
            glue_start_x = mouse_x;
            glue_start_y = mouse_y;
        }

        if (is_gluing) {
            if (mouse_check_button_released(mb_left)) {
                is_gluing = false;
                
                var _dist = point_distance(glue_start_x, glue_start_y, mouse_x, mouse_y);
                var _steps = max(1, floor(_dist / 5)); 
                var _prev_block = noone;
                
                for (var i = 0; i <= _steps; i++) {
                    var _t = i / _steps;
                    var _px = lerp(glue_start_x, mouse_x, _t);
                    var _py = lerp(glue_start_y, mouse_y, _t);
                    
                    var _gx = floor((_px - world_x1) / cell_size);
                    var _gy = floor((_py - world_y1) / cell_size);
                    
                    var _found_block = noone;
                    
                    with (obj_block) {
                        if (grid_x == _gx && grid_y == _gy) { _found_block = id; break; }
                    }
                    if (_found_block == noone) {
                        with (obj_block_oscillator) {
                            if (grid_x == _gx && grid_y == _gy) { _found_block = id; break; }
                        }
                    }
                    
					if (_found_block == noone) {
                        with (obj_block_chainer) {
                            if (grid_x == _gx && grid_y == _gy) { _found_block = id; break; }
                        }
                    }
					if (_found_block == noone) {
                        with (obj_block_blocker) {
                            if (grid_x == _gx && grid_y == _gy) { _found_block = id; break; }
                        }
                    }
					if (_found_block == noone) {
                        with (obj_block_teleporter) {
                            if (grid_x == _gx && grid_y == _gy) { _found_block = id; break; }
                        }
                    }
					if (_found_block == noone) {
                        with (obj_block_receiver) {
                            if (grid_x == _gx && grid_y == _gy) { _found_block = id; break; }
                        }
                    }
                    if (_found_block != noone && _found_block != _prev_block) {
                        if (_prev_block != noone) {
                            with(_prev_block) { connect_with_neighbor(_found_block); }
                        }
                        _prev_block = _found_block;
                    }
                }
            }
        }
        
        // СТРОИТЕЛЬСТВО И СТИРАНИЕ
        if (!is_gluing) {
            if (mouse_x >= world_x1 && mouse_x < world_x2 && mouse_y >= world_y1 && mouse_y < world_y2) {
                var _cell_x = floor((mouse_x - world_x1) / cell_size);
                var _cell_y = floor((mouse_y - world_y1) / cell_size);
                
                if (_cell_x >= 0 && _cell_x < grid_width_cells && _cell_y >= 0 && _cell_y < grid_height_cells) {
                    var _bx = world_x1 + (_cell_x * cell_size);
                    var _by = world_y1 + (_cell_y * cell_size);
                    
                    if (mouse_check_button(mb_left) && _option_pressed) {
                        var _target_block = noone;
                        
                        with (obj_block) {
                            if (grid_x == _cell_x && grid_y == _cell_y) { _target_block = id; break; }
                        }
                        if (_target_block == noone) {
                            with (obj_block_oscillator) {
                                if (grid_x == _cell_x && grid_y == _cell_y) { _target_block = id; break; }
                            }
                        }
						
						if (_target_block == noone) {
                            with (obj_block_chainer) {
                                if (grid_x == _cell_x && grid_y == _cell_y) { _target_block = id; break; }
                            }
                        }
						if (_target_block == noone) {
                            with (obj_block_blocker) {
                                if (grid_x == _cell_x && grid_y == _cell_y) { _target_block = id; break; }
                            }
                        }
						if (_target_block == noone) {
                            with (obj_block_teleporter) {
                                if (grid_x == _cell_x && grid_y == _cell_y) { _target_block = id; break; }
                            }
                        }
						if (_target_block == noone) {
                            with (obj_block_receiver) {
                                if (grid_x == _cell_x && grid_y == _cell_y) { _target_block = id; break; }
                            }
                        }
						
                        if (_target_block != noone) {
                            // Сбрасываем флаги соединений у всех соседних сигнальщиков вокруг стираемой клетки
                            with (obj_block) {
                                if (grid_x == _cell_x - 1 && grid_y == _cell_y) r = false;
                                if (grid_x == _cell_x + 1 && grid_y == _cell_y) l = false;
                                if (grid_x == _cell_x && grid_y == _cell_y - 1) d = false;
                                if (grid_x == _cell_x && grid_y == _cell_y + 1) u = false;
                            }
                            // Сбрасываем флаги соединений у всех соседних осцилляторов вокруг
                            with (obj_block_oscillator) {
                                if (grid_x == _cell_x - 1 && grid_y == _cell_y) r = false;
                                if (grid_x == _cell_x + 1 && grid_y == _cell_y) l = false;
                                if (grid_x == _cell_x && grid_y == _cell_y - 1) d = false;
                                if (grid_x == _cell_x && grid_y == _cell_y + 1) u = false;
                            }
							with (obj_block_chainer) {
                                if (grid_x == _cell_x - 1 && grid_y == _cell_y) r = false;
                                if (grid_x == _cell_x + 1 && grid_y == _cell_y) l = false;
                                if (grid_x == _cell_x && grid_y == _cell_y - 1) d = false;
                                if (grid_x == _cell_x && grid_y == _cell_y + 1) u = false;
                            }
                            with (obj_block_blocker) {
                                if (grid_x == _cell_x - 1 && grid_y == _cell_y) r = false;
                                if (grid_x == _cell_x + 1 && grid_y == _cell_y) l = false;
                                if (grid_x == _cell_x && grid_y == _cell_y - 1) d = false;
                                if (grid_x == _cell_x && grid_y == _cell_y + 1) u = false;
                            }
							with (obj_block_teleporter) {
                                if (grid_x == _cell_x - 1 && grid_y == _cell_y) r = false;
                                if (grid_x == _cell_x + 1 && grid_y == _cell_y) l = false;
                                if (grid_x == _cell_x && grid_y == _cell_y - 1) d = false;
                                if (grid_x == _cell_x && grid_y == _cell_y + 1) u = false;
                            }
                            with (obj_block_receiver) {
                                if (grid_x == _cell_x - 1 && grid_y == _cell_y) r = false;
                                if (grid_x == _cell_x + 1 && grid_y == _cell_y) l = false;
                                if (grid_x == _cell_x && grid_y == _cell_y - 1) d = false;
                                if (grid_x == _cell_x && grid_y == _cell_y + 1) u = false;
                            }
                            instance_destroy(_target_block);
                        }
                    }
                    
                    // ДИНАМИЧЕСКОЕ СТРОИТЕЛЬСТВО
                    else if (mouse_check_button(mb_left) && !_shift_pressed && !_option_pressed) {
                        var _already_exists = false;
                        
                        // Проверяем, не занята ли клетка сигнальщиком...
                        with (obj_block) {
                            if (grid_x == _cell_x && grid_y == _cell_y) _already_exists = true;
                        }
                        // ...или осциллятором!...
                        with (obj_block_oscillator) {
                            if (grid_x == _cell_x && grid_y == _cell_y) _already_exists = true;
                        }
						// ...а может это чейнер?
						with (obj_block_chainer) {
                            if (grid_x == _cell_x && grid_y == _cell_y) _already_exists = true;
                        }
						
						with (obj_block_blocker) {
                            if (grid_x == _cell_x && grid_y == _cell_y) _already_exists = true;
                        }
						with (obj_block_teleporter) {
                            if (grid_x == _cell_x && grid_y == _cell_y) _already_exists = true;
                        }
						with (obj_block_receiver) {
                            if (grid_x == _cell_x && grid_y == _cell_y) _already_exists = true;
                        }
                        
                        if (!_already_exists) {
                            var _current_block_data = available_blocks[selected_block_index];
                            var _inst = instance_create_layer(_bx, _by, "Instances", _current_block_data.object);
                            _inst.grid_x = _cell_x;
                            _inst.grid_y = _cell_y;
                        }
                    }
                }
            }
        }
    }
}

if (double_click_timer > 0) double_click_timer -= 1;

if (mouse_check_button_pressed(mb_left) && !menu_open) {
    var _clicked_inst = instance_position(mouse_x, mouse_y, obj_block_teleporter);
    if (_clicked_inst == noone) {
        _clicked_inst = instance_position(mouse_x, mouse_y, obj_block_receiver);
    }
    
    // Если нашли блок
    if (_clicked_inst != noone) {
        if (double_click_timer > 0) {
            button_pressed(15, true);
            editing_block = _clicked_inst;
            menu_open = true;
            double_click_timer = 0;
        } else {
            // Это был только первый клик, даем игроку 15 кадров на второй клик
            double_click_timer = 15;
        }
    }
}

// ==========================================
// ОБНОВЛЕНИЕ КАМЕРЫ И СИМУЛЯЦИИ
// ==========================================
camera_set_view_pos(view_camera[0], cam_x + room_width/2 - _view_w/2, cam_y + room_height/2 - _view_h/2);
camera_set_view_size(view_camera[0], _view_w, _view_h);

var _should_tick = false;

if (!sim_paused) {
    sim_timer += 1;
    if (sim_timer >= sim_speed) {
        sim_timer = 0;
        _should_tick = true;
    }
} else if (sim_do_single_step) {
    sim_do_single_step = false;
    _should_tick = true;
}

if (_should_tick) {
   
    global.teleporter_frequencies = json_parse("{}");
    
    // -1. Удаление за границами мира
    with (obj_block) { if (x < other.world_x1 || x >= other.world_x2 || y < other.world_y1 || y >= other.world_y2) instance_destroy(); }
    with (obj_block_oscillator) { if (x < other.world_x1 || x >= other.world_x2 || y < other.world_y1 || y >= other.world_y2) instance_destroy(); }
    with (obj_block_chainer) { if (x < other.world_x1 || x >= other.world_x2 || y < other.world_y1 || y >= other.world_y2) instance_destroy(); }
    with (obj_block_blocker) { if (x < other.world_x1 || x >= other.world_x2 || y < other.world_y1 || y >= other.world_y2) instance_destroy(); }
    with (obj_block_teleporter) { if (x < other.world_x1 || x >= other.world_x2 || y < other.world_y1 || y >= other.world_y2) instance_destroy(); }
    with (obj_block_receiver) { if (x < other.world_x1 || x >= other.world_x2 || y < other.world_y1 || y >= other.world_y2) instance_destroy(); }
    
    // Расчет
    with (obj_block)            { event_user(0); }
    with (obj_block_oscillator) { event_user(0); }
    with (obj_block_chainer)    { event_user(0); }
    with (obj_block_blocker)    { event_user(0); }
    with (obj_block_teleporter) { event_user(0); }
    with (obj_block_receiver)   { event_user(0); }
    
    // Применение
    with (obj_block)            { event_user(1); }
    with (obj_block_oscillator) { event_user(1); }
    with (obj_block_chainer)    { event_user(1); }
    with (obj_block_blocker)    { event_user(1); }
    with (obj_block_teleporter) { event_user(1); }
    with (obj_block_receiver)   { event_user(1); }
}

if (keyboard_check_pressed(vk_space)) {
    sim_paused = !sim_paused;
}

if (sim_paused && keyboard_check_pressed(vk_tab)) {
    sim_do_single_step = true;
}

var _modifier_pressed = false;
if (os_type == os_macosx) {
    _modifier_pressed = keyboard_check(vk_lmeta) || keyboard_check(vk_rmeta); 
} else {
    _modifier_pressed = keyboard_check(vk_control);
}

if (is_typing) {
    if (_modifier_pressed && keyboard_check_pressed(ord("V"))) {
        if (clipboard_has_text()) {
            input_text += clipboard_get_text();
        }
    }
    
    if (keyboard_check_pressed(vk_backspace)) {
        input_text = string_delete(input_text, string_length(input_text), 1);
    }
    
    if (keyboard_string != "") {
        if (!_modifier_pressed) {
            input_text += keyboard_string;
        }
        keyboard_string = "";
    }
    
    if (keyboard_check_pressed(vk_enter)) {
        if (input_text != "") {
            map_text_code = input_text;
            is_typing = false;
            target_load_path = ""; 
            show_load_confirm = true;
        }
    }
    
    if (keyboard_check_pressed(vk_escape)) {
        is_typing = false;
        menu_open = false;
    }
} 
else {
    if (_modifier_pressed) {
        if (keyboard_check_pressed(ord("S"))) {
            if (os_browser != browser_not_a_browser) {
                save_world(""); 
                show_io_save_window = true; 
                menu_open = true;
                
                if (map_text_code != "" && map_text_code != undefined) {
                    clipboard_set_text(map_text_code);
                }
            } else {
                var _path = get_save_filename("01sbx PC Map|*.01mapPC", default_save_name);
                if (_path != "") {
                    save_world(_path);
                    default_save_name = filename_name(_path); 
                }
            }
        }
        
        if (keyboard_check_pressed(ord("L"))) {
            if (os_browser != browser_not_a_browser) {
                input_text = "";
                keyboard_string = "";
                is_typing = true;
                menu_open = true;
            } else {
                show_pc_load_choice = true; 
                menu_open = true;
            }
        }
    }
}