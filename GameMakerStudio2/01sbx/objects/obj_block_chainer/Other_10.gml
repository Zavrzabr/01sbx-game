if (status != "ready") {
    if (status == "active") next_status = "cooldown";
    if (status == "cooldown") next_status = "ready";
    exit;
}

var _has_input = false;

var _check_signal_at = function(_px, _py) {
    var _neighbor = instance_position(_px, _py, all);
    if (_neighbor != noone && variable_instance_exists(_neighbor, "status")) {
        if (_neighbor.object_index != obj_block_chainer && _neighbor.status == "active") return true;
    }
    return false;
}

if (d && _check_signal_at(x + 11, y + 22 + 11)) _has_input = true;
if (r && _check_signal_at(x + 22 + 11, y + 11)) _has_input = true;
if (u && _check_signal_at(x + 11, y - 22 + 11)) _has_input = true;
if (l && _check_signal_at(x - 22 + 11, y + 11)) _has_input = true;

var _is_blocked = false;
var _check_blocker_at = function(_px, _py, _required_glue_flag) {
    var _neighbor = instance_position(_px, _py, obj_block_blocker);
    if (_neighbor != noone && _neighbor.status == "active" && !_required_glue_flag) return true;
    return false;
}
var _active_blockers_count = 0
_active_blockers_count += _check_blocker_at(x - 22 + 11, y + 11, l);
_active_blockers_count += _check_blocker_at(x + 22 + 11, y + 11, r);
_active_blockers_count += _check_blocker_at(x + 11, y - 22 + 11, u); 
_active_blockers_count += _check_blocker_at(x + 11, y + 22 + 11, d);
var _is_blocked = (_active_blockers_count % 2 != 0);

if (_has_input && !_is_blocked) {
    var _queue = ds_queue_create();
    var _visited = ds_list_create();
    
    ds_queue_enqueue(_queue, id);
    ds_list_add(_visited, id);
    
    while (!ds_queue_empty(_queue)) {
        var _current = ds_queue_dequeue(_queue);
        
        _current.next_status = "active"; 
        
        if (_current.l) {
            var _n = instance_position(_current.x - 22 + 11, _current.y + 11, obj_block_chainer);
            if (_n != noone && ds_list_find_index(_visited, _n) == -1 && _n.status == "ready") {
                ds_list_add(_visited, _n); ds_queue_enqueue(_queue, _n);
            }
        }
        if (_current.r) {
            var _n = instance_position(_current.x + 22 + 11, _current.y + 11, obj_block_chainer);
            if (_n != noone && ds_list_find_index(_visited, _n) == -1 && _n.status == "ready") {
                ds_list_add(_visited, _n); ds_queue_enqueue(_queue, _n);
            }
        }
        if (_current.u) {
            var _n = instance_position(_current.x + 11, _current.y - 22 + 11, obj_block_chainer);
            if (_n != noone && ds_list_find_index(_visited, _n) == -1 && _n.status == "ready") {
                ds_list_add(_visited, _n); ds_queue_enqueue(_queue, _n);
            }
        }
        if (_current.d) {
            var _n = instance_position(_current.x + 11, _current.y + 22 + 11, obj_block_chainer);
            if (_n != noone && ds_list_find_index(_visited, _n) == -1 && _n.status == "ready") {
                ds_list_add(_visited, _n); ds_queue_enqueue(_queue, _n);
            }
        }
    }
    
    ds_queue_destroy(_queue);
    ds_list_destroy(_visited);
}