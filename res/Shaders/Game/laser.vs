#version 330

layout(location = 0) in vec3 vertexPosition;
layout(location = 1) in vec3 vertexNormal;
layout(location = 2) in float vertexColor;

uniform mat4 projection;
uniform mat4 modelView;
uniform mat4 normalTransformation;

out float U;

/// Main entry of our vertex shader.
void main()
{
	vec4 normal = (normalTransformation * vec4(vertexPosition, 1.0)) * 0.00001;

	gl_Position = (projection * modelView * vec4(vertexPosition, 1.0)) + normal;
	U 			= vertexColor;

}