#version 330

flat in vec4 fragmentColor;
in vec2 UV;

out vec4 color;

uniform sampler2D tex;
uniform int textured;

void main()
{
	if (textured == 1) {
		color = texture(tex, UV) * fragmentColor;
	} else {
		color = fragmentColor;
	}
}