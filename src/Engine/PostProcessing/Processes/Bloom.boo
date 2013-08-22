namespace Spectral.PostProcess.Processes

import System
import OpenTK.Graphics.OpenGL
import Spectral.Graphics
import Spectral.Graphics.Textures
import Spectral.PostProcess

class Bloom(PostProcess):
"""A two pass bloom filter."""

    # The first pass of our bloom shader is actually also a PostProcess.
    private class FirstPass(PostProcess):
        private _firstPass as PostProcessProgram

        def constructor():
        """Constructor."""
            _firstPass = PostProcessProgram()
            _firstPass.AddShader(Shader.LoadFromFile(ShaderType.VertexShader, "./Resources/Shaders/Engine/PostProcessing/pass.vs"))
            _firstPass.AddShader(Shader.LoadFromFile(ShaderType.FragmentShader, "./Resources/Shaders/Engine/PostProcessing/bloom1.fs"))

        def Processing(texture as Texture2D):
        """Processes the first bloom pass."""
            texture.Bind()
            GL.BindVertexArray(_vertexArray)

            _firstPass.Use()
            GL.DrawArrays(BeginMode.Quads, 0, 4)

        override def Create(width as uint, height as uint):
            super(width, height)

            _firstPass.Width  = width
            _firstPass.Height = height

        override def Dispose():
            super()
            _firstPass.Dispose()

    private _firstPass as FirstPass
    private _secondPass as PostProcessProgram

    def constructor():
    """Constructor."""
        _firstPass  = FirstPass()

        _secondPass = PostProcessProgram()
        _secondPass.AddShader(Shader.LoadFromFile(ShaderType.VertexShader, "./Resources/Shaders/Engine/PostProcessing/pass.vs"))
        _secondPass.AddShader(Shader.LoadFromFile(ShaderType.FragmentShader, "./Resources/Shaders/Engine/PostProcessing/bloom2.fs"))

    def Processing(texture as Texture2D):
    """
    The actual processing of the shader onto a texture.
    Param texture: The initial texture to process onto.
    """
        _firstPass.Process(texture)
        _firstPass.Texture.Bind()
        GL.BindVertexArray(_vertexArray)

        _secondPass.Use()
        GL.DrawArrays(BeginMode.Quads, 0, 4)

    override def Create(width as uint, height as uint):
    """
    When created, update the shader variables as well.
    Param width: Width of the framebuffer.
    Param height: Height of the framebuffer.
    """
        super(width, height)

        _firstPass.Create(width, height)
        _secondPass.Width  = width
        _secondPass.Height = height

    override def Dispose():
    """Cleanup."""
        return if _disposed

        _firstPass.Dispose()
        _secondPass.Dispose()

        super()