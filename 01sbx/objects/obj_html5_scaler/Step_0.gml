
if (browser_width != current_width || browser_height != current_height) 
{
    current_width = browser_width;
    current_height = browser_height;

    var aspect = base_width / base_height;
    
    var canvas_w = current_width;
    var canvas_h = current_height;

    if (current_width / aspect > current_height) {
        canvas_w = current_height * aspect;
    } else {
        canvas_h = current_width / aspect;
    }

    window_set_size(canvas_w, canvas_h);
    
    window_set_position((current_width - canvas_w) / 2, (current_height - canvas_h) / 2);
}
