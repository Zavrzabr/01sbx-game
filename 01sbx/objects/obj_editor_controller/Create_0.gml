
gpu_set_texfilter(false);
my_border_sprite = spr_world_border; 

// --- ГРАНИЦЫ МИРА (Координаты рамки) ---
sprite_grid_size = 22;
cell_size = sprite_grid_size;

world_x1 = 110; 
world_y1 = 110;
world_x2 = 1320; 
world_y2 = 902;  
// Сохранение мира

show_io_save_window = false;
show_io_load_window = false;
map_text_code = "";
show_pc_load_choice = false;
input_msg_id = -1;
input_text = ""; // Сюда будет записываться вводимый JSON/текст
is_typing = false; // Активно ли поле ввода прямо сейчас

// Минимальный размер мира в блоках (минимум 5 на 5 ячеек)
min_blocks_w = 5;
min_blocks_h = 5;
min_world_width = min_blocks_w * cell_size;  
min_world_height = min_blocks_h * cell_size; 

// --- КАМЕРА, ДВИЖЕНИЕ И ЗУМ ---
cam_x = 0;
cam_y = 0;
cam_zoom = 1.0;
max_zoom = 3.0;
min_zoom = 0.3;

// --- ТРИГГЕРЫ ДЛЯ ХВАТАНИЯ МЫШКОЙ ---
drag_mouse_x = 0;
drag_mouse_y = 0;
// Для механики клея
glue_start_x = 0;
glue_start_y = 0;
is_gluing = false;


editing_frequency = false;
button_pressed_timer = 0

sim_timer = 0;
sim_speed = 5; // Скорость тика (каждые 5 кадров игры)

grab_edge = "none"; 
grab_margin = 16;  

// --- ИНИЦИАЛИЗАЦИЯ МАССИВА ДАННЫХ СЕТКИ ---
grid_width_cells = (world_x2 - world_x1) / cell_size;
grid_height_cells = (world_y2 - world_y1) / cell_size;

sim_paused = false;
sim_do_single_step = false;

world_grid = array_create(grid_width_cells);
for (var i = 0; i < grid_width_cells; i++) {
    world_grid[i] = array_create(grid_height_cells);
    for (var j = 0; j < grid_height_cells; j++) {
        world_grid[i][j] = { type: "empty", state: "ready", signal: 0, l: false, r: false, u: false, d: false, code: "00000000" };
    }
}

// Функция для динамического изменения размера сетки при растягивании рамки
update_grid_size = function() {
    var _new_w = (world_x2 - world_x1) / cell_size;
    var _new_h = (world_y2 - world_y1) / cell_size;
    
    if (_new_w != grid_width_cells || _new_h != grid_height_cells) {
        var _new_grid = array_create(_new_w);
        for (var i = 0; i < _new_w; i++) {
            _new_grid[i] = array_create(_new_h);
            for (var j = 0; j < _new_h; j++) {
                if (i < grid_width_cells && j < grid_height_cells) {
                    _new_grid[i][j] = world_grid[i][j];
                } else {
                    _new_grid[i][j] = { type: "empty", state: "ready", signal: 0, l: false, r: false, u: false, d: false, code: "00000000" };
                }
            }
        }
        world_grid = _new_grid;
        grid_width_cells = _new_w;
        grid_height_cells = _new_h;
    }
    
    // Проверяем абсолютно ВСЕ сигнальщики в комнате
    with (obj_block) {
        if (x < other.world_x1 || x >= other.world_x2 || y < other.world_y1 || y >= other.world_y2) {
            instance_destroy();
        }
    }
    // Проверяем абсолютно ВСЕ осцилляторы в комнате
    with (obj_block_oscillator) {
        if (x < other.world_x1 || x >= other.world_x2 || y < other.world_y1 || y >= other.world_y2) {
            instance_destroy();
        }
    }
	with (obj_block_chainer) {
        if (x < other.world_x1 || x >= other.world_x2 || y < other.world_y1 || y >= other.world_y2) {
            instance_destroy();
        }
    }
	with (obj_block_blocker) {
        if (x < other.world_x1 || x >= other.world_x2 || y < other.world_y1 || y >= other.world_y2) {
            instance_destroy();
        }
    }
	with (obj_block_teleporter) {
        if (x < other.world_x1 || x >= other.world_x2 || y < other.world_y1 || y >= other.world_y2) {
            instance_destroy();
        }
    }
	with (obj_block_receiver) {
        if (x < other.world_x1 || x >= other.world_x2 || y < other.world_y1 || y >= other.world_y2) {
            instance_destroy();
        }
    }
}
// --- РЕЖИМЫ РАБОТЫ РЕДАКТОРА ---
// Варианты: "build" (режим строительства) или "camera" (режим камеры)
editor_mode = "build"; 

// Координаты кнопок на экране (в GUI)
// Рисуем в правом верхнем углу, например, отступив 50 пикселей от правого края окна
btn_build_x = window_get_width() - 100;
btn_build_y = 20;

btn_cam_x = window_get_width() - 50;
btn_cam_y = 20;

// --- НАСТРОЙКИ СТРОИТЕЛЬНОГО МЕНЮ (GUI) ---
menu_open = false;     
menu_width = 240;   
menu_current_x = window_get_width(); 
menu_target_x = window_get_width();  
menu_anim_speed = 0.15; 

btn_build_last_click = 0; 

selected_block_index = 0; 

global.teleporter_frequencies = json_parse("{}");
editing_block = noone;                 
double_click_timer = 0;

