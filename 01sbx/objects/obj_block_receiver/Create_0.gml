grid_x = 0;
grid_y = 0;

l = false;
r = false;
u = false;
d = false;

status = "ready";
next_status = "ready";
signal = 0;

frequency_array = [0, 0, 0, 0, 0, 0, 0, 0];

get_freq_string = function() {
    var _str = "";
    for (var i = 0; i < 8; i++) {
        _str += string(frequency_array[i]);
    }
    return _str;
}

connect_with_neighbor = function(_neighbor) {
    if (_neighbor == noone || _neighbor == id) return;
    if (_neighbor.grid_x == grid_x - 1 && _neighbor.grid_y == grid_y) { l = true; _neighbor.r = true; } 
    if (_neighbor.grid_x == grid_x + 1 && _neighbor.grid_y == grid_y) { r = true; _neighbor.l = true; } 
    if (_neighbor.grid_x == grid_x && _neighbor.grid_y == grid_y - 1) { u = true; _neighbor.d = true; } 
    if (_neighbor.grid_x == grid_x && _neighbor.grid_y == grid_y + 1) { d = true; _neighbor.u = true; } 
}