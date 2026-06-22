if (status != "ready") {
    if (status == "active") next_status = "cooldown";
    if (status == "cooldown") next_status = "ready";
    exit;
}

var _has_input = false;

var _check_glued_signal = function(_px, _py) {
    var _neighbor = instance_position(_px, _py, all);
    if (_neighbor != noone && variable_instance_exists(_neighbor, "status")) {
        if (_neighbor.status == "active") return true;
    }
    return false;
}

if (l && _check_glued_signal(x - 22 + 11, y + 11)) _has_input = true;
if (r && _check_glued_signal(x + 22 + 11, y + 11)) _has_input = true;
if (u && _check_glued_signal(x + 11, y - 22 + 11)) _has_input = true;
if (d && _check_glued_signal(x + 11, y + 22 + 11)) _has_input = true;

if (_has_input) {
    next_status = "active";
    var _my_freq = get_freq_string();
    variable_struct_set(global.teleporter_frequencies, _my_freq, true);
} else {
    next_status = "ready";
}