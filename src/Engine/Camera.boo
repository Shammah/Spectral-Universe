namespace Spectral

import System
import System.Math as SMath
import OpenTK
import Spectral.Actors

class Camera:
"""The camera class. This will be used for viewing transformations, such as Perspective, LookAt and Orthogonal."""

    Position as Vector3:
    """The camera position in World Space."""
        get:
            return _position
        set:
            _position = value
            OnOrientationChanged(self)

    Target as Vector3:
    """The target location of where the camera should look at, in World Space."""
        get:
            return _target
        set:
            _target = value
            OnOrientationChanged(self)

    Up as Vector3:
    """The up vector of the camera, defining its orientation."""
        get:
            return _up
        set:
            _up = Vector3.Normalize(value)
            OnOrientationChanged(self)

    Direction as Vector3:
    """The normalized direction of the camera."""
        get:
            return Vector3.Normalize(Target - Position)
        set:
            Target = Position + Vector3.Normalize(value)

    Fov as single:
    """The camera's horizontal field of view in radians."""
        get:
            return FovYToFovX(_fovy)
        set:
            _fovy = FovXToFovY(value)
            _fovx = value
            OnPerspectiveChanged(self)

    FovY as single:
    """The camera's vertical field of view in radians."""
        get:
            return _fovy
        set:
            _fovy = value
            _fovx = FovYToFovX(value)
            OnPerspectiveChanged(self)

    AspectRatio as single:
    """
    The aspect ratio, needed for correct FoV calculation.
    Remarks: The field of view will be updated and changed. SO BEWARE!
    Raises ArgumentException: Aspectratio cannot be smaller than or be equal to 0.
    """
        get:
            return _aspectRatio
        protected set:
            raise ArgumentException("How on earth can an aspectratio be smaller than or equal to 0!?") if value <= 0
            _aspectRatio = value
            Fov          = _fovx
            OnPerspectiveChanged(self)

    ZNear as single:
    """
    The closest point to the camera that will still be projected onto the screen.
    Raises ArgumentException: The ZNear distance has to be bigger than 0.
    Raises ArgumentException: The ZNear distance has to be smaller than ZFar.
    """
        get:
            return _zNear
        set:
            raise ArgumentException("The zNear has to be bigger than 0.") if value <= 0
            raise ArgumentException("The zNear cannot be bigger than zFar.") if value > ZFar
            _zNear = value
            OnPerspectiveChanged(self)
            OnOrthoChanged(self)

    ZFar as single:
    """
    The furthest point respectively to the camera position that will still be projected onto the screen.
    Raises ArgumentException: The ZFar distance has to be bigger than 0.
    Raises ArgumentException: The ZFar distance has to be bigger than ZNear.
    """
        get:
            return _zFar
        set:
            raise ArgumentException("The zFar has to be bigger than 0.") if value <= 0
            raise ArgumentException("The zFar cannot be smaller than zNear.") if value < ZNear
            _zFar = value
            OnPerspectiveChanged(self)
            OnOrthoChanged(self)

    Width as single:
    """
    The width of the orthogonal projection matrix in pixels. Obviously has to be bigger than 0.
    Raises ArgumentException: The camera width has to be bigger than 0.
    """
        get:
            return _width
        set:
            raise ArgumentException("Camera width should be bigger than 0.") if value <= 0
            _width      = value
            AspectRatio = value / Height
            OnOrthoChanged(self)

    Height as single:
    """
    The height of the orthogonal projection matrix in pixels. Obviously has to be bigger than 0.
    Raises ArgumentException: The camera height has to be bigger than 0.
    """
        get:
            return _height
        set:
            raise ArgumentException("Camera width should be bigger than 0.") if value <= 0
            _height     = value
            AspectRatio = Width / value
            OnOrthoChanged(self)

    Attach as Actor:
    """Attaches the camera position to an actor's position."""
        get:
            return _actor
        set:
            # Remove old listener.
            _actor.OnPositionChanged -= OnAttachementPositionChanged if _actor is not null and _actor != value

            # Add new listener.
            value.OnPositionChanged  += OnAttachementPositionChanged if value is not null and _actor != value

            _actor = value

    event OnOrientationChanged as callable(Camera)
    event OnPerspectiveChanged as callable(Camera)
    event OnOrthoChanged as callable(Camera)

    private _position as Vector3
    private _up as Vector3
    private _target as Vector3
    private _fovy as single # In radians, and used because LookAt wants the fovy!
    private _aspectRatio as single
    private _zNear as single
    private _zFar as single
    private _width as single
    private _height as single

    private _actor as Actor

    private _fovx as single # This is what the user has set as FOV. We need to store this, as we need the original value for when the aspectratio changes.

    def constructor(camera as Camera):
    """
    Copy Constructor.
    Remark: Does not copy over any observer.
    """
        Position        = camera.Position
        Up              = camera.Up
        Target          = camera.Target
        Fov             = camera.Fov
        AspectRatio     = camera.AspectRatio
        ZNear           = camera.ZNear
        ZFar            = camera.ZFar
        Width           = camera.Width
        Height          = camera.Height
        Attach          = camera.Attach

    def constructor():
    """Constructor."""
        Position        = Vector3(0, 0, 3)
        Up              = Vector3(0, 1, 0)  # Default is Y-Axis.
        Target          = Vector3(0, 0, 2)
        _fovx           = Math.Tau / 4      # 90 degrees of horizontal FoV by default.
        _aspectRatio    = 1                 # I need -something-, right?
        _fovy           = FovXToFovY(_fovx)
        _zNear          = 0.1f
        _zFar           = 100f
        Width           = 100
        Height          = 100

        _actor          = null

    def FovXToFovY(fovx as single) as single:
    """
    Returns the vertical field of view in radians.
    Param fovx: The horizontal field of view in radians.
    """
        return 2 * SMath.Atan(SMath.Tan(0.5 * fovx) / AspectRatio)

    def FovYToFovX(fovy as single) as single:
    """
    Returns the horizontal field of view in radians.
    Param fovy: The vertical field of view in radians.
    """
        return 2 * SMath.Atan(SMath.Tan(0.5 * fovy) * AspectRatio)

    def LookAt() as Matrix4:
    """Creates a new camera-space matrix transformation, such that a camera has a position, and looks at a given target with a given up orientation."""
        return Matrix4.LookAt(Position, Target, Up)

    def Perspective() as Matrix4:
    """Creates a new perspective projection matrix with a given FoV, Aspectratio and viewing distance."""
        return Matrix4.CreatePerspectiveFieldOfView(_fovy, AspectRatio, ZNear, ZFar)

    def Orthogonal() as Matrix4:
    """Creates a new orthogonal projection matrix with the given width and height."""
        return Matrix4.CreateOrthographic(Width, Height, ZNear, ZFar)

    def Raycast(x as uint, y as uint) as Vector3:
    """
    Converts 2D screen coordinates to a normalized direction vector into the 3D world.
    Param x: The x coordinates.
    Param y: The y coordinates.
    Returns: A normalized direction vector.
    """
        dx          = (x - Width  / 2) / (Width  / 2)
        dy          = (Height / 2 - y) / (Height / 2)

        invertProj  = Matrix4.Invert(LookAt() * Perspective())
        near        = Vector4(dx, dy, 0, 1)
        far         = Vector4(dx, dy, 1, 1)

        nearWorld   = Vector4.Transform(near, invertProj)
        farWorld    = Vector4.Transform(far, invertProj)

        nearWorld  /= nearWorld.W
        farWorld   /= farWorld.W

        direction   = Vector3(farWorld.X, farWorld.Y, farWorld.Z) - Vector3(nearWorld.X, nearWorld.Y, nearWorld.Z)
        
        return Vector3.Normalize(direction)

    def AddObserver(observer as ICameraObserver):
    """
    Adds an observer to the events.
    Param observer: The observer to add.
    Raises NullReferenceException: observer may not be null.
    """
        raise NullReferenceException("Observer may not be null.") if observer is null

        OnOrientationChanged += observer.OnOrientationChanged
        OnPerspectiveChanged += observer.OnPerspectiveChanged
        OnOrthoChanged       += observer.OnOrthoChanged

        # Set up the initial camera matrices for the observer.
        observer.OnOrientationChanged(self)
        observer.OnPerspectiveChanged(self)
        observer.OnOrthoChanged(self)

    def RemoveObserver(observer as ICameraObserver):
    """
    Removes an observer from the events.
    Param observer: The observer to remove.
    Raises NullReferenceException: observer may not be null.
    """
        raise NullReferenceException("Observer may not be null.") if observer is null

        OnOrientationChanged -= observer.OnOrientationChanged
        OnPerspectiveChanged -= observer.OnPerspectiveChanged
        OnOrthoChanged       -= observer.OnOrthoChanged

    override def ToString():
        a = "Position: \t$(Position.ToString())\n"
        b = "Target: \t$(Target.ToString())\n"
        c = "Up: \t\t$(Up.ToString())\n"
        d = "Horizontal FoV: $(Fov)\n"
        e = "Vertical FoV: \t$(_fovy)\n"
        f = "Aspect Ratio: \t$(AspectRatio)\n"
        g = "ZNear: \t\t$(ZNear)\n"
        h = "ZFar: \t\t$(ZFar)\n"
        i = "Width: \t\t$(Width)\n"
        j = "Height: \t$(Height)"

        return a + b + c + d + e + f + g + h + i + j

    virtual def OnAttachementPositionChanged(actor as Actor, deltaPos as Vector3):
    """
    Moves along with the attachement.
    Param actor: The actor that is being attached to.
    Param deltaPos: The delta position of the movement of the attachement.
    """
        Position += deltaPos
        Target   += deltaPos