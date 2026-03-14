uniform lowp float u_device_pixel_ratio;
uniform mediump float u_ratio;

in vec2 v_width2;
in vec2 v_normal;
in float v_gamma_scale;
in highp float v_linesofar;
#ifdef GLOBE
in float v_depth;
#endif

#pragma mapbox: define highp vec4 color
#pragma mapbox: define lowp float blur
#pragma mapbox: define lowp float opacity
#pragma mapbox: define highp float hash_interval
#pragma mapbox: define highp float hash_length
#pragma mapbox: define highp float hash_width

void main() {
    #pragma mapbox: initialize highp vec4 color
    #pragma mapbox: initialize lowp float blur
    #pragma mapbox: initialize lowp float opacity
    #pragma mapbox: initialize highp float hash_interval
    #pragma mapbox: initialize highp float hash_length
    #pragma mapbox: initialize highp float hash_width

    // Distance from line center in pixels
    float dist = length(v_normal) * v_width2.s;

    // Antialiasing
    float blur2 = (blur + 1.0 / u_device_pixel_ratio) * v_gamma_scale;
    float alpha = clamp(min(dist - (v_width2.t - blur2), v_width2.s - dist) / blur2, 0.0, 1.0);

    // Convert v_linesofar from tile units to pixels
    float linesofar_px = v_linesofar / u_ratio;

    // Periodic hash ticks: distance along line modulo interval
    float along = mod(linesofar_px, hash_interval);
    float half_tick = hash_width * 0.5;
    // Antialiased tick in the along-line direction
    float tick = 1.0 - smoothstep(half_tick - 0.7, half_tick + 0.7,
                                   abs(along - hash_interval * 0.5));
    // Also check: tick at interval boundary (handle wrap)
    float tick2 = 1.0 - smoothstep(half_tick - 0.7, half_tick + 0.7,
                                    min(along, hash_interval - along));
    tick = max(tick, tick2);

    // Perpendicular extent: hash_length controls how far the tick extends
    // v_normal.y ranges from -1 to 1 across the line width
    // Scale to check against hash_length relative to line width
    float perp_dist = abs(v_normal.y) * v_width2.s;
    float half_hash = hash_length * 0.5;
    float perp = 1.0 - smoothstep(half_hash - 0.7, half_hash + 0.7, perp_dist);

    // Combine: visible only where both tick and perpendicular extent overlap
    float hash = tick * perp;

    fragColor = color * (alpha * opacity * hash);

    #ifdef GLOBE
    if (v_depth > 1.0) { discard; }
    #endif

#ifdef OVERDRAW_INSPECTOR
    fragColor = vec4(1.0);
#endif
}
