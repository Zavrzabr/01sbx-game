grid_x = 0;
grid_y = 0;

l = false;
u = false;
r = false;
d = false;

status = "ready";
next_status = "ready"; 

signal = 0; 

connect_with_neighbor = function(_neighbor) {
    if (_neighbor == noone || _neighbor == id) return;
    
    if (_neighbor.grid_x == grid_x - 1 && _neighbor.grid_y == grid_y) { l = true; _neighbor.r = true; } // Сосед слева
    if (_neighbor.grid_x == grid_x + 1 && _neighbor.grid_y == grid_y) { r = true; _neighbor.l = true; } // Сосед справа
    if (_neighbor.grid_x == grid_x && _neighbor.grid_y == grid_y - 1) { u = true; _neighbor.d = true; } // Сосед сверху
    if (_neighbor.grid_x == grid_x && _neighbor.grid_y == grid_y + 1) { d = true; _neighbor.u = true; } // Сосед снизу
}
disconnect_dead_neighbors = function() {
    var _my_gx = grid_x;
    var _my_gy = grid_y;
    
    if (l) {
        var _exists = false;
        with (obj_block) { if (grid_x == _my_gx - 1 && grid_y == _my_gy) _exists = true; }
        if (!_exists) l = false;
    }
    
    if (u) {
        var _exists = false;
        with (obj_block) { if (grid_x == _my_gx && grid_y == _my_gy - 1) _exists = true; }
        if (!_exists) u = false;
    }
    
    if (r) {
        var _exists = false;
        with (obj_block) { if (grid_x == _my_gx + 1 && grid_y == _my_gy) _exists = true; }
        if (!_exists) r = false;
    }
    
    if (d) {
        var _exists = false;
        with (obj_block) { if (grid_x == _my_gx && grid_y == _my_gy + 1) _exists = true; }
        if (!_exists) d = false;
    }
}