available_blocks = [
    {
        name: "Signaler",
        sprite: spr_block_signaler, 
        object: obj_block,
    },
    {
        name: "Oscillator",
        sprite: spr_block_oscillator,
        object: obj_block_oscillator,
    },
	{
		name: "Chainer",
		sprite: spr_block_chainer,
		object: obj_block_chainer,
	},
	{
		name: "Blocker",
		sprite: spr_block_blocker,
		object: obj_block_blocker,
	},
	{
		name: "Teleporter",
		sprite: spr_block_teleporter,
		object: obj_block_teleporter,
	},
	{
		name: "Receiver",
		sprite: spr_block_receiver,
		object: obj_block_receiver,
	},
];
// Настройки файловой системы
default_save_name = "My01World";
show_load_confirm = false; 

// 1. Задаем пути к границам мира, если они еще не сохранены в переменные
world_x1 = 0;
world_y1 = 0;
world_x2 = room_width; 
world_y2 = room_height;
target_load_path = "";
save_world = function(_filename) {
    var _save_list = array_create(0);
    
    with (all) {
        if (variable_instance_exists(id, "grid_x")) {
            var _block_data = json_parse("{}");
            _block_data[$ "object"] = object_get_name(object_index);
            _block_data[$ "gx"] = grid_x;
            _block_data[$ "gy"] = grid_y;
            _block_data[$ "x"] = x;
            _block_data[$ "y"] = y;
            _block_data[$ "l"] = l;
            _block_data[$ "r"] = r;
            _block_data[$ "u"] = u;
            _block_data[$ "d"] = d;
            
            if (variable_instance_exists(id, "frequency_array")) {
                _block_data[$ "freq"] = frequency_array;
            } else {
                _block_data[$ "freq"] = pointer_null;
            }
            array_push(_save_list, _block_data);
        }
    }
    
    var _json_string = json_stringify(_save_list);
    
    if (os_browser != browser_not_a_browser) {
        // HTML5: упаковываем в zlib + Base64 текст
        var _buffer = buffer_create(1024, buffer_grow, 1);
        buffer_write(_buffer, buffer_string, _json_string);
        var _compressed_buffer = buffer_compress(_buffer, 0, buffer_tell(_buffer));
        
        map_text_code = buffer_base64_encode(_compressed_buffer, 0, buffer_get_size(_compressed_buffer));
        
        show_io_save_window = true;
        menu_open = true;
        
        buffer_delete(_buffer);
        buffer_delete(_compressed_buffer);
    } else {
        // ПК: Сохраняем в сжатый файл .01mapPC
        if (_filename != "") {
            var _buffer = buffer_create(1024, buffer_grow, 1);
            buffer_write(_buffer, buffer_string, _json_string);
            var _compressed_buffer = buffer_compress(_buffer, 0, buffer_tell(_buffer));
            
            buffer_save(_compressed_buffer, _filename);
            
            buffer_delete(_buffer);
            buffer_delete(_compressed_buffer);
        }
    }
}

load_world_from_string = function(_string) {
    if (_string == "" || _string == undefined) return false;
    
    var _final_json = "";
    
    if (string_char_at(_string, 1) == "[") {
        _final_json = _string;
    } else {
        var _compressed_buffer = buffer_base64_decode(_string);
        if (_compressed_buffer != -1) {
            var _buffer = buffer_decompress(_compressed_buffer);
            if (_buffer != -1) {
                _final_json = buffer_read(_buffer, buffer_string);
                buffer_delete(_buffer);
            }
            buffer_delete(_compressed_buffer);
        }
    }
    
    if (_final_json == "") return false;
    
    with (all) {
        if (variable_instance_exists(id, "grid_x")) {
            instance_destroy();
        }
    }
    
    var _load_list = json_parse(_final_json);
    var _count = array_length(_load_list);
    
    for (var i = 0; i < _count; i++) {
        var _data = _load_list[i];
        var _obj_index = asset_get_index(_data[$ "object"]);
        
        if (_obj_index != -1) {
            var _inst = instance_create_layer(_data[$ "x"], _data[$ "y"], "Instances", _obj_index);
            _inst.grid_x = _data[$ "gx"];
            _inst.grid_y = _data[$ "gy"];
            _inst.l = _data[$ "l"];
            _inst.r = _data[$ "r"];
            _inst.u = _data[$ "u"];
            _inst.d = _data[$ "d"];
            
            if (_data[$ "freq"] != pointer_null) {
                _inst.frequency_array = _data[$ "freq"];
            }
        }
    }
    return true;
}

load_world = function(_filename) {
    if (os_browser != browser_not_a_browser) {
        return load_world_from_string(map_text_code);
    } else {
        if (_filename == "") {
            return load_world_from_string(map_text_code);
        }
        
        if (!file_exists(_filename)) return false;
        
        var _compressed_buffer = buffer_load(_filename);
        var _buffer = buffer_decompress(_compressed_buffer);
        
        if (_buffer != -1) {
            var _json_string = buffer_read(_buffer, buffer_string);
            
            with (all) { if (variable_instance_exists(id, "grid_x")) instance_destroy(); }
            
            var _load_list = json_parse(_json_string);
            var _count = array_length(_load_list);
            for (var i = 0; i < _count; i++) {
                var _data = _load_list[i];
                var _obj_index = asset_get_index(_data[$ "object"]);
                if (_obj_index != -1) {
                    var _inst = instance_create_layer(_data[$ "x"], _data[$ "y"], "Instances", _obj_index);
                    _inst.grid_x = _data[$ "gx"]; _inst.grid_y = _data[$ "gy"];
                    _inst.l = _data[$ "l"]; _inst.r = _data[$ "r"]; _inst.u = _data[$ "u"]; _inst.d = _data[$ "d"];
                    if (_data[$ "freq"] != pointer_null) _inst.frequency_array = _data[$ "freq"];
                }
            }
            buffer_delete(_buffer);
        }
        buffer_delete(_compressed_buffer);
        return true;
    }
    return false;
}