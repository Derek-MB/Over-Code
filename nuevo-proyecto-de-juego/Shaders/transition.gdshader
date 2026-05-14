shader_type canvas_item;

uniform float progress : hint_range(0.0, 1.0) = 0.0;

void fragment() {
    vec2 uv = UV;

    // patrón tipo puntos
    float grid = step(0.5, fract(uv.x * 20.0)) * step(0.5, fract(uv.y * 20.0));

    // mezcla con progreso
    float mask = step(progress, uv.x + uv.y + grid * 0.2);

    COLOR = vec4(0.0, 0.0, 0.0, mask);
}