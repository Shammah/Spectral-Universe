namespace Spectral.Physics.Collision

import System
import OpenTK

class BoundingSphere:
"""A volumetric sphere with a position and a radius."""
    
    Position as Vector3:
    """The position of the sphere."""
        get:
            return _position
        set:
            _position = value

    Radius as single:
    """
    The radius of the sphere, which has to be bigger than 0.
    Raises ArgumentException: The radius has to be bigger than 0.
    """
        get:
            return _radius
        set:
            raise ArgumentException("Sphere radius cannot be 0.") if value == 0
            raise ArgumentException("Sphere radius cannot be negative.") if value < 0

            _radius = value

    private _position as Vector3
    private _radius as single

    static def op_BitwiseAnd(x as BoundingSphere, y as BoundingSphere) as bool:
        return x.CollidesWith(y)

    static def op_Subtraction(x as BoundingSphere, y as BoundingSphere) as single:
        return x.Penetration(y)

    def constructor(sphere as BoundingSphere):
    """Copy Constructor."""
        self(sphere.Position, sphere.Radius)

    def constructor():
    """Constructor."""
        self(Vector3.Zero, 1f)

    def constructor(pos as Vector3):
    """
    Constructor.
    Param pos: The position of the sphere.
    """
        self(pos, 1f)

    def constructor(pos as Vector3, radius as single):
    """
    Constructor.
    Param pos: The position of the sphere.
    Param radius: The radius of the sphere.
    Raises ArgumentException: The radius has to be bigger than 0.
    """
        Position = pos
        Radius = radius

    def CollidesWith(collider as BoundingSphere) as bool:
    """
    Checks whether the current sphere collides with the other sphere.
    Param collider: The 'opponent' to check collision with.
    Returns: Whether both spheres collide or not.
    """
        relative = Position - collider.Position
        return relative.X * relative.X + relative.Y * relative.Y + relative.Z * relative.Z <= (Radius + collider.Radius) * (Radius + collider.Radius)

    def Penetration(collider as BoundingSphere) as single:
    """
    Calculates the penetration distance. If this is 0 or bigger, penetration has occured.
    Param collider: The 'opponent' to check collision with.
    Returns: The penetration distance.
    """
        return (Radius + collider.Radius) - (Position - collider.Position).Length