status = "ready";
next_status = "ready";
grid_x = 0;
grid_y = 0;
l = false; r = false; u = false; d = false;
signal = 0;

connect_with_neighbor = function(_neighbor_id) {
    if (_neighbor_id == noone || _neighbor_id == id) exit;
    
    var _dx = _neighbor_id.grid_x - grid_x;
    var _dy = _neighbor_id.grid_y - grid_y;
    
    if (_dx == 0 && _dy == 1)  { d = true; _neighbor_id.u = true; }
    if (_dx == 1 && _dy == 0)  { r = true; _neighbor_id.l = true; }
    if (_dx == 0 && _dy == -1) { u = true; _neighbor_id.d = true; }
    if (_dx == -1 && _dy == 0) { l = true; _neighbor_id.r = true; }
}
