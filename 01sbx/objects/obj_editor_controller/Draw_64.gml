function string_wrap_no_spaces(str, width) {
    var _new_str = "";
    var _temp_str = "";
    var _len = string_length(str);
    
    for (var i = 1; i <= _len; i++) {
        var _char = string_char_at(str, i);
        _temp_str += _char;
        
        if (string_width(_temp_str) > width) {
            _new_str += "\n" + _char; 
            _temp_str = _char;
        } else {
            _new_str += _char;
        }
    }
    return _new_str;
}

// ==========================================
// 1. INITIALIZATION & CURSOR DATA
// ==========================================
var _gui_w = display_get_gui_width();
var _gui_h = display_get_gui_height();
var _mx = device_mouse_x_to_gui(0);
var _my = device_mouse_y_to_gui(0);

draw_set_font(-1); 
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_alpha(1.0);


// ==========================================
// 2. EDITOR MODE BUTTONS (BUILD / CAMERA)
// ==========================================
if sprite_exists(spr_building) && sprite_exists(spr_watching) {
    var spr_w = sprite_get_width(spr_building) * 2;
    var spr_h = sprite_get_height(spr_building) * 2;
    
    draw_set_color(c_white);
    if (editor_mode == "build") {
        draw_rectangle(btn_build_x - 2, btn_build_y - 2, btn_build_x + spr_w + 2, btn_build_y + spr_h + 2, true);
    } else {
        draw_rectangle(btn_cam_x - 2, btn_cam_y - 2, btn_cam_x + spr_w + 2, btn_cam_y + spr_h + 2, true);
    }
    
    draw_sprite_ext(spr_building, 0, btn_build_x, btn_build_y, 2, 2, 0, c_white, 1);
    draw_sprite_ext(spr_watching, 0, btn_cam_x, btn_cam_y, 2, 2, 0, c_white, 1);
} else {
    draw_set_color(editor_mode == "build" ? c_lime : c_gray);
    draw_rectangle(btn_build_x, btn_build_y, btn_build_x + 16, btn_build_y + 16, false);
    draw_set_color(c_black); draw_text(btn_build_x + 3, btn_build_y, "B");
    
    draw_set_color(editor_mode == "camera" ? c_lime : c_gray);
    draw_rectangle(btn_cam_x, btn_cam_y, btn_cam_x + 16, btn_cam_y + 16, false);
    draw_set_color(c_black); draw_text(btn_cam_x + 3, btn_cam_y, "C");
}

draw_set_color(c_white);
draw_text(10, 10, "mode: " + string(editor_mode));


// ==========================================
// 3. SLIDE-OUT BUILDING MENU
// ==========================================
if (menu_current_x < _gui_w) {
    // Безопасный расчет размеров на базе GUI ширины
    var _win_menu_w = _gui_w + (0.5 * menu_current_x) - 555;
    var _win_menu_h = _gui_h;
    
    draw_set_color(c_black);
    draw_rectangle(menu_current_x, 0, _win_menu_w, _win_menu_h, false);
    
    draw_set_color(c_white);
    draw_line_width(menu_current_x, 0, menu_current_x, _win_menu_h, 2);
    
    draw_set_color(c_white);
    draw_text(menu_current_x + 15, 15, "BUILDER TOOLS:");
    
    var _start_item_y = 40;
    var _item_height = 50;
    
    for (var i = 0; i < array_length(available_blocks); i++) {
        var _block_info = available_blocks[i];
        
        var _ix1 = menu_current_x + 10;
        var _iy1 = _start_item_y + (i * _item_height);
        var _ix2 = _win_menu_w - 10;
        var _iy2 = _iy1 + 40;
        
        if (i == selected_block_index) {
            draw_set_color(c_white);
            draw_rectangle(_ix1, _iy1, _ix2, _iy2, true);
        } else {
            draw_set_color(c_black);
            draw_rectangle(_ix1, _iy1, _ix2, _iy2, true);
        }
        
        // КРИТИЧЕСКОЕ ИСПРАВЛЕНИЕ: HTML5 падал, если sprite был undefined
        if (variable_struct_exists(_block_info, "sprite") && _block_info.sprite != undefined) {
            if (sprite_exists(_block_info.sprite)) {
                draw_sprite_ext(_block_info.sprite, 0, _ix1, _iy1, 1, 1, 0, c_white, 1);
            }
        }
        
        draw_set_color(c_white);
        draw_text(_ix1 + 45, _iy1 + 12, string(_block_info.name));
    }
}


