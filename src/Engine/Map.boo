namespace Spectral

import System
import System.Collections.Generic
import Spectral.Actors
import Spectral.Audio
import Spectral.Graphics

class Map(IDisposable, IRenderable):
"""Each map is mostly made out of actors."""

    Name as string:
    """The name of the map."""
        get:
            return _name
        set:
            raise ArgumentException("The name may not be empty or null.") if value == String.Empty or value is null
            _name = value

    Engine as Engine:
    """Engine that the map belongs to."""
        get:
            return _engine

    Log as Spectral.Log:
    """Engine log for macro purposes."""
        get:
            return _engine.Log

    Actors as ActorGroup:
    """The main actor group containing all (excluding specials) map actors."""
        get:
            return _actors

    Music as Dictionary[of string, IAudio]:
    """Dictionary of music for the map."""
        get:
            return _music

    event OnLightAdded as callable(Light)
    event OnLightRemoved as callable(Light)

    private _name as string

    private _actors as ActorGroup
    private _music as Dictionary[of string, IAudio]
    private _engine as Engine

    protected _disposed as bool

    def constructor(engine as Engine):
    """
    Constructor.
    Param engine: The engine that this map will belong to.
    Raises NullReferenceException: engine may not be null.
    """
        raise NullReferenceException("Engine is null.") if engine is null
        _engine     = engine
        _name       = "Spectral Engine Map"

        _actors     = ActorGroup()
        _music      = Dictionary[of string, IAudio]()

        _disposed   = false

    virtual def Render():
    """Renders certain groups on the screen of which we know that are renderable."""
        for actor in Actors:
            (actor as IRenderable).Render() if actor isa IRenderable

    virtual def Update(elapsedTime as single):
    """
    Updates the actors within the map.
    Param elapsedTime: The elapsed time since the last call to this function in seconds.
    """
        for actor in Actors:
            (actor as IUpdatable).Update(elapsedTime) if actor isa IUpdatable

    internal def AddActor(actor as Actor):
    """
    Adds an actor to the map.
    Remarks: DO NOT CALL DIRECTLY OR SHIT MAY HIT THE FAN. USE ACTOR.MAP = VALUE INSTEAD!
    Param name: The name of the actor.
    Param actor: The actor to add.
    Raises NullReferenceException: The actor may not be null.
    """
        raise NullReferenceException("Actor may not be null.") if actor is null
        return if actor.Map == self

        _actors.Add(actor)
        
        OnLightAdded(actor cast Light) if actor isa Light

    internal def RemoveActor(actor as Actor):
    """
    Removes an actor from the map.
    Remarks: DO NOT CALL DIRECTLY OR SHIT MAY HIT THE FAN. USE ACTOR.MAP = VALUE INSTEAD!
    Param name: The name of the actor.
    Param actor: The actor to remove.
    Raises NullReferenceException: The actor may not be null.
    """
        raise NullReferenceException("Actor may not be null.") if actor is null
        return if actor.Map != self

        _actors.Remove(actor)

        OnLightRemoved(actor cast Light) if actor isa Light

    virtual def Dispose():
    """Cleanup of all actors that are disposable."""
        return if _disposed

        _actors.Dispose()

        for music in _music.Values:
            if music is not null:
                music.Dispose()

        _disposed = true