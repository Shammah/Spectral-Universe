namespace Universe.Armory

import OpenTK
import Spectral
import Universe.Actors

abstract class Projectile(GameMesh, IUpdatable):
"""Projectiles have a moving speed, a moving direction and can be updated."""

    Speed as single:
    """The moving speed of the projectile."""
        virtual get:
            return _speed

        virtual set:
            _speed = value

    Direction as Vector3:
    """The moving direction of the projectile."""
        virtual get:
            return _direction

        virtual set:
            _direction = Vector3.Normalize(value)

    Owner as Spectral.Actors.Actor:
    """The owner of the projectile."""
        get:
            return _owner
        set:
            _owner = value

    private _speed as single
    private _direction as Vector3
    private _owner as Spectral.Actors.Actor

    def constructor(name as string, owner as Spectral.Actors.Actor, resource as string, program as Spectral.Graphics.Programs.GLProgram):
    """Constructs a laser ray."""
        super(name, resource, program)

        Speed       = 0
        Direction   = Vector3.Zero
        Owner       = owner

    abstract def Update(elapsedTime as single):
    """
    Updates the projection logic.
    Param elapsedTime: The time delta since the last Update() invocation.
    """
        pass