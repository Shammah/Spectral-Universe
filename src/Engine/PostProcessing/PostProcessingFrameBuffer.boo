namespace Spectral.PostProcess

import System
import OpenTK.Graphics.OpenGL
import Spectral.Graphics
import Spectral.Graphics.Textures

class PostProcessFrameBuffer(Framebuffer):
"""This class contains a framebuffer, and everything rendered to it will be rendered into a texture and depthbuffer."""

    Texture as Texture2D:
    """The texture that gets rendered to."""
        get:
            return _renderTexture

    protected _renderTexture as Texture2D
    protected _depthRenderBuffer as uint

    protected _vertexArray as uint
    private _vertexBuffer as uint

    def constructor():
    """Constructor."""
        GL.GenRenderbuffers(1, _depthRenderBuffer)

        GL.GenVertexArrays(1, _vertexArray)
        GL.BindVertexArray(_vertexArray)

        GL.GenBuffers(1, _vertexBuffer)
        GL.BindBuffer(BufferTarget.ArrayBuffer, _vertexBuffer)

        quad = (-1.0f, -1.0f,   0.0f, 0.0f,
                1.0f, -1.0f,    1.0f, 0.0f,
                1.0f,  1.0f,    1.0f, 1.0f,
                -1.0f,  1.0f,   0.0f, 1.0f)
        GL.BufferData(BufferTarget.ArrayBuffer, IntPtr(sizeof(single) * quad.Length), quad, BufferUsageHint.StaticDraw)

        GL.EnableVertexAttribArray(0)
        GL.EnableVertexAttribArray(1)
        GL.VertexAttribPointer(0, 2, VertexAttribPointerType.Float, false, sizeof(single) * 4, 0)
        GL.VertexAttribPointer(1, 2, VertexAttribPointerType.Float, false, sizeof(single) * 4, sizeof(single) * 2)

        GL.BindVertexArray(0)

    virtual def Create(width as uint, height as uint):
    """
    Creates a framebuffer and binds a Texture2D and Renderbuffer to it.
    Param width: The width of the Texture2D and Renderbuffer in pixels.
    Param height: The height of the Texture2D and Renderbuffer in pixels.
    Raises Exception: There was an error in the creation of the framebuffer.
    """
        Width  = width
        Height = height

        # Setup the texture
        _renderTexture = Texture2D(Width, Height, 0, PixelInternalFormat.Rgb, PixelFormat.Rgb, PixelType.UnsignedByte, IntPtr.Zero)

        # Setup the Renderbuffer
        GL.BindRenderbuffer(RenderbufferTarget.Renderbuffer, _depthRenderBuffer)
        GL.RenderbufferStorage(RenderbufferTarget.Renderbuffer, RenderbufferStorage.DepthComponent24, Width, Height);

        # Setup the Framebuffer
        GL.BindFramebuffer(FramebufferTarget.Framebuffer, _renderTarget)
        GL.FramebufferTexture2D(FramebufferTarget.Framebuffer,
                                FramebufferAttachment.ColorAttachment0,
                                TextureTarget.Texture2D,
                                _renderTexture.Handle,
                                0)
        GL.FramebufferRenderbuffer(FramebufferTarget.Framebuffer,
                                   FramebufferAttachment.DepthAttachment,
                                   RenderbufferTarget.Renderbuffer,
                                   _depthRenderBuffer)

        # Quick check to see if all has gone well.
        if GL.CheckFramebufferStatus(FramebufferTarget.Framebuffer) != FramebufferErrorCode.FramebufferComplete:
            raise Exception("Error creating framebuffer. ERMAGAERD ABANDON SHIP!")

        GL.DrawBuffer(DrawBufferMode.ColorAttachment0)

        # Restore
        GL.BindFramebuffer(FramebufferTarget.Framebuffer, 0)
        GL.BindRenderbuffer(RenderbufferTarget.Renderbuffer, 0)
        
        _renderTexture.BindZero()

    override def Dispose():
    """Cleanup."""
        return if _disposed

        _renderTexture.Dispose()
        GL.DeleteRenderbuffers(1, _depthRenderBuffer)

        GL.DeleteBuffers(1, _vertexBuffer)
        GL.DeleteVertexArrays(1, _vertexArray)

        super()