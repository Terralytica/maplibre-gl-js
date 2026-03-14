import {patternUniformValues} from './pattern';
import {MercatorCoordinate} from '../../geo/mercator_coordinate';
import {
    Uniform1i,
    Uniform1f,
    Uniform2f,
    Uniform3f,
    Uniform4f,
} from '../uniform_binding';
import {extend} from '../../util/util';

import type {Painter} from '../painter';
import type {UniformValues, UniformLocations} from '../uniform_binding';
import type {Context} from '../../gl/context';
import type {CrossfadeParameters} from '../../style/evaluation_parameters';
import type {Tile} from '../../tile/tile';

export type FillUniformsType = {
    'u_fill_translate': Uniform2f;
};

export type FillOutlineUniformsType = {
    'u_world': Uniform2f;
    'u_fill_translate': Uniform2f;
};

export type FillPatternUniformsType = {
    // pattern uniforms:
    'u_texsize': Uniform2f;
    'u_image': Uniform1i;
    'u_pixel_coord_upper': Uniform2f;
    'u_pixel_coord_lower': Uniform2f;
    'u_scale': Uniform3f;
    'u_fade': Uniform1f;
    'u_fill_translate': Uniform2f;
};

export type FillOutlinePatternUniformsType = {
    'u_world': Uniform2f;
    // pattern uniforms:
    'u_texsize': Uniform2f;
    'u_image': Uniform1i;
    'u_pixel_coord_upper': Uniform2f;
    'u_pixel_coord_lower': Uniform2f;
    'u_scale': Uniform3f;
    'u_fade': Uniform1f;
    'u_fill_translate': Uniform2f;
};

const fillUniforms = (context: Context, locations: UniformLocations): FillUniformsType => ({
    'u_fill_translate': new Uniform2f(context, locations.u_fill_translate)
});

const fillPatternUniforms = (context: Context, locations: UniformLocations): FillPatternUniformsType => ({
    'u_image': new Uniform1i(context, locations.u_image),
    'u_texsize': new Uniform2f(context, locations.u_texsize),
    'u_pixel_coord_upper': new Uniform2f(context, locations.u_pixel_coord_upper),
    'u_pixel_coord_lower': new Uniform2f(context, locations.u_pixel_coord_lower),
    'u_scale': new Uniform3f(context, locations.u_scale),
    'u_fade': new Uniform1f(context, locations.u_fade),
    'u_fill_translate': new Uniform2f(context, locations.u_fill_translate)
});

export type FillHatchUniformsType = {
    'u_fill_translate': Uniform2f;
    'u_pattern_offset': Uniform2f;
    'u_pattern_matrix': Uniform4f;
    'u_screen_center': Uniform2f;
    'u_zoom_fraction': Uniform1f;
    'u_pattern_scale': Uniform1f;
};

const fillHatchUniforms = (context: Context, locations: UniformLocations): FillHatchUniformsType => ({
    'u_fill_translate': new Uniform2f(context, locations.u_fill_translate),
    'u_pattern_offset': new Uniform2f(context, locations.u_pattern_offset),
    'u_pattern_matrix': new Uniform4f(context, locations.u_pattern_matrix),
    'u_screen_center': new Uniform2f(context, locations.u_screen_center),
    'u_zoom_fraction': new Uniform1f(context, locations.u_zoom_fraction),
    'u_pattern_scale': new Uniform1f(context, locations.u_pattern_scale),
});

const fillDotUniforms = fillHatchUniforms;

const fillOutlineUniforms = (context: Context, locations: UniformLocations): FillOutlineUniformsType => ({
    'u_world': new Uniform2f(context, locations.u_world),
    'u_fill_translate': new Uniform2f(context, locations.u_fill_translate)
});

const fillOutlinePatternUniforms = (context: Context, locations: UniformLocations): FillOutlinePatternUniformsType => ({
    'u_world': new Uniform2f(context, locations.u_world),
    'u_image': new Uniform1i(context, locations.u_image),
    'u_texsize': new Uniform2f(context, locations.u_texsize),
    'u_pixel_coord_upper': new Uniform2f(context, locations.u_pixel_coord_upper),
    'u_pixel_coord_lower': new Uniform2f(context, locations.u_pixel_coord_lower),
    'u_scale': new Uniform3f(context, locations.u_scale),
    'u_fade': new Uniform1f(context, locations.u_fade),
    'u_fill_translate': new Uniform2f(context, locations.u_fill_translate)
});

const fillPatternUniformValues = (
    painter: Painter,
    crossfade: CrossfadeParameters,
    tile: Tile,
    translate: [number, number]
): UniformValues<FillPatternUniformsType> => extend(
    patternUniformValues(crossfade, painter, tile),
    {
        'u_fill_translate': translate,
    }
);

const fillUniformValues = (translate: [number, number]): UniformValues<FillUniformsType> => ({
    'u_fill_translate': translate,
});

const fillHatchUniformValues = (
    painter: Painter,
    translate: [number, number]
): UniformValues<FillHatchUniformsType> => {
    const transform = painter.transform;
    const gl = painter.context.gl;

    // Screen-to-world rotation: undo the map's bearing rotation
    // gl_FragCoord.y is bottom-up, so negate the y component of rotation
    const angle = -transform.bearingInRadians;
    const cos_a = Math.cos(angle);
    const sin_a = Math.sin(angle);

    // World-pixel position of the map center
    const centerMerc = MercatorCoordinate.fromLngLat(transform.center);
    const worldCenterX = centerMerc.x * transform.worldSize;
    const worldCenterY = centerMerc.y * transform.worldSize;

    const zoomFraction = Math.abs(transform.zoom - Math.round(transform.zoom));

    // Zoom-relative scale: 1.0 at zoom 12, doubles per zoom level.
    // Custom shaders can use this to scale patterns with the map.
    const patternScale = Math.pow(2, transform.zoom - 12);

    return {
        'u_fill_translate': translate,
        'u_pattern_matrix': [cos_a, sin_a, -sin_a, cos_a],
        'u_screen_center': [gl.drawingBufferWidth / 2, gl.drawingBufferHeight / 2],
        'u_pattern_offset': [worldCenterX % 8192, worldCenterY % 8192],
        'u_zoom_fraction': zoomFraction,
        'u_pattern_scale': patternScale,
    };
};

const fillOutlineUniformValues = (drawingBufferSize: [number, number], translate: [number, number]): UniformValues<FillOutlineUniformsType> => ({
    'u_world': drawingBufferSize,
    'u_fill_translate': translate,
});

const fillOutlinePatternUniformValues = (
    painter: Painter,
    crossfade: CrossfadeParameters,
    tile: Tile,
    drawingBufferSize: [number, number],
    translate: [number, number]
): UniformValues<FillOutlinePatternUniformsType> => extend(
    fillPatternUniformValues(painter, crossfade, tile, translate),
    {
        'u_world': drawingBufferSize
    }
);

export {
    fillUniforms,
    fillDotUniforms,
    fillHatchUniforms,
    fillPatternUniforms,
    fillOutlineUniforms,
    fillOutlinePatternUniforms,
    fillUniformValues,
    fillHatchUniformValues,
    fillPatternUniformValues,
    fillOutlineUniformValues,
    fillOutlinePatternUniformValues
};
