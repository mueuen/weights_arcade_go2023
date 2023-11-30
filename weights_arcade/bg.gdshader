shader_type canvas_item;

uniform vec3 color1;
uniform vec3 color2;

void fragment() {
	vec4 inColor = texture(TEXTURE, UV);
	vec3 outColor = vec3(0.0, 0.0, 0.0);
	if (inColor.r == 0.0) {
		outColor = color1;
	}
	else if (inColor.r == 1.0) {
		outColor = color2;
	}

	COLOR = vec4(outColor, 1.0);
}
