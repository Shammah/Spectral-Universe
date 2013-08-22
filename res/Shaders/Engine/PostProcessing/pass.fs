#version 330

in vec2 UV;

uniform sampler2D tex;
uniform uint width;
uniform uint height;

out vec4 color;

void main()
{
    // Does no filtering.
    // The vec2 for width and height is needed to avoid errors in not finding both uniform variables.
    // By using our default PostProcessingProgram, the initial width and height are 1, so everything is unaffected.
    float w = width;
    float h = height;

    color = texture(tex, UV * vec2(w, h));
}