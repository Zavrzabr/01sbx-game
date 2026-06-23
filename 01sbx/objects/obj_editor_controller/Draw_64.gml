// ==========================================
// 1. ИНИЦИАЛИЗАЦИЯ И СБОР ДАННЫХ КУРСОРА
// ==========================================
var _gui_w = display_get_gui_width();
var _gui_h = display_get_gui_height();
var _mx = device_mouse_x_to_gui(0);
var _my = device_mouse_y_to_gui(0);

// По умолчанию сбрасываем выравнивание, чтобы базовые элементы не «поехали»
draw_set_font(-1); 
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_alpha(1.0);


// ==========================================
// 2. ОТРИСОВКА КНОПОК РЕЖИМОВ (BUILD / CAMERA)
// ==========================================
if (sprite_exists(spr_building) && sprite_exists(spr_watching)) {
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
// 3. ОТРИСОВКА ВЫЕЗЖАЮЩЕГО СТРОИТЕЛЬНОГО МЕНЮ
// ==========================================
if (menu_current_x < window_get_width()) {
    var _win_menu_w = window_get_width() + (0.5 * menu_current_x) - 555;
    var _win_menu_h = window_get_height();
    
    draw_set_color(c_black);
    draw_rectangle(menu_current_x, 0, _win_menu_w, _win_menu_h, false);
    
    draw_set_color(c_white);
    draw_line_width(menu_current_x, 0, menu_current_x, _win_menu_h, 2);
    
    draw_set_color(c_white);
    draw_text(menu_current_x + 15, 15, "BUILDERTOOLS:");
    
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
        
        if (sprite_exists(_block_info.sprite)) {
            draw_sprite_ext(_block_info.sprite, 0, _ix1, _iy1, 1, 1, 0, c_white, 1);
        }
        
        draw_set_color(c_white);
        draw_text(_ix1 + 45, _iy1 + 12, _block_info.name);
    }
}


// ==========================================
// 4. ОКНО НАСТРОЙКИ ЧАСТОТЫ БЛОКА
// ==========================================
if (editing_block != noone) {
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
// 5. ИНТЕРФЕЙС ВЫБОРА: ФАЙЛ ИЛИ ТЕКСТ (ПК)
// ==========================================
// Старый кусок с дублирующимся методом get_string_async полностью удален!
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
    draw_text((_x1 + _x2) / 2, _y1 + 20, "ТИП ЗАГРУЗКИ КАРТЫ:\n\n[ F1 ] - Файл (.01mapPC)\n[ F2 ] - Текст (JSON/Код)");
    
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
        is_typing = true; // Просто включаем наше окно ввода!
    }
    
    if (keyboard_check_pressed(vk_escape)) {
        show_pc_load_choice = false;
        menu_open = false;
    }
    draw_set_halign(fa_left);
}


// ==========================================
// 6. НАШЕ КАСТОМНОЕ ОКНО ВВОДА (ВМЕСТО УЖАСНЫХ МАК-ОКОН)
// ==========================================
if (is_typing) {
    var _box_w = 600;
    var _box_h = 160;
    var _x1 = (_gui_w - _box_w) / 2;
    var _y1 = (_gui_h - _box_h) / 2;
    var _x2 = _x1 + _box_w;
    var _y2 = _y1 + _box_h;
    
    draw_set_color(c_black);
    draw_rectangle(_x1, _y1, _x2, _y2, false);
    draw_set_color(c_white);
    draw_rectangle(_x1, _y1, _x2, _y2, true);
    
    draw_set_halign(fa_center);
    draw_text((_x1 + _x2) / 2, _y1 + 15, "ВСТАВЬТЕ КОД КАРТЫ И НАЖМИТЕ ENTER");
    
    var _tx1 = _x1 + 20;
    var _ty1 = _y1 + 55;
    var _tx2 = _x2 - 20;
    var _ty2 = _y2 - 50;
    draw_set_color(c_black);
    draw_rectangle(_tx1, _ty1, _tx2, _ty2, false);
    draw_set_color(c_white);
    draw_rectangle(_tx1, _ty1, _tx2, _ty2, true);
    
    draw_set_halign(fa_left);
    draw_set_valign(fa_middle);
    
    var _disp_text = input_text;
    if (string_width(_disp_text) > (_tx2 - _tx1 - 20)) {
        _disp_text = "..." + string_copy(_disp_text, string_length(_disp_text) - 40, 40);
    }
    
    var _cursor = (current_time mod 1000 < 500) ? "|" : "";
    draw_text(_tx1 + 10, (_ty1 + _ty2) / 2, _disp_text + _cursor);
    
    draw_set_halign(fa_center);
    draw_text((_x1 + _x2) / 2, _y2 - 25, "[Cmd+V/Ctrl+V] - Вставить | [ESC] - Отмена");
    
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}


