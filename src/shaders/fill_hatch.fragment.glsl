uniform vec4 u_pattern_matrix;
uniform vec2 u_pattern_offset;
uniform vec2 u_screen_center;
uniform float u_zoom_fraction;

#pragma mapbox: define highp vec4 color
#pragma mapbox: define lowp float opacity
#pragma mapbox: define highp vec4 hatch_color
#pragma mapbox: define highp float hatch_angle
#pragma mapbox: define highp float hatch_spacing
#pragma mapbox: define highp float hatch_width

void main() {
    #pragma mapbox: initialize highp vec4 color
    #pragma mapbox: initialize lowp float opacity
    #pragma mapbox: initialize highp vec4 hatch_color
    #pragma mapbox: initialize highp float hatch_angle
    #pragma mapbox: initialize highp float hatch_spacing
    #pragma mapbox: initialize highp float hatch_width

    // Transform screen pixels to world pixels:
    // 1. Center on screen (gl_FragCoord is bottom-left origin)
    // 2. Rotate by inverse of map bearing
    // 3. Add world-pixel offset of map center
    // Flip Y: gl_FragCoord is bottom-up, world/Mercator is top-down
    vec2 screen = vec2(gl_FragCoord.x, u_screen_center.y * 2.0 - gl_FragCoord.y) - u_screen_center;
    mat2 rot = mat2(u_pattern_matrix.xy, u_pattern_matrix.zw);
    vec2 pos = rot * screen + u_pattern_offset;

    float angle_rad = radians(hatch_angle);
    float c = cos(angle_rad);
    float s = sin(angle_rad);

    float d = pos.x * s - pos.y * c;
    float half_w = hatch_width * 0.5;
    float dist = abs(mod(d + hatch_spacing * 0.5, hatch_spacing) - hatch_spacing * 0.5);

    // Widen smoothstep during zoom transitions to reduce shimmer
    float aa = 0.7 + u_zoom_fraction * 2.0;
    float hatch = 1.0 - smoothstep(half_w - aa, half_w + aa, dist);

    fragColor = mix(color * opacity, hatch_color, hatch);

    if (fragColor.a < 0.005) discard;

#ifdef OVERDRAW_INSPECTOR
    fragColor = vec4(1.0);
#endif
}
