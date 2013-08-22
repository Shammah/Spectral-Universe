#version 330

in vec2 UV;

uniform sampler2D tex;
uniform uint width;
uniform uint height;
uniform float time;

out vec4 color;
float p = 0.1;

void main()
{
    float w = width;
    float h = height;

    color = texture(tex, UV + 0.001 * vec2(sin(time + w * UV.x),cos(time + h * UV.y)));
}