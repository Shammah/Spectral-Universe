namespace Spectral.Graphics.Vertices

import System
import OpenTK
import OpenTK.Graphics
import OpenTK.Graphics.OpenGL

struct VertexNormalColor(IVertex):
"""A vertex which has a normal and color."""

    def constructor(p as Vector3):
    """
    Constructor.
    Param p: Position vector.
    """
        pos     = p
        normal  = p
        color   = Color4(1, 1, 1, 1)

    def constructor(p as Vector3, n as Vector3):
    """
    Constructor.
    Param p: Position vector.
    Param n: Normal vector.
    """
        pos     = p
        normal  = n
        color   = Color4(1, 1, 1, 1)

    def constructor(p as Vector3, n as Vector3, c as Color4):
    """
    Constructor.
    Param p: Position vector.
    Param n: Normal vector.
    Param c: Color vector (Note, values are floating point in the range [0, 1]).
    """
        pos     = p
        normal  = n
        color   = c

    Attributes as (Tuple[of uint, uint, VertexAttribPointerType]):
    """
    Returns an array of all attributes the vertex hold.
    Each attribute is represented as a Tuple, consisting of an offset in the data pointer, together with its type.
    """
        get:
            p = Tuple[of uint, uint, VertexAttribPointerType](0                  , 3, VertexAttribPointerType.Float)
            n = Tuple[of uint, uint, VertexAttribPointerType](sizeof(Vector3)    , 3, VertexAttribPointerType.Float)
            c = Tuple[of uint, uint, VertexAttribPointerType](2 * sizeof(Vector3), 3, VertexAttribPointerType.Float)

            return (p, n, c)

    pos as Vector3
    normal as Vector3
    color as Color4