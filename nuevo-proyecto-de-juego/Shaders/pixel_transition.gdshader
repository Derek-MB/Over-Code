shader_type canvas_item;

uniform sampler2D next_texture : source_color;
uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform float pixel_size : hint_range(1.0, 100.0) = 40.0;

void fragment() {
    vec2 uv = UV;

    // Coordenadas usadas SOLAMENTE para crear los bloques
    vec2 pixel_uv = floor(uv * pixel_size) / pixel_size;

    // Ambas imágenes se leen con UV normal.
    // Por eso las dos permanecen completamente nítidas.
    vec4 current = texture(TEXTURE, uv);
    vec4 next = texture(next_texture, uv);

    // Patrón de bloques/píxeles
    float noise = fract(
        sin(
            dot(pixel_uv, vec2(12.9898, 78.233))
        ) * 43758.5453
    );

    // Cada bloque decide cuándo cambiar
    float mask = step(noise, progress);

    // Revela la segunda imagen mediante bloques
    COLOR = mix(current, next, mask);
}