var _step = sprite_grid_size; // 22 пикселя

if (!sprite_exists(my_border_sprite)) {
    draw_text(10, 10, "Ошибка: Назначьте правильный спрайт в Create Event!");
    exit;
}

// ==========================================
// 1. ПРОЦЕДУРНАЯ ЛИНИЯ СТЕН (Кадр 0)
// ==========================================

// Верхняя горизонтальная линия (Поворот 90°)
for (var _x = world_x1 + _step; _x < world_x2; _x += _step) {
    draw_sprite_ext(my_border_sprite, 0, _x, world_y1, 1, 1, 90, c_white, 1);
}

// Нижняя горизонтальная линия (Поворот 270°)
for (var _x = world_x1 + _step; _x < world_x2; _x += _step) {
    draw_sprite_ext(my_border_sprite, 0, _x, world_y2, 1, 1, 270, c_white, 1);
}

// Левая вертикальная линия (Угол 0, но зеркалим по X (xscale = -1). Никаких убогих сдвигов!)
for (var _y = world_y1 + _step; _y < world_y2; _y += _step) {
    draw_sprite_ext(my_border_sprite, 0, world_x1, _y, -1, 1, 0, c_white, 1);
}

// Правая вертикальная линия (Поворот 0°, дефолт)
for (var _y = world_y1 + _step; _y < world_y2; _y += _step) {
    draw_sprite_ext(my_border_sprite, 0, world_x2, _y, 1, 1, 0, c_white, 1);
}


// ==========================================
// 2. ОТРИСОВКА ЧЕТЫРЕХ УГЛОВ (Строго по координатам граней)
// ==========================================

// Верхний Левый угол (Кадр 1, угол 90)
draw_sprite_ext(my_border_sprite, 1, world_x1, world_y1, 1, 1, 90, c_white, 1);

// Верхний Правый угол (Кадр 2, угол 0)
draw_sprite_ext(my_border_sprite, 2, world_x2, world_y1, 1, 1, 0, c_white, 1);

// Нижний Левый угол (Кадр 2, угол 180)
draw_sprite_ext(my_border_sprite, 2, world_x1, world_y2, 1, 1, 180, c_white, 1);

// Нижний Правый угол (Кадр 1, угол 270)
draw_sprite_ext(my_border_sprite, 1, world_x2, world_y2, 1, 1, 270, c_white, 1);


// ==========================================
// 3. ВНУТРЕННЯЯ СЕТКА МИРА
// ==========================================
draw_set_color(c_white);
draw_set_alpha(0.1); 

for (var _grid_x = world_x1 + _step; _grid_x < world_x2; _grid_x += _step) {
    draw_line(_grid_x, world_y1, _grid_x, world_y2);
}
for (var _grid_y = world_y1 + _step; _grid_y < world_y2; _grid_y += _step) {
    draw_line(world_x1, _grid_y, world_x2, _grid_y);
}
draw_set_alpha(1.0);
// ==========================================
// 5. ОТРИСОВКА РАСТЯГИВАЮЩЕГОСЯ КЛЕЯ
// ==========================================
if (is_gluing) {
    if (sprite_exists(spr_glue)) {
        var _dist = point_distance(glue_start_x, glue_start_y, mouse_x, mouse_y);
        var _angle = point_direction(glue_start_x, glue_start_y, mouse_x, mouse_y);
        var _sw = sprite_get_width(spr_glue);
        
        // Рассчитываем xscale, чтобы спрайт растянулся ровно до мышки
        var _xscale = _dist / _sw;
        
        // Рисуем клей (всегда смотрит по направлению мыши, базовая текстура нарисована вправо)
        draw_sprite_ext(spr_glue, 0, glue_start_x, glue_start_y, _xscale, 1, _angle, c_white, 0.8);
    } else {
        // Запасной вариант, если спрайт не назначен
        draw_set_color(c_purple);
        draw_line_width(glue_start_x, glue_start_y, mouse_x, mouse_y, 4);
    }
}