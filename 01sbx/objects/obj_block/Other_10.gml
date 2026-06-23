
if (status != "ready") {
    if (status == "active") next_status = "cooldown";
    if (status == "cooldown") next_status = "ready";
    exit;
}

var _has_input = false;

var _check_signal_at = function(_px, _py) {
    var _neighbor = instance_position(_px, _py, all);
    
    if (_neighbor != noone && variable_instance_exists(_neighbor, "status")) {

        if (_neighbor.status == "active") return true;
    }
    return false;
}

if (d && _check_signal_at(x + 11, y + 22 + 11)) _has_input = true;
if (r && _check_signal_at(x + 22 + 11, y + 11)) _has_input = true;
if (u && _check_signal_at(x + 11, y - 22 + 11)) _has_input = true; 
if (l && _check_signal_at(x - 22 + 11, y + 11)) _has_input = true; 

var _active_blockers_count = 0;
var _check_blocker_at = function(_px, _py, _required_glue_flag) {
    var _neighbor = instance_position(_px, _py, obj_block_blocker);
    if (_neighbor != noone && _neighbor.status == "active" && !_required_glue_flag) return 1;
    return 0;
}
_active_blockers_count += _check_blocker_at(x - 22 + 11, y + 11, l);
_active_blockers_count += _check_blocker_at(x + 22 + 11, y + 11, r);
_active_blockers_count += _check_blocker_at(x + 11, y - 22 + 11, u);
_active_blockers_count += _check_blocker_at(x + 11, y + 22 + 11, d);

var _is_blocked = (_active_blockers_count % 2 != 0);

if (_has_input && !_is_blocked) {
    next_status = "active";
} else {
    next_status = "ready";
}