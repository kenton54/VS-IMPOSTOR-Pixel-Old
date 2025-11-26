#pragma header

uniform float uRadius;
uniform vec2 uCenter;

void main() {
    vec2 uv = (openfl_TextureCoordv * openfl_TextureSize) / openfl_TextureSize;
    vec2 center = uCenter / openfl_TextureSize;
    float dist = distance(uv, center);

    if (dist < uRadius) {
        gl_FragColor = flixel_texture2D(bitmap, uv);
    } else {
        discard;
    }
}