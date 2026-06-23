if (status != "ready") {
    if (status == "active") next_status = "cooldown";
    if (status == "cooldown") next_status = "ready";
    exit;
}

var _my_freq = get_freq_string();
var _signal_in_air = variable_struct_get(global.teleporter_frequencies, _my_freq);

if (_signal_in_air == true) {
    next_status = "active";
} else {
    next_status = "ready";
}