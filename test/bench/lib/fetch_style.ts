import type {StyleSpecification} from '@terralytica/maplibre-gl-style-spec';

export default function fetchStyle(value: string | StyleSpecification): Promise<StyleSpecification> {
    return typeof value === 'string' ?
        fetch(value).then(response => response.json()) :
        Promise.resolve(value);
}
