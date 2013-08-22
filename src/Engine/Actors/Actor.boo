namespace Spectral.Actors

import System
import OpenTK
import Spectral

abstract class Actor:
"""Basic Actor class, which represents an entity in the game. It has a position, orientation, scale and (possibly) model."""
    
    Name as string:
    """An actor needs to be identified by a name."""
        get:
            return _name

    Map as Map:
    """An actor can be tied to, or be part of a map."""
        get:
            return _map

        virtual set:
            # Remove the actor first if it was present already in a map.
            _map.RemoveActor(self) if _map is not null and value != _map

            # Add the new actor to the map
            value.AddActor(self) if value is not null

            _map = value
            OnSpawn(_map) if _map is not null

    Position as Vector3:
    """
    The position of the Actor in world space.
    """
        get:
            return _position
        set:
            deltaPos    = value - _position
            _position   = value
            OnPositionChanged(self, deltaPos)

    Orientation as Quaternion:
    """
    The orientation of the Actor in world space as quaternion
    """
        get:
            return _orientation
        set:
            oldOrient       = _orientation
            _orientation    = value
            OnOrientationChanged(self, oldOrient - _orientation)

    Scale as Vector3:
    """
    The scale of the Actor in world space. In general, this is for scaling a (possible) boundary box and/or model.
    Raises ArgumentException: A scaling component can only be positive.
    """
        get:
            return _scale
        set:
            if value.X <= 0 or value.Y <= 0 or value.Z <= 0:
                raise ArgumentException("A scaling component can only be positive.")
                
            deltaScale  = Vector3(value.X / _scale.X, value.Y / _scale.Y, value.Z / _scale.Z)
            _scale      = value
            OnScaleChanged(self, deltaScale)

    event OnPositionChanged as callable(Actor, Vector3)
    event OnOrientationChanged as callable(Actor, Quaternion)
    event OnScaleChanged as callable(Actor, Vector3)

    event OnSpawn as callable(Map)
    event OnDestroyed as callable(Actor)

    private _position as Vector3
    private _orientation as Quaternion
    private _scale as Vector3

    private _name as string
    private _map as Map

    def constructor(name as string):
    """
    Constructor.
    Param name: Name of the actor.
    """
        self(name, Vector3.Zero, Quaternion.Identity, Vector3.One)

    def constructor(name as string, pos as Vector3):
    """
    Constructor.
    Param name: Name of the actor.
    Param pos: The position vector in world space coordinates.
    """
        self(name, pos, Quaternion.Identity, Vector3.One)

    def constructor(name as string, pos as Vector3, orient as Quaternion):
    """
    Constructor.
    Param name: Name of the actor.
    Param pos: The position vector in world space coordinates.
    Param orient: The orientation for as a quaternion.
    """
        self(name, pos, orient, Vector3.One)

    def constructor(name as string, pos as Vector3, orient as Quaternion, scale as Vector3):
    """
    Constructor.
    Param name: Name of the actor.
    Param pos: The position vector in world space coordinates.
    Param orient: The orientation for as a quaternion.
    Param scale: The scale of the actor. USed in for exambly possible boundary boxes and/or models.
    """
        raise NullReferenceException("Name cannot be null.") if name is null
        raise ArgumentException("Name cannot be empty.") if name == String.Empty

        Position    = pos
        Orientation = orient
        Scale       = scale

        _name       = name
        _map        = null

    virtual def Destroy():
    """Destroys the actor, whatever that may be"""
        OnDestroyed(self)

        (self cast IDisposable).Dispose() if self isa IDisposable