# MapLibre GL JS Shaders

This repository contains the GLSL shaders

## Pragmas

Some variables change type depending on their context:

 - if the variable is the same for all features, we declare it as a `uniform`
 - if the variable is different for each feature, we declare it as an `attribute` (in the vertex shader) and an accompanying `varying` (in both the vertex and fragment shaders).
 - if the variable is different for each feature and a function of zoom, we declare several `attributes` and `uniforms` then calculate the value using interpolation

We abstract over this functionality using pragmas.

```glsl
#pragma mapbox: define highp vec4 color

main() {
    #pragma mapbox: initialize highp vec4 color
    ...
    fragColor = color;
}
```

This program defines a variable within `main` called `color`, initialize the value of `color`, then sets `fragColor` to the value of `color`.

Pragmas take the following form.

```glsl
#pragma mapbox: (define|initialize) (lowp|mediump|highp) (float|vec2|vec3|vec4) {name}
```

When using pragmas, the following requirements apply.

 - all pragma-defined variables must have both `define` and `initialize` pragmas
 - `define` pragmas must be in file scope
 - `initialize` pragmas must be in function scope
 - all pragma-defined variables defined and initialized in the fragment shader must also be defined and initialized in the vertex shader because `attribute`s are not accessible from the fragment shader

## Procedural Pattern Shaders

In addition to image-based `fillPattern` shaders, the following procedural pattern shaders are available:

### `fillHatch`
Renders world-fixed angled line hatching over fill polygons. Pragma-bound properties:
- `hatch_color` (vec4) — color of the hatch lines
- `hatch_angle` (float) — angle of the hatching in degrees
- `hatch_spacing` (float) — distance between hatch lines in pixels
- `hatch_width` (float) — width of each hatch line in pixels

### `fillDot`
Renders world-fixed dot grid patterns over fill polygons. Pragma-bound properties:
- `dot_color` (vec4) — color of the dots
- `dot_radius` (float) — radius of each dot in pixels
- `dot_spacing_x` (float) — horizontal spacing between dots in pixels
- `dot_spacing_y` (float) — vertical spacing between dots in pixels
- `dot_displacement_x` (float) — horizontal offset for alternating rows (brick-like layout)

### `lineHash`
Renders periodic perpendicular tick marks along line features. Pragma-bound properties:
- `hash_interval` (float) — distance between tick marks in pixels
- `hash_length` (float) — perpendicular extent of each tick in pixels
- `hash_width` (float) — width of each tick along the line in pixels

All procedural fill shaders receive world-space coordinates via uniforms (`u_pattern_matrix`, `u_pattern_offset`, `u_screen_center`) so that patterns remain fixed to geographic positions during map rotation and panning.

### Custom fill shaders
`Painter.useCustomFillProgram(glsl)` accepts a GLSL fragment snippet defining a `vec4 customFill(vec2 pos, vec4 color, float opacity)` function. The `pos` parameter provides world-fixed pixel coordinates. The program is compiled, cached, and rendered using the same uniform set as the procedural fill shaders.

## Prelude

The `_prelude.fragment.glsl` and `_prelude.vertex.glsl` files are automatically included in all shaders by the compiler.
