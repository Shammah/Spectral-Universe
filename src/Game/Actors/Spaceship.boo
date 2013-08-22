namespace Universe.Actors

abstract class Spaceship(GameMesh):
"""General spaceship class."""

    Health as uint:
    """A spaceship has health, just like any other livi- wait what."""
        get:
            return _health
        set:
            _health = value

    Armor as Armor:
    """Spaceship armor, not yet sure on whether I'll make it rechargable or not."""
        get:
            return _armor

    private _health as uint
    private _armor as Armor

    def constructor(name as string, resource as string, program as Spectral.Graphics.Programs.GLProgram):
    """
    Constructs a spaceship.
    Param name: Name of the actor.
    Param resource: Name of the resource, without extension.
    """
        super(name, resource, program)

        _health = 100
        _armor  = Armor(100)