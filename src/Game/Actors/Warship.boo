namespace Universe.Actors

import System.Collections.Generic
import Universe.Armory

class Warship(Spaceship):
"""A spaceship that has weapons to shoot with."""

    Weapons as Dictionary[of string, IWeapon]:
    """A dictionary of weapons and there names."""
        get:
            return _weapons

    private _weapons as Dictionary[of string, IWeapon]

    def constructor(name as string, resource as string, program as Spectral.Graphics.Programs.GLProgram):
    """
    Constructs a warship.
    Param name: Name of the actor.
    Param resource: Name of the resource, without extension.
    """
        super(name, resource, program)

        _weapons = Dictionary[of string, IWeapon]()