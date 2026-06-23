grid_x = 0;
grid_y = 0;

l = false;
r = false;
u = false;
d = false;

status = "ready";
next_status = "ready"; 

signal = 0; 

connect_with_neighbor = function(_neighbor) {
    if (_neighbor == noone || _neighbor == id) return;
    
    if (_neighbor.grid_x == grid_x - 1 && _neighbor.grid_y == grid_y) { l = true; _neighbor.r = true; } 
    if (_neighbor.grid_x == grid_x + 1 && _neighbor.grid_y == grid_y) { r = true; _neighbor.l = true; } 
    if (_neighbor.grid_x == grid_x && _neighbor.grid_y == grid_y - 1) { u = true; _neighbor.d = true; } 
    if (_neighbor.grid_x == grid_x && _neighbor.grid_y == grid_y + 1) { d = true; _neighbor.u = true; } 
}

disconnect_dead_neighbors = function() {
    var _my_gx = grid_x;
    var _my_gy = grid_y;
    
    if (l) {
        var _exists = false;
        with (all) { if (variable_instance_exists(id, "grid_x") && grid_x == _my_gx - 1 && grid_y == _my_gy) _exists = true; }
        if (!_exists) l = false;
    }
    if (u) {
        var _exists = false;
        with (all) { if (variable_instance_exists(id, "grid_x") && grid_x == _my_gx && grid_y == _my_gy - 1) _exists = true; }
        if (!_exists) u = false;
    }
    if (r) {
        var _exists = false;
        with (all) { if (variable_instance_exists(id, "grid_x") && grid_x == _my_gx + 1 && grid_y == _my_gy) _exists = true; }
        if (!_exists) r = false;
    }
    if (d) {
        var _exists = false;
        with (all) { if (variable_instance_exists(id, "grid_x") && grid_x == _my_gx && grid_y == _my_gy + 1) _exists = true; }
        if (!_exists) d = false;
    }
}