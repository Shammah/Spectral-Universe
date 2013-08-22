namespace Spectral.Gwen

import System
import OpenTK
import OpenTK.Graphics.OpenGL
import Spectral.Graphics
import Spectral.Graphics.Programs

class GwenProgram(GLProgram):
"""Shader needed to render the Gwenterface."""

    Width as uint:
    """
    Width of the render canvas in pixels.
    Remarks: private variable _projChanged will be true.
    """
        get:
            return _width
        set:
            _width             = value
            _projChanged     = true

    Height as uint:
    """
    Height of the render canvas in pixels.
    Remarks: private variable _projChanged will be true.
    """
        get:
            return _height
        set:
            _height         = value
            _projChanged    = true

    private _width as uint
    private _height as uint

    private _proj_uniform as int
    private _text_uniform as int

    private _projChanged as bool

    def constructor():
    """Constructor."""
        vertex as Shader   = Shader.LoadFromFile(ShaderType.VertexShader, "./Resources/Shaders/Engine/gwen.vs")
        fragment as Shader = Shader.LoadFromFile(ShaderType.FragmentShader, "./Resources/Shaders/Engine/gwen.fs")
        AddShader(vertex)
        AddShader(fragment)

        Width  = 800
        Height = 600

    override def Link():
        super.Link()

        # Once linked up, we can retrieve our uniform variables.
        _proj_uniform = GL.GetUniformLocation(Handle, "projection")
        if (_proj_uniform == -1):
            raise GLProgramException(self, "Unable to locate uniform shader variable 'projection' in GwenShader'.")

        _text_uniform = GL.GetUniformLocation(Handle, "textured")
        if (_text_uniform == -1):
            raise GLProgramException(self, "Unable to locate uniform shader variable 'textured' in GwenShader'.")

    override def Use():
        super.Use()

        if _projChanged:
            proj as Matrix4 = Matrix4.CreateOrthographicOffCenter(0, Width, Height, 0, -1, 1)
            GL.UniformMatrix4(_proj_uniform, false, proj)
            _projChanged = false

    def Textured(toggle as bool):
    """
    This will enable or disable textures from the shader, as they are not always needed.
    Param toggle: Whether textures are enabled or not.
    """
        if toggle:
            GL.Uniform1(_text_uniform, 1)
        else:
            GL.Uniform1(_text_uniform, 0)