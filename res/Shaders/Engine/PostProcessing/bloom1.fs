#version 330

in vec2 UV;

uniform sampler2D tex;
uniform uint width;

out vec4 color;

float w = width;
float dw = 1.0f / width;

int radius = 4; // The amount of pixel neigbours to look at.
float gaussian[4] = float[] (0.241f, 0.053f, 0.0044f, 0.0013f);

void main()
{
    vec4 sum = vec4(0);

    sum += 0.0013f * 2 * texture(tex, UV + vec2(dw * -3 * 3, 0));
    sum += 0.0044f * 2 * texture(tex, UV + vec2(dw * -2 * 3, 0));
    sum += 0.0530f * 2 * texture(tex, UV + vec2(dw * -1 * 3, 0));
    sum += 0.2410f * 2 * texture(tex, UV + vec2(dw *  0 * 3, 0));
    sum += 0.0530f * 2 * texture(tex, UV + vec2(dw *  1 * 3, 0));
    sum += 0.0044f * 2 * texture(tex, UV + vec2(dw *  2 * 3, 0));
    sum += 0.0013f * 2 * texture(tex, UV + vec2(dw *  3 * 3, 0));

    color = texture(tex, UV) + sum;
}