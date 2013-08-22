namespace Spectral.PostProcess.Processes

import System
import OpenTK.Graphics.OpenGL
import Spectral.Graphics
import Spectral.Graphics.Textures
import Spectral.PostProcess

class Empty(PostProcess):
"""Dummy post process that does no filtering."""
    private _program as PostProcessProgram

    def constructor():
    """Constructor."""
        _program = PostProcessProgram()
        _program.AddShader(Shader.LoadFromFile(ShaderType.VertexShader, "./Resources/Shaders/Engine/PostProcessing/pass.vs"))
        _program.AddShader(Shader.LoadFromFile(ShaderType.FragmentShader, "./Resources/Shaders/Engine/PostProcessing/pass.fs"))

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