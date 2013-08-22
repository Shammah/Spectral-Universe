namespace Spectral.Actors

import System
import OpenTK
import OpenTK.Graphics

abstract class Light(Actor):
"""General light class, which is an Actor with a light intensity and light color. Can be set as a point light or directional light."""

    Color as Color4:
    """The color that the light will emit. Unsure about the use of the alpha channel, but it will probably have it's use somewhere in the future..."""
        get:
            return _color
        set:
            _color = value

    Intensity as single:
    """
    How bright the light will shine.
    Raises ArgumentException: Intensity can only be greater than or equal to 0.
    """
        get:
            return _intensity
        set:
            raise ArgumentException("Light intensity has to be 0 (off) or positive.") if value < 0
            _intensity = value

    private _color as Color4
    private _intensity as single

    def constructor(light as Light):
    """Copy Constructor."""
        self(light.Name, light.Position, light.Color, light.Intensity)

    def constructor(name as string):
    """
    Constructor.
    Param name: Name of the actor.
    """
        self(name, Vector3.Zero, Color.White, 1)

    def constructor(name as string, pos as Vector3):
    """
    Constructor.
    Param name: Name of the actor.
    Param pos: The position vector in world space coordinates.
    """
        self(name, pos, Color.White, 1)

    def constructor(name as string, pos as Vector3, col as Color4):
    """
    Constructor.
    Param name: Name of the actor.
    Param pos: The position vector in world space coordinates.
    Param col: The color of the light.
    """
        self(name, pos, col, 1)

    def constructor(name as string, pos as Vector3, col as Color4, intensity as int):
    """
    Constructor.
    Param name: Name of the actor.
    Param pos: The position vector in world space coordinates.
    Param col: The color of the light.
    Param intensity: The intensity of the light.
    """
        super(name, pos)
        Color         = col
        Intensity     = intensity