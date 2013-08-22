namespace Spectral.Gwen

import System
import Spectral.Graphics

class Gwenterface(IDisposable, IRenderable):
"""Gwenterface is our 2D GUI rendering class."""

    Canvas as Gwen.Control.Canvas:
    """The canvas of Gwenterface, on which the controls will be placed on."""
        get:
            return _gwenCanvas

    Width as uint:
    """The width of the render canvas."""
        get:
            return _width

    Height as uint:
    """The height of the render canvas."""
        get:
            return _height

    Input as Input:
    """The input handler for the canvas."""
        get:
            return _gwenInput

    Console as Console:
    """The main engine console."""
        get:
            return _console

    private _engine as Spectral.Engine
    private _width as uint
    private _height as uint

    private _gwenRenderer as Renderer
    private _gwenSkin as Gwen.Skin.Base
    private _gwenCanvas as Gwen.Control.Canvas
    private _gwenInput as Input

    private _console as Console

    def constructor(engine as Spectral.Engine):
    """
    Constructor.
    Remarks: The engine has to be running (A rendering context exists).
    Param engine: The engine to which this Gwenterface will belong to.
    Raises NullReferenceException: engine may not be null.
    Raises ArgumentException: The engine has not rendering window (it does not exist).
    """
        raise NullReferenceException("The engine given to the Gwenterface is null.") if engine is null
        _engine = engine

        raise ArgumentException("The engine does not exist (there is no rendering window!)") if not engine.Exists

        _gwenRenderer     = Renderer(true)
        _gwenSkin        = Gwen.Skin.TexturedBase(_gwenRenderer, "./Resources/Textures/Engine/gwen_black.png")
        _gwenCanvas     = Gwen.Control.Canvas(_gwenSkin)

        _gwenCanvas.SetSize(engine.ClientRectangle.Width, engine.ClientRectangle.Height)
        _gwenCanvas.ShouldDrawBackground = false

        _gwenInput        = Input(engine)
        _gwenInput.Initialize(_gwenCanvas)

        _console         = Console(_gwenCanvas, engine)

    def SetSize(width as uint, height as uint):
    """
    Changes the size of the render canvas.
    Param width: The width of the render canvas in pixels.
    Param height: The height of the render canvas in pixels.
    """
        _gwenCanvas.SetSize(width, height)
        _gwenRenderer.Program.Width  = width
        _gwenRenderer.Program.Height = height

        _width  = width
        _height = height

    def Dispose():
    """Free the managed resources used by GWEN."""
        _gwenRenderer.Dispose()
        _gwenSkin.Dispose()
        _gwenCanvas.Dispose()

    def Render():
    """Renders the Gwenterface Canvas on the screen."""
        Canvas.RenderCanvas()