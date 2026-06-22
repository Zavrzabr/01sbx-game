// Проверяем существование спрайтов кнопок
if (sprite_exists(spr_building) && sprite_exists(spr_watching)) {
    
    // Рисуем подложку или рамку вокруг активного режима, чтобы было видно, что выбрано
    draw_set_color(c_white);
    if (editor_mode == "build") {
        draw_rectangle(btn_build_x - 2, btn_build_y - 2, btn_build_x + 18, btn_build_y + 18, true);
    } else {
        draw_rectangle(btn_cam_x - 2, btn_cam_y - 2, btn_cam_x + 18, btn_cam_y + 18, true);
    }
    
    // Рисуем сами кнопочки
    draw_sprite(spr_building, 0, btn_build_x, btn_build_y);
    draw_sprite(spr_watching, 0, btn_cam_x, btn_cam_y);
    
} else {
    // Если спрайтов пока нет — рисуем цветные квадраты с буквами для теста
    draw_set_color(editor_mode == "build" ? c_lime : c_gray);
    draw_rectangle(btn_build_x, btn_build_y, btn_build_x + 16, btn_build_y + 16, false);
    draw_set_color(c_black); draw_text(btn_build_x + 3, btn_build_y, "B");
    
    draw_set_color(editor_mode == "camera" ? c_lime : c_gray);
    draw_rectangle(btn_cam_x, btn_cam_y, btn_cam_x + 16, btn_cam_y + 16, false);
    draw_set_color(c_black); draw_text(btn_cam_x + 3, btn_cam_y, "C");
}

// Выводим текст текущего режима для подстраховки
draw_set_color(c_white);
draw_text(10, 10, "Режим: " + string(editor_mode));