// ==========================================
// 4. BLOCK FREQUENCY SETTING WINDOW
// ==========================================
if (editing_block != noone && instance_exists(editing_block)) {
    editing_frequency = true;
    
    var _win_freq_w = 400;
    var _win_freq_h = 160;
    var _win_freq_x = (_gui_w - _win_freq_w) / 2;
    var _win_freq_y = (_gui_h - _win_freq_h) / 2;
    
    draw_set_color(c_black);
    draw_rectangle(_win_freq_x, _win_freq_y, _win_freq_x + _win_freq_w, _win_freq_y + _win_freq_h, false);
    draw_set_color(c_white);
    draw_rectangle(_win_freq_x, _win_freq_y, _win_freq_x + _win_freq_w, _win_freq_y + _win_freq_h, true);
    
    draw_set_font(fnt_press_start);
    draw_set_halign(fa_center);
    draw_text(_win_freq_x + _win_freq_w / 2, _win_freq_y + 20, "SET FREQUENCY (8-BIT)");
    
    var _start_boxes_x = _win_freq_x + 40;
    var _box_y = _win_freq_y + 60; 
    var _box_size = 32;       
    var _spacing = 8;         
    
    for (var i = 0; i < 8; i++) {
        var _bx = _start_boxes_x + i * (_box_size + _spacing);
        var _hover = (_mx >= _bx && _mx < _bx + _box_size && _my >= _box_y && _my < _box_y + _box_size);
        
        if (_hover && mouse_check_button_pressed(mb_left)) {
            editing_block.frequency_array[i] = (editing_block.frequency_array[i] == 0) ? 1 : 0;
        }
        
        draw_set_color(_hover ? c_yellow : c_white);
        draw_rectangle(_bx, _box_y, _bx + _box_size, _box_y + _box_size, true);
        
        draw_set_color(c_white);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        
        var _digit_string = string(editing_block.frequency_array[i]);
        draw_text(_bx + _box_size / 2, _box_y + _box_size / 2, _digit_string);
    }
    
    draw_set_valign(fa_top);
    var _btn_close_w = 100;
    var _btn_close_h = 30;
    var _btn_close_x = _win_freq_x + (_win_freq_w - _btn_close_w) / 2;
    var _btn_close_y = _win_freq_y + _win_freq_h - 40;
    
    var _btn_close_hover = (_mx >= _btn_close_x && _mx < _btn_close_x + _btn_close_w && _my >= _btn_close_y && _my < _btn_close_y + _btn_close_h);
    
    draw_set_color(_btn_close_hover ? c_red : c_white);
    draw_rectangle(_btn_close_x, _btn_close_y, _btn_close_x + _btn_close_w, _btn_close_y + _btn_close_h, true);
    
    draw_set_color(c_white);
    draw_set_halign(fa_center);
    draw_text(_btn_close_x + _btn_close_w / 2, _btn_close_y + 8, "CLOSE");
    
    if (_btn_close_hover && mouse_check_button_pressed(mb_left) && !button_pressed(0, false)) {
        button_pressed(15, true);
        editing_block = noone;
    }
    
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
} else { 
    editing_frequency = false; 
}


// ==========================================
// 5. LOAD CHOICE INTERFACE: FILE OR TEXT (PC)
// ==========================================
if (os_browser == browser_not_a_browser && show_pc_load_choice) {
    var _box_w = 400;
    var _box_h = 180;
    var _x1 = (_gui_w - _box_w) / 2;
    var _y1 = (_gui_h - _box_h) / 2;
    var _x2 = _x1 + _box_w;
    var _y2 = _y1 + _box_h;
    
    draw_set_color(c_black);
    draw_rectangle(_x1, _y1, _x2, _y2, false);
    draw_set_color(c_white);
    draw_rectangle(_x1, _y1, _x2, _y2, true);
    
    draw_set_halign(fa_center);
    draw_set_valign(fa_top);
    draw_text((_x1 + _x2) / 2, _y1 + 20, "MAP LOADING TYPE:\n\n[ F1 ] - File (.01mapPC)\n[ F2 ] - Text (JSON/Code)");
    
    if (keyboard_check_pressed(vk_f1)) {
        show_pc_load_choice = false;
        var _path = get_open_filename("01sbx PC Map|*.01mapPC", "");
        if (_path != "" && file_exists(_path)) {
            target_load_path = _path; 
            show_load_confirm = true;
        } else {
            menu_open = false;
        }
    }
    
    if (keyboard_check_pressed(vk_f2)) {
        show_pc_load_choice = false;
        input_text = "";
        keyboard_string = "";
        is_typing = true;
    }
    
    if (keyboard_check_pressed(vk_escape)) {
        show_pc_load_choice = false;
        menu_open = false;
    }
    draw_set_halign(fa_left);
}

