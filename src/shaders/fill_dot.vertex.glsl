uniform vec2 u_fill_translate;

in vec2 a_pos;

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

    gl_Position = projectTile(a_pos + u_fill_translate, a_pos);
}