// ==========================================
// ОТРИСОВКА ВЫЕЗЖАЮЩЕГО СТРОИТЕЛЬНОГО МЕНЮ
// ==========================================
// Рисуем панель, только если её текущая позиция хоть немного залезла на экран
if (menu_current_x < window_get_width()) {
    
    var _win_w = window_get_width();
    var _win_h = window_get_height();
    
    // 1. Рисуем черный прямоугольник панели
    draw_set_color(c_black);
    draw_rectangle(menu_current_x, 0, _win_w, _win_h, false);
    
    // 2. Рисуем нетолстую белую левую рамку (границу меню)
    draw_set_color(c_white);
    draw_line_width(menu_current_x, 0, menu_current_x, _win_h, 2);
    
    // 3. Заголовок меню
    draw_set_color(c_white);
    draw_text(menu_current_x + 15, 15, "BUILDERTOOLS:");
    
    // 4. Отрисовка кирпичиков блоков из массива
    var _start_item_y = 40;
    var _item_height = 50;
    
    for (var i = 0; i < array_length(available_blocks); i++) {
        var _block_info = available_blocks[i];
        
        var _ix1 = menu_current_x + 10;
        var _iy1 = _start_item_y + (i * _item_height);
        var _ix2 = _win_w - 10;
        var _iy2 = _iy1 + 40;
        
        // Если этот блок сейчас выбран — подсвечиваем его рамку белым, иначе — тускло-серой
        if (i == selected_block_index) {
            draw_set_color(c_white);
            // Толстая белая рамка вокруг кирпичика
            draw_rectangle(_ix1, _iy1, _ix2, _iy2, true);
        } else {
            draw_set_color(c_black);
            draw_rectangle(_ix1, _iy1, _ix2, _iy2, true);
        }
        
        // Рисуем иконку блока внутри кирпичика (смещение на центр иконки)
        if (sprite_exists(_block_info.sprite)) {
            // Рисуем 0-й кадр (неактивный) блока. Смещение на x+25, y+20 для центрирования
            draw_sprite_ext(_block_info.sprite, 0, _ix1, _iy1, 1, 1, 0, c_white, 1);
        }
        
        // Пишем подпись блока справа от его иконки
        draw_set_color(c_white);
        draw_text(_ix1 + 45, _iy1 + 12, _block_info.name);
    }
}
// Проверяем, выбрали ли мы какой-то блок для настройки частоты
if (editing_block != noone) {
    
    // 1. ВЫЧИСЛЯЕМ РАЗМЕРЫ И ЦЕНТР ЭКРАНА
    // Узнаем текущее разрешение GUI-слоя, чтобы окно всегда было ровно по центру
    var _gui_w = display_get_gui_width();
    var _gui_h = display_get_gui_height();
    
    // Задаем фиксированные размеры для нашего черного окошка
    var _win_w = 400;
    var _win_h = 160;
    
    // Находим верхнюю левую точку окна, отнимая половину размеров от центра экрана
    var _win_x = (_gui_w - _win_w) / 2;
    var _win_y = (_gui_h - _win_h) / 2;
    
    // Включаем флаг меню, чтобы игра знала: мы в интерфейсе, строить на фоне нельзя!
    menu_open = true; 
    
    
    // 2. РИСУЕМ КОРПУС ОКНА
    // Сначала рисуем сплошной черный задний фон
    draw_set_color(c_black);
    draw_rectangle(_win_x, _win_y, _win_x + _win_w, _win_y + _win_h, false);
    
    // Поверх него рисуем белую контурную рамку
    draw_set_color(c_white);
    draw_rectangle(_win_x, _win_y, _win_x + _win_w, _win_y + _win_h, true);
    
    // Выводим заголовок окна. Включаем твой шрифт fnt_press_start
    draw_set_font(fnt_press_start);
    draw_set_halign(fa_center);
    draw_text(_win_x + _win_w / 2, _win_y + 20, "SET FREQUENCY (8-BIT)");
    
    
    // 3. РИСУЕМ И ОБРАБАТЫВАЕМ 8 КНОПОК-ЦИФР
    // Высчитываем начальную точку по X для ряда кнопок, чтобы они стояли симметрично
    var _start_boxes_x = _win_x + 40;
    var _box_y = _win_y + 60; // Высота, на которой будет стоять весь ряд кнопок
    var _box_size = 32;       // Размер каждой квадратной рамочки (32х32 пикселя)
    var _spacing = 8;         // Расстояние (зазор) между соседними рамочками
    
    // Хватаем точные координаты курсора мыши на GUI-слое
    var _mx = device_mouse_x_to_gui(0);
    var _my = device_mouse_y_to_gui(0);
    
    // Запускаем цикл от 0 до 7. Он по очереди обработает каждую из 8 цифр частоты
    for (var i = 0; i < 8; i++) {
        
        // Главная математика: сдвигаем координату X для каждой следующей кнопки вправо.
        // Для первой кнопки (i=0) сдвиг равен 0. Для второй (i=1) сдвиг равен 40 пикселей, и так далее.
        var _bx = _start_boxes_x + i * (_box_size + _spacing);
        
        // Проверяем геометрическое условие: находится ли сейчас мышь внутри этой конкретной рамочки?
        var _hover = (_mx >= _bx && _mx < _bx + _box_size && _my >= _box_y && _my < _box_y + _box_size);
        
        // ЕСЛИ МЫШЬ НАВЕДЕНА И ИГРОК КЛИКНУЛ ЛКМ:
        if (_hover && mouse_check_button_pressed(mb_left)) {
            // Переключаем значение в массиве редактируемого блока. 
            // Мы берем ячейку под номером 'i'. Если там был 0 — записываем 1. Если была 1 — записываем 0.
            if (editing_block.frequency_array[i] == 0) {
                editing_block.frequency_array[i] = 1;
            } else {
                editing_block.frequency_array[i] = 0;
            }
        }
        
        // ПОДСВЕТКА: Если мышь наведена на рамочку, красим её контур в желтый, иначе — в белый.
        if (_hover) {
            draw_set_color(c_yellow);
        } else {
            draw_set_color(c_white);
        }
        // Рисуем рамку кнопки
        draw_rectangle(_bx, _box_y, _bx + _box_size, _box_y + _box_size, true);
        
        // НАСТРОЙКА ТЕКСТА ДЛЯ ЦИФРЫ: центрируем текст по осям X и Y внутри квадрата
        draw_set_color(c_white);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        
        // Вытаскиваем из массива актуальное значение (0 или 1) и рисуем его строго по центру рамочки
        var _digit_string = string(editing_block.frequency_array[i]);
        draw_text(_bx + _box_size / 2, _box_y + _box_size / 2, _digit_string);
    }
    
    
    // 4. РИСУЕМ КНОПКУ ЗА КРЫТИЯ ОКНА "CLOSE"
    // Сбрасываем вертикальное выравнивание обратно на стандартное верхнее
    draw_set_valign(fa_top);
    
    var _btn_w = 100;
    var _btn_h = 30;
    var _btn_x = _win_x + (_win_w - _btn_w) / 2; // Центрируем кнопку "CLOSE" по ширине окна
    var _btn_y = _win_y + _win_h - 40;            // Смещаем её в самый низ окошка
    
    // Проверяем, наведена ли мышь на кнопку "CLOSE"
    var _btn_hover = (_mx >= _btn_x && _mx < _btn_x + _btn_w && _my >= _btn_y && _my < _btn_y + _btn_h);
    
    // Если наведена — подсвечиваем красным цветом опасности, иначе — белым
    if (_btn_hover) {
        draw_set_color(c_red);
    } else {
        draw_set_color(c_white);
    }
    // Рисуем рамку кнопки закрытия
    draw_rectangle(_btn_x, _btn_y, _btn_x + _btn_w, _btn_y + _btn_h, true);
    
    // Пишем сам текст CLOSE
    draw_set_color(c_white);
    draw_set_halign(fa_center);
    draw_text(_btn_x + _btn_w / 2, _btn_y + 8, "CLOSE");
    
    // Если игрок кликнул по кнопке CLOSE — закрываем меню и обнуляем ссылку на редактируемый блок
    if (_btn_hover && mouse_check_button_pressed(mb_left)) {
        editing_block = noone;
    }
    
    // В самом конце обязательно возвращаем стандартные настройки рисования GameMaker, 
    // чтобы не сломать отображение остального интерфейса игры
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}
if (show_load_confirm) {
    var _gui_w = display_get_gui_width();
    var _gui_h = display_get_gui_height();
    
    // Размеры маленького окна предупреждения
    var _win_w = 320;
    var _win_h = 140;
    var _win_x = (_gui_w - _win_w) / 2;
    var _win_y = (_gui_h - _win_h) / 2;
    
    // 1. Рисуем темный полупрозрачный задний фон на весь экран, чтобы затенить плату
    draw_set_alpha(0.5);
    draw_set_color(c_black);
    draw_rectangle(0, 0, _gui_w, _gui_h, false);
    draw_set_alpha(1.0); // Сброс альфы
    
    // 2. Рисуем коробку окна (черный прямоугольник с белым контуром)
    draw_set_color(c_black);
    draw_rectangle(_win_x, _win_y, _win_x + _win_w, _win_y + _win_h, false);
    draw_set_color(c_white);
    draw_rectangle(_win_x, _win_y, _win_x + _win_w, _win_y + _win_h, true);
    
    // Текст вопроса шрифтом fnt_press_start
    draw_set_font(fnt_press_start);
    draw_set_halign(fa_center);
    draw_text(_win_x + _win_w / 2, _win_y + 25, "ARE YOU SURE?");
    
    // Координаты мыши на GUI слое
    var _mx = device_mouse_x_to_gui(0);
    var _my = device_mouse_y_to_gui(0);
    
    // 3. КНОПКА "YES" (Слева)
    var _btn_yes_x = _win_x + 30;
    var _btn_y = _win_y + 70;
    var _btn_w = 110;
    var _btn_h = 35;
    
    var _hover_yes = (_mx >= _btn_yes_x && _mx < _btn_yes_x + _btn_w && _my >= _btn_y && _my < _btn_y + _btn_h);
    
    draw_set_color(_hover_yes ? c_green : c_white);
    draw_rectangle(_btn_yes_x, _btn_y, _btn_yes_x + _btn_w, _btn_y + _btn_h, true);
    draw_set_color(c_white);
    draw_text(_btn_yes_x + _btn_w / 2, _btn_y + 12, "YES");
    
    // Если кликнули на YES — загружаем мир и закрываем окно
    if (_hover_yes && mouse_check_button_pressed(mb_left)) {
        load_world(target_load_path); // Используем точный путь!
        show_load_confirm = false;
        menu_open = false; 
    }
    
    // 4. КНОПКА "CANCEL" (Справа)
    var _btn_cancel_x = _win_x + _win_w - 30 - _btn_w;
    
    var _hover_cancel = (_mx >= _btn_cancel_x && _mx < _btn_cancel_x + _btn_w && _my >= _btn_y && _my < _btn_y + _btn_h);
    
    draw_set_color(_hover_cancel ? c_red : c_white);
    draw_rectangle(_btn_cancel_x, _btn_y, _btn_cancel_x + _btn_w, _btn_y + _btn_h, true);
    draw_set_color(c_white);
    draw_text(_btn_cancel_x + _btn_w / 2, _btn_y + 12, "CANCEL");
    
    // Если кликнули на CANCEL — просто закрываем окно
    if (_hover_cancel && mouse_check_button_pressed(mb_left)) {
        show_load_confirm = false;
        menu_open = false; // Возвращаем управление в игру
    }
    
    // Возвращаем стандартные выравнивания текста
    draw_set_halign(fa_left);
}