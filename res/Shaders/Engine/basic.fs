#version 330

in vec4 lighting;

out vec4 color;

uniform sampler1D tex;

void main()
{
	color = lighting;
}