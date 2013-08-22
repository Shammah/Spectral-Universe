namespace Spectral.PostProcess

import System
import System.Collections.Generic
import OpenTK.Graphics.OpenGL
import Spectral.Graphics
import Spectral.Graphics.Textures

class PostProcessing(PostProcessFrameBuffer, IRenderable):
"""
Class that collects the wanted post-processes and performs them.
Todo: Multisampling lol.
"""

    private _processes as Queue[of PostProcess]
    private _program as PostProcessProgram
    private _texture as Texture2D

    def constructor():
    """Constructor."""
        _processes = Queue[of PostProcess]()
        _texture   = null

        # Empty passthrough program just so we can render the final result.
        _program   = PostProcessProgram()
        _program.AddShader(Shader.LoadFromFile(ShaderType.VertexShader, "./Resources/Shaders/Engine/PostProcessing/pass.vs"))
        _program.AddShader(Shader.LoadFromFile(ShaderType.FragmentShader, "./Resources/Shaders/Engine/PostProcessing/pass.fs"))

    def Render():
    """Perform the post-processing and render to the screen."""
        _texture = _renderTexture

        # Apply post processes.
        for pp in _processes:
            pp.Process(_texture)
            _texture = pp.Texture

        # Render our final output to the screen.
        GL.BindFramebuffer(FramebufferTarget.Framebuffer, 0)
        _texture.Bind()
        GL.BindVertexArray(_vertexArray)

        _program.Use()
        GL.DrawArrays(BeginMode.Quads, 0, 4)

    def Enqueue(pp as PostProcess):
    """
    Puts a post process into the queue.
    Param pp: The postprocess to be put on the queue.
    Raises NullReferenceException: pp may not be null.
    """
        raise NullReferenceException("PostProcess is null.") if pp is null
        pp.Create(Width, Height)
        _processes.Enqueue(pp)

    def Dequeue():
    """
    Removes a post process form the end of the queue.
    Raises InvalidOperationException: There is no item in the queue.
    """
        pp as PostProcess = _processes.Dequeue()
        pp.Dispose()

    def Contains(pp as PostProcess) as bool:
    """Returns whether the queue contains a given post process already."""
        return _processes.Contains(pp)

    def Peek() as PostProcess:
    """
    Returns the beginning (first) element of the queue.
    Raises InvalidOperationException: There is no item in the queue.
    """
        return _processes.Peek()

    override def Create(width as uint, height as uint):
    """
    Creates the framebuffers for all the framebuffers, including the post-processes ones.
    Param width: The width of the framebuffer in pixels.
    Param height: The height of the framebuffer in pixels.
    """
        super(width, height)
        
        for pp in _processes:
            pp.Create(width, height)

    override def Dispose():
    """Cleanup."""
        return if _disposed

        for pp in _processes:
            pp.Dispose()

        super()