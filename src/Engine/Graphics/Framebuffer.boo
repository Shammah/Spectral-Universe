namespace Spectral.Graphics

import System
import OpenTK.Graphics.OpenGL

abstract class Framebuffer(IDisposable):
    Width as uint:
    """Width of the framebuffer in pixels."""
        get:
            return _width
        protected set:
            _width = value

    Height as uint:
    """Height of the framebuffer in pixels."""
        get:
            return _height
        protected set:
            _height = value

    FrameBuffer as uint:
    """The framebuffer itself."""
        get:
            return _renderTarget

    protected _renderTarget as int

    private _width as uint
    private _height as uint

    private _begin as bool

    private _oldFramebuffer as int
    private _oldViewport as (int)

    protected _disposed as bool

    def constructor():
    """Constructor."""
        GL.GenFramebuffers(1, _renderTarget)
        _oldViewport    = array(int, 4)
        _disposed       = false

    virtual def Begin():
    """Call this function to target any rendering to the framebuffer."""
        return if _begin

        GL.GetInteger(GetPName.FramebufferBinding, _oldFramebuffer)
        GL.GetInteger(GetPName.Viewport, _oldViewport)

        GL.BindFramebuffer(FramebufferTarget.Framebuffer, _renderTarget)
        GL.Viewport(0,0, Width, Height)

        GL.ClearColor(System.Drawing.Color.Black)
        GL.Clear(ClearBufferMask.ColorBufferBit | ClearBufferMask.DepthBufferBit)

        _begin = true

    virtual def End():
    """Call the function after you're done with rendering to the framebuffer."""
        raise Exception("You're calling the Framebuffer End() function without having called Begin() first.") unless _begin

        GL.BindFramebuffer(FramebufferTarget.Framebuffer, _oldFramebuffer)
        GL.Viewport(_oldViewport[0], _oldViewport[1], _oldViewport[2], _oldViewport[3])

        _begin = false

    virtual def Dispose():
    """Cleanup."""
        return if _disposed

        GL.DeleteFramebuffers(1, _renderTarget)

        _disposed = true