namespace Spectral.Actors

import System
import OpenTK
import OpenTK.Graphics

class PointLight(Light):
"""
A general point light, that emits light in all direction from a given point. Can be seen as sunlight.
Todo: Directional light uses its position as replacer for the direction. Switch this to orientation instead.
"""

    Directional as bool:
    """
    Whether the light is at a certain point in space, or is considered directional (eg, like the sun).
    Remarks: If this is set to true, the position will be considered as the place of where the 'sun' is in a sphere with diameter 1.
    """
        get:
            return _directional
        set:
            _directional = value

    private _directional as bool

    def constructor(light as PointLight):
    """Copy Constructor."""
        self(light.Name, light.Position, light.Color, light.Intensity, light.Directional)

    def constructor(name as string):
    """
    Constructor.
    Param name: Name of the actor.
    """
        self(name, Vector3.Zero, Color.White, 1, false)

    def constructor(name as string, pos as Vector3):
    """
    Constructor.
    Param name: Name of the actor.
    Param pos: The position vector in world space coordinates.
    """
        self(name, pos, Color.White, 1, false)

    def constructor(name as string, pos as Vector3, col as Color4):
    """
    Constructor.
    Param name: Name of the actor.
    Param pos: The position vector in world space coordinates.
    Param col: The color of the light.
    """
        self(name, pos, col, 1, false)

    def constructor(name as string, pos as Vector3, col as Color4, intensity as int):
    """
    Constructor.
    Param name: Name of the actor.
    Param pos: The position vector in world space coordinates.
    Param col: The color of the light.
    Param intensity: The intensity of the light.
    """
        self(name, pos, col, intensity, false)

    def constructor(name as string, pos as Vector3, col as Color4, intensity as int, dir as bool):
    """
    Constructor.
    Param name: Name of the actor.
    Param pos: The position vector in world space coordinates.
    Param col: The color of the light.
    Param intensity: The intensity of the light.
    Param dir Whether the light is just a directional light like the sun, or a fixed point light like a lamp.
    """
        super(name, pos, col, intensity)
        Directional = dir