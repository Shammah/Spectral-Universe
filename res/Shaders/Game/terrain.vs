#version 330

layout(location = 0) in vec3 vertexPosition;
layout(location = 1) in vec3 vertexNormal;
layout(location = 2) in float vertexColor;

uniform mat4 projection;
uniform mat4 modelView;
uniform mat4 normalTransformation;

// Lights!
// %numLights% is the number of lights our shader will have, and has to be replaced just before compiling the shader.
// Beware of the case of 0 lights, as you cannot have an array consisting of 0 elements.
uniform vec4  lightPos[%numLights%];
uniform vec4  lightColor[%numLights%];
uniform float lightIntensity[%numLights%];

uniform vec4  ambientColor;
uniform float shininess;

out vec4  lighting;
out float U;

// Global position and normal variable, because I don't feel like passing it around.
vec4 position = vec4(0);
vec3 normal   = vec3(0);

// Function prototype.
void addDiffuse(int n);
void addSpecular(int n);

/// Main entry of our vertex shader.
void main()
{
	position 		= modelView * vec4(vertexPosition, 1.0);
	normal 			= (normalTransformation * vec4(vertexNormal, 0.0)).xyz;
	lighting		= ambientColor; // Ambient shading.
	U 				= vertexColor;

	// Process all lights.
	for (int i = 0; i < %numLights%; i++)
	{
		addDiffuse(i);
		addSpecular(i);
	}

	// Project from camera space onto the screen using a perspective projection.
	gl_Position = projection * position;
}

/// Adds diffuse light from light n to the fragment color.
///
/// @param i Which light to add.
/// @post lighting will be updated.
void addDiffuse(int n)
{
	// If there is no such light, I'm outta here...
	if (n >= %numLights%)
	{
		return;
	}

	// Calculate the angle between the normal and incoming light ray on the given vertexPosition.
	// Note that this does not take account for obstacles etc, so no shadowing!
	float angle;
	if (lightPos[n].w == 0)
	{
		angle = clamp(dot(-normalize(lightPos[n].xyz), normal), 0, 1); // Light is coming AT the normal, so invert.
		lighting += lightColor[n] * lightIntensity[n] * angle;
	}

	else
	{
		angle = clamp(dot(normalize(lightPos[n].xyz - position.xyz), normal), 0, 1);
		float intensity = lightIntensity[n] / length(lightPos[n].xyz - position.xyz); // Loss is intensity / distance from light to surface.
		lighting += lightColor[n] * intensity * angle;
	}
}

/// Adds specular lighting from light n to the fragment color.
///
/// @param i Which light to add.
/// @post lighting will be updated.
void addSpecular(int n)
{
	// If there is no such light, I'm outta here...
	if (n >= %numLights%)
	{
		return;
	}

	// Calculate the angle between the vector from eye to vertex and the reflect light vector.
	vec3 eye 	= normalize(position.xyz);
	vec3 light  = vec3(0);
	float angle = 0;

	if (lightPos[n].w == 0)
	{
		light = reflect(-normalize(lightPos[n].xyz), normal); // Light is coming AT the normal, so invert.
		angle = clamp(dot(eye, light), 0, 1);
		lighting += lightColor[n] * lightIntensity[n] * pow(angle, shininess);
	}

	else
	{
		light = reflect(normalize(lightPos[n].xyz - position.xyz), normal);
		angle = clamp(dot(eye, light), 0, 1);
		float intensity = lightIntensity[n] / length(lightPos[n].xyz - position.xyz); // Loss is intensity / distance from light to surface.
		lighting += lightColor[n] * intensity * pow(angle, shininess);
	}
}