// ==========================================
// 6. CUSTOM INPUT WINDOW (IMPORT)
// ==========================================
if (is_typing) {
    var _box_w = 640;
    var _padding = 20;
    
    draw_set_font(fnt_press_start);
    
    var _base_scale = 0.65;
    var _max_w = (_box_w - (_padding * 2) - 20) / _base_scale; 
    
    var _title_text = "PASTE MAP CODE AND PRESS ENTER";
    
    var _disp_text = "";
    if (input_text != "") {
        _disp_text = string_wrap_no_spaces(input_text, _max_w);
        var _cursor = (current_time mod 1000 < 500) ? "|" : "";
        _disp_text += _cursor;
    } else {
        _disp_text = "Paste code here (Cmd+V / Ctrl+V)...";
    }
    
    var _raw_height = string_height(_disp_text);
    var _text_scale = _base_scale;
    var _max_allowed_height = 220; 
    
    if ((_raw_height * _text_scale) > _max_allowed_height) {
        _text_scale = _max_allowed_height / _raw_height;
    }
    
    var _text_height = _raw_height * _text_scale;
    var _box_h = clamp(55 + _text_height + 65, 160, 400); 
    
    var _x1 = (_gui_w - _box_w) / 2;
    var _y1 = (_gui_h - _box_h) / 2;
    var _x2 = _x1 + _box_w;
    var _y2 = _y1 + _box_h;
    
    draw_set_color(c_black); draw_rectangle(_x1, _y1, _x2, _y2, false);
    draw_set_color(c_white); draw_rectangle(_x1, _y1, _x2, _y2, true);
    
    draw_set_halign(fa_center); draw_set_valign(fa_top);
    draw_text((_x1 + _x2) / 2, _y1 + 15, _title_text);
    
    var _tx1 = _x1 + _padding;
    var _ty1 = _y1 + 45;
    var _tx2 = _x2 - _padding;
    var _ty2 = _y2 - 50;
    
    draw_set_color(c_black); draw_rectangle(_tx1, _ty1, _tx2, _ty2, false);
    draw_set_color(c_white); draw_rectangle(_tx1, _ty1, _tx2, _ty2, true);
    
    draw_set_halign(fa_left);
    draw_set_color((input_text == "") ? c_gray : c_white);
    
    draw_text_transformed(_tx1 + 10, _ty1 + 8, _disp_text, _text_scale, _text_scale, 0);
    
    draw_set_color(c_white); draw_set_halign(fa_center);
    draw_text((_x1 + _x2) / 2, _y2 - 25, "[Cmd+V/Ctrl+V] - Paste | [ESC] - Cancel");
    
    draw_set_halign(fa_left); draw_set_valign(fa_top);
}

// ==========================================
// 7. LOAD CONFIRMATION WINDOW
// ==========================================
if (show_load_confirm) {
    var _win_conf_w = 320;
    var _win_conf_h = 140;
    var _win_conf_x = (_gui_w - _win_conf_w) / 2;
    var _win_conf_y = (_gui_h - _win_conf_h) / 2;
    
    draw_set_alpha(0.5);
    draw_set_color(c_black);
    draw_rectangle(0, 0, _gui_w, _gui_h, false);
    draw_set_alpha(1.0); 
    
    draw_set_color(c_black);
    draw_rectangle(_win_conf_x, _win_conf_y, _win_conf_x + _win_conf_w, _win_conf_y + _win_conf_h, false);
    draw_set_color(c_white);
    draw_rectangle(_win_conf_x, _win_conf_y, _win_conf_x + _win_conf_w, _win_conf_y + _win_conf_h, true);
    
    draw_set_font(fnt_press_start);
    draw_set_halign(fa_center);
    draw_text(_win_conf_x + _win_conf_w / 2, _win_conf_y + 25, "ARE YOU SURE?");
    
    var _btn_yes_x = _win_conf_x + 30;
    var _btn_yes_y = _win_conf_y + 70;
    var _btn_yes_w = 110;
    var _btn_yes_h = 35;
    
    var _hover_yes = (_mx >= _btn_yes_x && _mx < _btn_yes_x + _btn_yes_w && _my >= _btn_yes_y && _my < _btn_yes_y + _btn_yes_h);
    
    draw_set_color(_hover_yes ? c_green : c_white);
    draw_rectangle(_btn_yes_x, _btn_yes_y, _btn_yes_x + _btn_yes_w, _btn_yes_y + _btn_yes_h, true);
    draw_set_color(c_white);
    draw_text(_btn_yes_x + _btn_yes_w / 2, _btn_yes_y + 12, "YES");
    
    if (_hover_yes && mouse_check_button_pressed(mb_left)) {
        load_world(target_load_path); 
        show_load_confirm = false;
        menu_open = false; 
    }
    
    var _btn_cancel_x = _win_conf_x + _win_conf_w - 30 - _btn_yes_w;
    var _hover_cancel = (_mx >= _btn_cancel_x && _mx < _btn_cancel_x + _btn_yes_w && _my >= _btn_yes_y && _my < _btn_yes_y + _btn_yes_h);
    
    draw_set_color(_hover_cancel ? c_red : c_white);
    draw_rectangle(_btn_cancel_x, _btn_yes_y, _btn_cancel_x + _btn_yes_w, _btn_yes_y + _btn_yes_h, true);
    draw_set_color(c_white);
    draw_text(_btn_cancel_x + _btn_yes_w / 2, _btn_yes_y + 12, "CANCEL");
    
    if (_hover_cancel && mouse_check_button_pressed(mb_left)) {
        show_load_confirm = false;
        menu_open = false; 
    }
    
    draw_set_halign(fa_left);
}


