namespace Spectral

import System
import System.Collections.Generic
import OpenTK
import OpenTK.Graphics
import OpenTK.Graphics.OpenGL
import OpenTK.Audio
import Spectral.Actors
import Spectral.Graphics
import Spectral.PostProcess

partial class Engine(GameWindow):
"""
The main game engine class. Our game should inherit from here and expand beyond infinity!
Todo: Alpha blending only works on one side?
Todo: Just putting it here, ensure all overrides call their supers.
"""

    AspectRatio as single:
    """Returns the aspect ratio of the game (window)."""
        get:
            return ClientRectangle.Width cast single / ClientRectangle.Height cast single

    Camera as Camera:
    """
    The main camera of our engine.
    Raises NullReferenceException: The camera cnanot be null.
    """
        get:
            return _camera
        set:
            raise NullReferenceException("You cannot set a null camera for the engine.") if value is null
            _camera = value

    Map as Map:
    """The map the engine will use."""
        get:
            return _map
        set:
            _map = value

    /* Old GWEN code
    Gwenterface as Gwen.Gwenterface:
    """
    Gwenterface will be our main 2D GUI hub.
    Raises NullReferenceException: The gwenterface cannot be null.
    """
        get:
            return _gwenterface
        private set:
            raise NullReferenceException("The gwenterface cannot be set to null.") if value is null
            _gwenterface = value
    */

    CommandCentre as CommandCentre:
    """
    The command centre of our engine for issueing commands.
    Raises NullReferenceException: The commandcentre cannot be null.
    """
        get:
            return _commandCentre
        private set:
            raise NullReferenceException("The commandcentre cannot be set to null.") if value is null
            _commandCentre = value

    PostProcessing as PostProcessing:
    """
    The post-processing unit.
    Raises NullReferenceException: The post-processing unit cannot be null.
    """
        get:
            return _postProcessing
        private set:
            raise NullReferenceException("The post-processing unit cannot be set to null.") if value is null
            _postProcessing = value

    Scripts as Scripts:
    """
    The scripts system.
    Raises NullReferenceException: The script system cannot be null.
    """
        get:
            return _scripts
        set:
            raise NullReferenceException("The script system cannot be set to null.") if value is null
            _scripts = value

    AudioContext as AudioContext:
    """The OpenAL audiocontext of the engine."""
        get:
            return _ac
        private set:
            _ac = value

    Log as Log:
    """A log that will represent the engine console log."""
        get:
            return _log

    Startup as StartFunc:
    """A function thats get called at the startup (after Run())."""
        get:
            return _startFunc
        set:
            _startFunc = value

    private _camera as Camera
    private _map as Map
    private _commandCentre as CommandCentre
    private _postProcessing as PostProcessing
    private _scripts as Scripts
    //private _gwenterface as Gwen.Gwenterface Old GWEN code
    private _ac as AudioContext

    private _title as string
    private _log as Log
    private _startFunc as StartFunc

    protected _disposed as bool

    callable StartFunc()

    def constructor(width as int, height as int, gm as GraphicsMode, title as string):
    """
    Constructor.
    Param width: The width of the game window in pixels.
    Param height: The height of the game window in pixels.
    Param gm: The GraphicsMode that the engine will use.
    Param title: The window title.
    """
        super(width, height, gm, title)

        _title              = title
        _log                = Log()

        Camera              = Camera()
        CommandCentre       = CommandCentre(self)
        Scripts             = Scripts()
        Scripts.Compile()

        Keyboard.KeyDown   += Keyboard_KeyDown
        Keyboard.KeyUp     += Keyboard_KeyUp

        Mouse.ButtonDown   += Mouse_ButtonDown
        Mouse.ButtonUp     += Mouse_ButtonUp
        Mouse.Move         += Mouse_Move
        Mouse.WheelChanged += Mouse_Wheel

        # Instantiate AudioContext to default device.
        try:
            AudioContext = AudioContext()
        except ex as AudioException:
            log ex.Message, Log.Level.Error /// @todo Show warning, but play engine without sound. No need to crash.

        _disposed = false

    override def OnLoad(e as EventArgs):
    """Method is called just after the creation of the window and OpenGL context."""
        super(e)

        # Enable Dept Testing.
        GL.Enable(EnableCap.DepthTest)
        GL.DepthFunc(DepthFunction.Less)

        # Enable culling. Clockwise = front.
        GL.Enable(EnableCap.CullFace)
        GL.CullFace(CullFaceMode.Back)
        GL.FrontFace(FrontFaceDirection.Ccw)

        # Enable alpha blending.
        GL.Enable(EnableCap.Blend)
        //GL.BlendFunc(BlendingFactorSrc.SrcAlpha, BlendingFactorDest.DstAlpha)

        # Setup the camera properties.
        Camera.Fov          = Math.Tau / 4
        Camera.ZNear        = 0.1f
        Camera.ZFar         = 1000f
        Camera.Width        = ClientRectangle.Width
        Camera.Height       = ClientRectangle.Height
        log "Created camera.\n" + Camera.ToString(), Log.Level.Debug

        # Post-processing.
        PostProcessing      = PostProcessing()
        PostProcessing.Create(ClientRectangle.Width, ClientRectangle.Height)

        # Todo: creating pp after gwenterface breaks gwenterface?
        PostProcessing.Enqueue(Processes.Bloom())

        //Gwenterface         = Gwen.Gwenterface(self)
        Log.Engine          = self

        Startup() if Startup is not null

    override def OnUpdateFrame(e as FrameEventArgs):
    """This is our Update() method, which will get called each frame before rendering, thus this is our logical thinking unit."""
        super(e)
        Title = "$_title - $RenderFrequency"
        
        KeyboardProcess()
        Map.Update(RenderTime) if Map is not null

    override def OnRenderFrame(e as FrameEventArgs):
    """This is our Draw() method, where we will place our rendering for each frame."""
        super(e)
        GL.ClearColor(System.Drawing.Color.Black)
        GL.Clear(ClearBufferMask.ColorBufferBit | ClearBufferMask.DepthBufferBit)

        PostProcessing.Begin()
        
        Map.Render() if Map is not null
        
        PostProcessing.End()
        PostProcessing.Render()

        //Gwenterface.Render() if Gwenterface is not null
        SwapBuffers()

    override def OnResize(e as EventArgs):
    """This method gets called whenever our window gets resized. Useful to determine new GL Viewport and Projection Matrix."""
        super(e)
        GL.Viewport(self.ClientRectangle)
        Camera.Width  = ClientRectangle.Width
        Camera.Height = ClientRectangle.Height

        PostProcessing.Create(ClientRectangle.Width, ClientRectangle.Height)

        /* Old GWEN code
        # Just to resize it... lol.
        Gwenterface.SetSize(self.ClientRectangle.Width, self.ClientRectangle.Height)
        Gwenterface.Console.Toggle()
        Gwenterface.Console.Toggle()
        Gwenterface.Console.Toggle()
        */

    override def OnUnload(e as EventArgs):
    """Called just before the deletion of the OpenGL context, allowing us to do some cleaning up!"""
        super(e)

    virtual override def Dispose():
    """Overriden dispose, mostly needed to free unmanaged OpenGL resources."""
        return if _disposed

        //Gwenterface.Dispose() if Gwenterface is not null

        # Delete map and it's elements.
        Map.Dispose() if Map is not null

        AudioContext.Dispose() if AudioContext is not null
        PostProcessing.Dispose() if PostProcessing is not null

        _disposed = true
        super.Dispose()