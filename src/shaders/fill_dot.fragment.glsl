uniform vec4 u_pattern_matrix;
uniform vec2 u_pattern_offset;
uniform vec2 u_screen_center;
uniform float u_zoom_fraction;

#pragma mapbox: define highp vec4 color
#pragma mapbox: define lowp float opacity
#pragma mapbox: define highp vec4 dot_color
#pragma mapbox: define highp float dot_radius
#pragma mapbox: define highp float dot_spacing_x
#pragma mapbox: define highp float dot_spacing_y
#pragma mapbox: define highp float dot_displacement_x

void main() {
    #pragma mapbox: initialize highp vec4 color
    #pragma mapbox: initialize lowp float opacity
    #pragma mapbox: initialize highp vec4 dot_color
    #pragma mapbox: initialize highp float dot_radius
    #pragma mapbox: initialize highp float dot_spacing_x
    #pragma mapbox: initialize highp float dot_spacing_y
    #pragma mapbox: initialize highp float dot_displacement_x

    vec2 screen = vec2(gl_FragCoord.x, u_screen_center.y * 2.0 - gl_FragCoord.y) - u_screen_center;
    mat2 rot = mat2(u_pattern_matrix.xy, u_pattern_matrix.zw);
    vec2 pos = rot * screen + u_pattern_offset;

    float row = floor(pos.y / dot_spacing_y);
    if (mod(row, 2.0) > 0.5) {
        pos.x += dot_displacement_x;
    }

    vec2 cell = mod(pos, vec2(dot_spacing_x, dot_spacing_y));
    float dist = length(cell - vec2(dot_spacing_x * 0.5, dot_spacing_y * 0.5));

    float aa = 0.7 + u_zoom_fraction * 2.0;
    float dot = 1.0 - smoothstep(dot_radius - aa, dot_radius + aa, dist);

    fragColor = mix(color * opacity, dot_color, dot);

    if (fragColor.a < 0.005) discard;

#ifdef OVERDRAW_INSPECTOR
    fragColor = vec4(1.0);
#endif
}
