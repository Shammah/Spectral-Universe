#version 330

in vec2 UV;

uniform sampler2D tex;
uniform uint height;

out vec4 color;

float h = height;
float dh = 1.0f / height;

int radius = 4; // The amount of pixel neigbours to look at.
float gaussian[4] = float[] (0.241f, 0.053f, 0.0044f, 0.0013f);

void main()
{
    vec4 sum = vec4(0);

    sum += 0.0013f * 2 * texture(tex, UV + vec2(0, dh * -3 * 3));
    sum += 0.0044f * 2 * texture(tex, UV + vec2(0, dh * -2 * 3));
    sum += 0.0530f * 2 * texture(tex, UV + vec2(0, dh * -1 * 3));
    sum += 0.2410f * 2 * texture(tex, UV + vec2(0, dh *  0 * 3));
    sum += 0.0530f * 2 * texture(tex, UV + vec2(0, dh *  1 * 3));
    sum += 0.0044f * 2 * texture(tex, UV + vec2(0, dh *  2 * 3));
    sum += 0.0013f * 2 * texture(tex, UV + vec2(0, dh *  3 * 3));

    color = texture(tex, UV) + sum;
}