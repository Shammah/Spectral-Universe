namespace Spectral.PostProcess.Processes

import System
import OpenTK.Graphics.OpenGL
import Spectral.Graphics
import Spectral.Graphics.Textures
import Spectral.PostProcess

class Wobble(PostProcess):
"""A wobble filter, that jiggles the pixels around a bit."""
    class WobbleProgram(PostProcessProgram):
    """Program used for the wobbling shaders."""
        private _time_uniform as int

        override def Link():
            super()
            _time_uniform = GL.GetUniformLocation(Handle, "time")

        override def Use():
            super()
            GL.Uniform1(_time_uniform, (System.DateTime.Now.Millisecond cast single) / 1000.0f)

    private _program as WobbleProgram

    def constructor():
    """Constructor."""
        _program = WobbleProgram()
        _program.AddShader(Shader.LoadFromFile(ShaderType.VertexShader, "./Resources/Shaders/Engine/PostProcessing/pass.vs"))
        _program.AddShader(Shader.LoadFromFile(ShaderType.FragmentShader, "./Resources/Shaders/Engine/PostProcessing/wobble.fs"))

    def Processing(texture as Texture2D):
    """
    The actual processing of the shader onto a texture.
    Param texture: The initial texture to process onto.
    """
        texture.Bind()
        GL.BindVertexArray(_vertexArray)

        _program.Use()
        GL.DrawArrays(BeginMode.Quads, 0, 4)

    override def Create(width as uint, height as uint):
    """
    When created, update the shader variables as well.
    Param width: Width of the framebuffer.
    Param height: Height of the framebuffer.
    """
        super(width, height)

        _program.Width  = width
        _program.Height = height

    override def Dispose():
    """Cleanup."""
        return if _disposed

        _program.Dispose()

        super()