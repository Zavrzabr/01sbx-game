var _f = 0;
if (d) _f += 1;
if (r) _f += 2;
if (u) _f += 4;
if (l) _f += 8;
 
var _draw_frame = _f;
var _draw_alpha = 1.0;

switch (status) {
    case "ready":    _draw_frame = _f;      _draw_alpha = 1.0; break;
    case "active":   _draw_frame = _f + 16; _draw_alpha = 1.0; break;
    case "cooldown": _draw_frame = _f + 16; _draw_alpha = 0.5; break;
}

draw_set_alpha(_draw_alpha);
draw_sprite(sprite_index, _draw_frame, x, y);
draw_set_alpha(1.0);