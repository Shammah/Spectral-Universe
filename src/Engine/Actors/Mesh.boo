namespace Spectral.Actors

import System
import OpenTK
import OpenTK.Graphics.OpenGL
import Spectral
import Spectral.Graphics
import Spectral.Graphics.Programs
import Spectral.Physics.Collision

class Mesh(Actor, IDisposable, IRenderable):
"""
An actor that has a representable 3D model, thus a Mesh.
Bug / Todo: Setting the program after properties like pos, rot and scale is broken and does not work!
Todo: Proper constructor chaining.
"""

    Map as Map:
        override set:
            # Remove the observers from any previous map.
            if Map is not null and value != Map:
                RemoveFromMap(Map)

            # If the map is not null, add event listeners if needed for the programs!
            if value is not null:
                AddToMap(value)

            super(value)

    Model as IModel:
    """
    The actor's 3D model. This can be null to indicate there is no such!
    Raises NullReferenceException: Model cannot be null.
    """
        get:
            return _model
        set:
            raise NullReferenceException("A mesh cannot have no model. If you want it to be invisible, set Visible to false instead.") if value is null
            _model = value

    ModelMatrix as Matrix4:
    """Returns the model matrix, which gives a transformation matrix for going from Modelspace to Worldspace."""
        get:
            return _modelMatrix

    Visible as bool:
    """Whether the model should be visible or not."""
        get:
            return _visible
        set:
            _visible = value

    OBB as BoundingBox:
    """Returns or sets the bounding box of the model."""
        get:
            return _obb
        set:
            _obb = value

    private _model as IModel
    private _modelMatrix as Matrix4

    private _visible as bool
    private _mode as BeginMode

    private _obb as BoundingBox

    protected _disposed as bool

    def constructor(name as string, model as IModel):
    """
    Constructor.
    Param name: Name of the actor.
    Param model: The model of the mesh.
    """
        super(name, Vector3.Zero, Quaternion.Identity, Vector3.One)
        Init(model, true)

    def constructor(name as string, model as IModel, pos as Vector3):
    """
    Constructor.
    Param name: Name of the actor.
    Param model: The model of the mesh.
    Param pos: The position vector in world space coordinates.
    """
        super(name, pos, Quaternion.Identity, Vector3.One)
        Init(model, true)

    def constructor(name as string, model as IModel, pos as Vector3, orient as Quaternion):
    """
    Constructor.
    Param name: Name of the actor.
    Param model: The model of the mesh.
    Param pos: The position vector in world space coordinates.
    Param orient: The orientation for as a quaternion.
    """
        super(name, pos, orient, Vector3.One)
        Init(model, true)

    def constructor(name as string, model as IModel, pos as Vector3, orient as Quaternion, scale as Vector3):
    """
    Constructor.
    Param name: Name of the actor.
    Param model: The model of the mesh.
    Param pos: The position vector in world space coordinates.
    Param orient: The orientation for as a quaternion.
    Param scale: The scale of the actor. USed in for exambly possible boundary boxes and/or models.
    """
        super(name, pos, orient, scale)
        Init(model, true)

    private def Init(model as IModel, visible as bool):
    """
    Initializes the model class.
    Param model: The model of the mesh.
    Param visible: Whether the model should be visisble (to be rendered) or not.
    """
        Model                   = model
        Visible                 = visible

        OnPositionChanged      += ModelMatrixUpdatePosition
        OnOrientationChanged   += ModelMatrixUpdateOrient
        OnScaleChanged         += ModelMatrixUpdateScale

        _disposed               = false
        _obb                    = null

    virtual def Render():
    """Renders the mesh, if it were visible."""
        Model.Render() if Visible

    virtual def Dispose():
    """Gets rid of the unmanaged resources."""
        return if _disposed

        Map = null
        Model.Dispose()

        _disposed = true

    private def ModelMatrixUpdateOrient(actor as Actor, delta as Quaternion):
    """
    Called when the orientation has been changed.
    Param actor: Reference to the actor which has changed.
    Param delta: All delta changes made in the orientation.
    """
        scale           = Matrix4.CreateScale(actor.Scale)
        rotate          = Matrix4.CreateFromQuaternion(actor.Orientation)
        translate       = Matrix4.CreateTranslation(actor.Position)
        _modelMatrix    = scale * rotate * translate

        # Update shader program if needed.
        if Model.Program is not null:
            (Model.Program cast MVPProgram).Model = _modelMatrix if Model.Program isa MVPProgram

        # Update bounding box.
        OBB.Orientation = actor.Orientation if OBB is not null

    private def ModelMatrixUpdatePosition(actor as Actor, delta as Vector3):
    """
    Called when the position has been changed.
    Param actor: Reference to the actor which has changed.
    Param delta: All delta changes made in the position.
    """
        scale           = Matrix4.CreateScale(actor.Scale)
        rotate          = Matrix4.CreateFromQuaternion(actor.Orientation)
        translate       = Matrix4.CreateTranslation(actor.Position)
        _modelMatrix    = scale * rotate * translate

        # Update shader program if needed.
        if Model.Program is not null:
            (Model.Program cast MVPProgram).Model = _modelMatrix if Model.Program isa MVPProgram
        
        # Update bounding box.
        OBB.Position = actor.Position if OBB is not null

    private def ModelMatrixUpdateScale(actor as Actor, delta as Vector3):
    """
    Called when the scale has been changed.
    Param actor: Reference to the actor which has changed.
    Param delta: All delta changes made in the scale.
    """
        scale           = Matrix4.CreateScale(actor.Scale)
        rotate          = Matrix4.CreateFromQuaternion(actor.Orientation)
        translate       = Matrix4.CreateTranslation(actor.Position)
        _modelMatrix    = scale * rotate * translate

        # Update shader program if needed.
        if Model.Program is not null:
            (Model.Program cast MVPProgram).Model = _modelMatrix if Model.Program isa MVPProgram
        
        # Update bounding box.
        if OBB is not null:
            OBB.Width  *= delta.X
            OBB.Height *= delta.Y
            OBB.Depth  *= delta.Z

    private virtual def RemoveFromMap(m as Map):
    """
    Additional cleanup when removing the Mesh from a map.
    Param m: The map to be removed from.
    Raises NullReferenceException: The map cannot be null.
    """
        raise NullReferenceException("The map cannot be null") if m is null

        if Model.Program is not null and Model.Program isa MVPProgram:
            # Remove the shader from the camera event.
            m.Engine.Camera.RemoveObserver(Model.Program cast MVPProgram)

            # Remove the lights from the shaders.
            if Model.Program isa MVPLightProgram:
                lightProgram        = Model.Program cast MVPLightProgram

                m.OnLightAdded     -= lightProgram.AddLight
                m.OnLightRemoved   -= lightProgram.RemoveLight

                lightProgram.ClearLights()

    private virtual def AddToMap(m as Map):
    """
    Initializes shaders and observers when adding to a map.
    Param m: The map to be removed from.
    Raises NullReferenceException: The map cannot be null.
    """
        raise NullReferenceException("The map cannot be null") if m is null

        if Model.Program is not null and Model.Program isa MVPProgram:
            # Add shader to the camera observer.
            m.Engine.Camera.AddObserver(Model.Program cast MVPProgram)

            # Add lights if needed for the shader.
            if Model.Program isa MVPLightProgram:
                lightProgram        = Model.Program cast MVPLightProgram

                m.OnLightAdded     += lightProgram.AddLight
                m.OnLightRemoved   += lightProgram.RemoveLight

                # Add light actors.
                for actor in m.Actors:
                    lightProgram.AddLight(actor) if actor isa Light