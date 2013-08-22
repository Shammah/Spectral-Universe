namespace Spectral.Physics.Collision

import System
import OpenTK

class BoundingBox:
"""Oriented Bounding Boxes (3D volumetric boxes, aka cubes)."""

    Width as single:
    """
    Returns or sets the width of the bounding box.
    Raises ArgumentException: Value has to be bigger than 0.
    """
        get:
            return _width * 2f
        set:
            raise ArgumentException("Width must be bigger than 0.") if value <= 0
            _width = value / 2f

    Height as single:
    """
    Returns or sets the height of the bounding box.
    Raises ArgumentException: Value has to be bigger than 0.
    """
        get:
            return _height * 2f
        set:
            raise ArgumentException("Height must be bigger than 0.") if value <= 0
            _height = value / 2f

    Depth as single:
    """
    Returns or sets the depth of the bounding box.
    Raises ArgumentException: Value has to be bigger than 0.
    """
        get:
            return _depth * 2f
        set:
            raise ArgumentException("Depth must be bigger than 0.") if value <= 0
            _depth = value / 2f

    HalfWidth as single:
    """
    Returns or sets the half width of the bounding box.
    Raises ArgumentException: Value has to be bigger than 0.
    """
        get:
            return _width
        set:
            raise ArgumentException("Width must be bigger than 0.") if value <= 0
            _width = value

    HalfHeight as single:
    """
    Returns or sets the half height of the bounding box.
    Raises ArgumentException: Value has to be bigger than 0.
    """
        get:
            return _height
        set:
            raise ArgumentException("Height must be bigger than 0.") if value <= 0
            _height = value

    HalfDepth as single:
    """
    Returns or sets the half depth of the bounding box.
    Raises ArgumentException: Value has to be bigger than 0.
    """
        get:
            return _depth
        set:
            raise ArgumentException("Depth must be bigger than 0.") if value <= 0
            _depth = value

    Position as Vector3:
    """Returns or sets the center position of the bounding box."""
        get:
            return _pos
        set:
            _pos = value

    Orientation as Quaternion:
    """Returns or sets the orientation of the bounding box."""
        get:
            return _orient
        set:
            _orient = value

    # These 3 lengths are half-width/height/depths.
    private _width as single
    private _height as single
    private _depth as single

    private _pos as Vector3
    private _orient as Quaternion

    static def op_BitwiseAnd(x as BoundingBox, y as BoundingBox) as bool:
        return x.CollidesWith(y)

    def constructor(box as BoundingBox):
    """Copy Constructor."""
        self(box.Position, box.Width, box.Height, box.Depth, box.Orientation)

    def constructor():
    """Constructor."""
        self(Vector3.Zero, 1, 1, 1)

    def constructor(pos as Vector3, width as single, height as single, depth as single):
    """
    Constructor.
    Param pos: Position (center) of the box in world-space coordinates.
    Param width: The total width of the box.
    Param height: The total height of the box.
    Param depth: The total depth of the box.
    Raises ArgumentException: Width, height and depth all have to be bigger than 0.
    """
        self(pos, width, height, depth, Quaternion.Identity)

    def constructor(pos as Vector3, width as single, height as single, depth as single, orient as Quaternion):
    """
    Constructor.
    Param pos: Position (center) of the box in world-space coordinates.
    Param width: The total width of the box.
    Param height: The total height of the box.
    Param depth: The total depth of the box.
    Param orient: The rotiation, or orientation of the box as a Quaternion.
    Raises ArgumentException: Width, height and depth all have to be bigger than 0.
    """
        Position    = pos
        Orientation = orient

        Width      = width
        Height     = height
        Depth      = depth

    def CollidesWith(c as BoundingBox) as bool:
    """
    Checks whether the current box collides with the other box.
    Remark: This is done by using a special case of the SAT theorem.
    Param c: The 'opponent' to check collision with.
    Returns: Whether both boxes collide or not.
    """
        # Get all vertices for the first box.
        verticesA       = ComputeVertices(self)

        # Get the vertices for the box we are comparing with, our collider c.
        verticesB       = ComputeVertices(c)

        # Calculate the edges needed for the projection.
        edgesA          = array(Vector3, 3)
        edgesA[0]       = verticesA[1] - verticesA[0]
        edgesA[1]       = verticesA[2] - verticesA[0]
        edgesA[2]       = verticesA[3] - verticesA[0]

        edgesB          = array(Vector3, 3)
        edgesB[0]       = verticesB[1] - verticesB[0]
        edgesB[1]       = verticesB[2] - verticesB[0]
        edgesB[2]       = verticesB[3] - verticesB[0]

        # Test faces.
        return false if IsSeparationAxis(verticesA, verticesB, Vector3.Normalize(Vector3.Cross(edgesA[1], edgesA[0]))) # Test Face A-To-Right
        return false if IsSeparationAxis(verticesA, verticesB, Vector3.Normalize(Vector3.Cross(edgesA[2], edgesA[1]))) # Test Face A-To-Front
        return false if IsSeparationAxis(verticesA, verticesB, Vector3.Normalize(Vector3.Cross(edgesA[0], edgesA[2]))) # Test Face A-To-Top

        return false if IsSeparationAxis(verticesA, verticesB, Vector3.Normalize(Vector3.Cross(edgesB[1], edgesB[0]))) # Test Face B-To-Right
        return false if IsSeparationAxis(verticesA, verticesB, Vector3.Normalize(Vector3.Cross(edgesB[2], edgesB[1]))) # Test Face B-To-Front
        return false if IsSeparationAxis(verticesA, verticesB, Vector3.Normalize(Vector3.Cross(edgesB[0], edgesB[2]))) # Test Face B-To-Top

        # Test edges.
        return false if IsSeparationAxis(verticesA, verticesB, Vector3.Normalize(Vector3.Cross(edgesA[0], edgesB[0]))) # Test A0 x B0
        return false if IsSeparationAxis(verticesA, verticesB, Vector3.Normalize(Vector3.Cross(edgesA[0], edgesB[1]))) # Test A0 x B1
        return false if IsSeparationAxis(verticesA, verticesB, Vector3.Normalize(Vector3.Cross(edgesA[0], edgesB[2]))) # Test A0 x B2

        return false if IsSeparationAxis(verticesA, verticesB, Vector3.Normalize(Vector3.Cross(edgesA[1], edgesB[0]))) # Test A1 x B0
        return false if IsSeparationAxis(verticesA, verticesB, Vector3.Normalize(Vector3.Cross(edgesA[1], edgesB[1]))) # Test A1 x B1
        return false if IsSeparationAxis(verticesA, verticesB, Vector3.Normalize(Vector3.Cross(edgesA[1], edgesB[2]))) # Test A1 x B2

        return false if IsSeparationAxis(verticesA, verticesB, Vector3.Normalize(Vector3.Cross(edgesA[2], edgesB[0]))) # Test A2 x B0
        return false if IsSeparationAxis(verticesA, verticesB, Vector3.Normalize(Vector3.Cross(edgesA[2], edgesB[1]))) # Test A2 x B1
        return false if IsSeparationAxis(verticesA, verticesB, Vector3.Normalize(Vector3.Cross(edgesA[2], edgesB[2]))) # Test A2 x B2

        return true

    protected def IsSeparationAxis(ref verticesA as (Vector3), ref verticesB as (Vector3), axis as Vector3):
    """
    Checks whether axis is a seperation axis between two bounding boxes.
    Param verticesA: The vectors of box A.
    Param verticesB: The vectors of box B.
    Param axis: The seperation axis to test.
    Returns: True if axis is a seperation axis.
    Remarks: We assume the axis is normalized. I have no idea what happens if it isn't.
    """
        projectionA = Project(verticesA, axis)
        projectionB = Project(verticesB, axis)

        return true unless Overlap(projectionA, projectionB)
        return false

    protected def Project(ref vertices as (Vector3), axis as Vector3):
    """
    Returns the projection of a geometric model onto the axis.
    Param vertices: Array of vertices of the model to project.
    Param axis: The axis to project the vertices on.
    Remarks: We assume the axis is normalized. I have no idea what happens if it isn't.
    """
        min = max = Vector3.Dot(vertices[0], axis)

        for i in range(1, vertices.Length):
            dot = Vector3.Dot(vertices[i], axis)

            if dot < min:
                min = dot
            elif dot > max:
                max = dot

        return Vector2(min, max)

    protected def Overlap(ref a as Vector2, ref b as Vector2):
    """
    Returns whether the two vectors overlap.
    Remarks: We assume the two vectors lie on the same axis.
    Param a: The left projection.
    Param b: The right projection.
    """
        return true if (a.X >= b.X and a.X <= b.Y) or (a.Y >= b.X and a.Y <= b.Y) or (b.X >= a.X and b.X <= a.Y) or (b.Y >= a.X and b.Y <= a.Y)
        return false

    def ComputeVertices(box as BoundingBox):
    """Computes the vertices for a bounding box in world-space. See bounding_box.png to see what index corresponds to what vertex."""
        vertices       = array(Vector3, 8)

        vertices[0]    = Vector3.Transform(Vector3( box.HalfWidth,  box.HalfHeight,  box.HalfDepth), box.Orientation) + box.Position
        vertices[1]    = Vector3.Transform(Vector3( box.HalfWidth,  box.HalfHeight, -box.HalfDepth), box.Orientation) + box.Position
        vertices[2]    = Vector3.Transform(Vector3( box.HalfWidth, -box.HalfHeight,  box.HalfDepth), box.Orientation) + box.Position
        vertices[3]    = Vector3.Transform(Vector3(-box.HalfWidth,  box.HalfHeight,  box.HalfDepth), box.Orientation) + box.Position
        vertices[4]    = Vector3.Transform(Vector3(-box.HalfWidth, -box.HalfHeight, -box.HalfDepth), box.Orientation) + box.Position
        vertices[5]    = Vector3.Transform(Vector3(-box.HalfWidth, -box.HalfHeight,  box.HalfDepth), box.Orientation) + box.Position
        vertices[6]    = Vector3.Transform(Vector3(-box.HalfWidth,  box.HalfHeight, -box.HalfDepth), box.Orientation) + box.Position
        vertices[7]    = Vector3.Transform(Vector3( box.HalfWidth, -box.HalfHeight, -box.HalfDepth), box.Orientation) + box.Position

        return vertices