// ==========================================
// 7. ОКНО ПОДТВЕРЖДЕНИЯ ЗАГРУЗКИ КАРТЫ
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
// 8. ОКНО СОХРАНЕНИЯ КОДА (EXPORT / HTML5)
// ==========================================
if (show_io_save_window) {
    var _win_save_w = 460;
    var _win_save_h = 180;
    var _win_save_x = (_gui_w - _win_save_w) / 2;
    var _win_save_y = (_gui_h - _win_save_h) / 2;
    
    draw_set_alpha(0.6); draw_set_color(c_black);
    draw_rectangle(0, 0, _gui_w, _gui_h, false);
    draw_set_alpha(1.0);
    
    draw_set_color(c_black); draw_rectangle(_win_save_x, _win_save_y, _win_save_x + _win_save_w, _win_save_y + _win_save_h, false);
    draw_set_color(c_white); draw_rectangle(_win_save_x, _win_save_y, _win_save_x + _win_save_w, _win_save_y + _win_save_h, true);
    
    draw_set_font(fnt_press_start);
    draw_set_halign(fa_center);
    draw_text(_win_save_x + _win_save_w / 2, _win_save_y + 20, "MAP COPIED TO CLIPBOARD!");
    
    var _box_x = _win_save_x + 20;
    var _box_y = _win_save_y + 50;
    var _box_w = _win_save_w - 40;
    var _box_h = 40;
    draw_set_color(c_darkgray); draw_rectangle(_box_x, _box_y, _box_x + _box_w, _box_y + _box_h, false);
    draw_set_color(c_white); draw_rectangle(_box_x, _box_y, _box_x + _box_w, _box_y + _box_h, true);
    
    draw_set_halign(fa_left);
    var _short_text = string_copy(map_text_code, 1, 35) + "...";
    draw_text(_box_x + 10, _box_y + 15, _short_text);
    
    draw_set_halign(fa_center);
    draw_set_color(c_gray);
    draw_text(_win_save_x + _win_save_w / 2, _win_save_y + 105, "Paste it to any text file");
    
    var _btn_x = _win_save_x + (_win_save_w - 120) / 2;
    var _btn_y = _win_save_y + 130;
    var _btn_w = 120;
    var _btn_h = 35;
    var _hover = (_mx >= _btn_x && _mx < _btn_x + _btn_w && _my >= _btn_y && _my < _btn_y + _btn_h);
    
    draw_set_color(_hover ? c_green : c_white);
    draw_rectangle(_btn_x, _btn_y, _btn_x + _btn_w, _btn_y + _btn_h, true);
    draw_set_color(c_white);
    draw_text(_btn_x + _btn_w / 2, _btn_y + 12, "CLOSE");
    
    if (_hover && mouse_check_button_pressed(mb_left)) {
        show_io_save_window = false;
        menu_open = false;
    }
    draw_set_halign(fa_left);
}

// Финальный сброс параметров рендеринга на стандартные
draw_set_font(-1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);