#version 330

in vec4 lighting;
in float U;

out vec4 color;

uniform sampler1D tex;

void main()
{
	color = lighting * texture(tex, U);
}