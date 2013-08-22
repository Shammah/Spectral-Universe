#version 330

layout(location = 0) in vec2 vertexPosition;
layout(location = 1) in vec4 vertexColor;
layout(location = 2) in vec2 textureCords;

uniform mat4 projection;

flat out vec4 fragmentColor;
out vec2 UV;

/// Main entry of our vertex shader.
void main()
{
	gl_Position		= projection * vec4(vertexPosition.xy, 0.0, 1.0);
	fragmentColor 	= vertexColor;
	UV				= textureCords;
}