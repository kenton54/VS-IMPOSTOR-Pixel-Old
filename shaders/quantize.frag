#pragma header

uniform float u_steps;

void main() {
	vec4 tex = flixel_texture2D(bitmap, openfl_TextureCoordv);
	gl_FragColor = vec4(vec3(floor(tex.rgb * u_steps + 0.5) / u_steps), tex.a);
}