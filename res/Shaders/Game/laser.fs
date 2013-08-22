#version 330

in float U;

out vec4 color;

uniform sampler1D tex;

void main()
{
	color = texture(tex, U);
}