// ==========================================
// 8. MAP CODE EXPORT WINDOW (ФИКС ВЫЛЕТА)
// ==========================================
if (show_io_save_window) {
    var _win_save_w = 450; // Сделаем окно чуть компактнее и аккуратнее
    var _win_save_h = 200;
    var _win_save_x = (_gui_w - _win_save_w) / 2;
    var _win_save_y = (_gui_h - _win_save_h) / 2;
    
    // Затемнение заднего фона
    draw_set_alpha(0.6); 
    draw_set_color(c_black); 
    draw_rectangle(0, 0, _gui_w, _gui_h, false); 
    draw_set_alpha(1.0);
    
    // Основное окно
    draw_set_color(c_black); 
    draw_rectangle(_win_save_x, _win_save_y, _win_save_x + _win_save_w, _win_save_y + _win_save_h, false);
    draw_set_color(c_white); 
    draw_rectangle(_win_save_x, _win_save_y, _win_save_x + _win_save_w, _win_save_y + _win_save_h, true);
    
    // Заголовок
    draw_set_font(fnt_press_start);
    draw_set_halign(fa_center); 
    draw_set_valign(fa_top); 
    draw_set_color(c_white);
    draw_text(_win_save_x + _win_save_w / 2, _win_save_y + 20, "MAP EXPORTED!");
    
    // Информационное сообщение (Вместо падения на расчете длинного кода)
    draw_set_font(-1); // Используем стандартный безопасный шрифт для описания
    draw_text_transformed(_win_save_x + _win_save_w / 2, _win_save_y + 60, "The world code has been successfully generated\nand AUTOMATICALLY copied to your clipboard!", 1, 1, 0);
    draw_text_transformed(_win_save_x + _win_save_w / 2, _win_save_y + 95, "You can paste it directly into another game session.", 0.85, 0.85, 0);
    
    // КНОПКИ УПРАВЛЕНИЯ
    var _btn_w = 160; 
    var _btn_h = 35;
    var _btn_y = _win_save_y + _win_save_h - 55;
    
    // КНОПКА 1: COPY AGAIN (На случай, если буфер перезаписался)
    var _btn_copy_x = _win_save_x + (_win_save_w / 2) - _btn_w - 15;
    var _hover_copy = (_mx >= _btn_copy_x && _mx < _btn_copy_x + _btn_w && _my >= _btn_y && _my < _btn_y + _btn_h);
    
    draw_set_color(_hover_copy ? c_green : c_white); 
    draw_rectangle(_btn_copy_x, _btn_y, _btn_copy_x + _btn_w, _btn_y + _btn_h, true);
    
    draw_set_color(c_white); 
    draw_set_halign(fa_center); 
    draw_set_font(fnt_press_start);
    draw_text_transformed(_btn_copy_x + _btn_w / 2, _btn_y + 12, "COPY AGAIN", 0.75, 0.75, 0);
    
    if (_hover_copy && mouse_check_button_pressed(mb_left)) {
        if (map_text_code != "" && map_text_code != undefined) {
            clipboard_set_text(map_text_code);
        }
    }
    
    // КНОПКА 2: CLOSE
    var _btn_close_x = _win_save_x + (_win_save_w / 2) + 15;
    var _hover_close = (_mx >= _btn_close_x && _mx < _btn_close_x + _btn_w && _my >= _btn_y && _my < _btn_y + _btn_h);
    
    draw_set_color(_hover_close ? c_red : c_white); 
    draw_rectangle(_btn_close_x, _btn_y, _btn_close_x + _btn_w, _btn_y + _btn_h, true);
    
    draw_set_color(c_white); 
    draw_set_halign(fa_center);
    draw_text_transformed(_btn_close_x + _btn_w / 2, _btn_y + 12, "CLOSE", 0.75, 0.75, 0);
    
    if (_hover_close && mouse_check_button_pressed(mb_left)) {
        show_io_save_window = false;
        menu_open = false;
    }
    
    draw_set_halign(fa_left); 
    draw_set_valign(fa_top);
}


draw_set_font(-1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);