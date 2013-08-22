namespace Spectral.Graphics.Vertices

import System
import OpenTK
import OpenTK.Graphics.OpenGL

struct VertexNormal1D(IVertex):
"""A vertex which has a normal and 1D texture coordinate."""

    def constructor(p as Vector3):
    """
    Constructor.
    Param p: Position vector.
    """
        pos     = p
        normal  = p
        color   = 0.0f

    def constructor(p as Vector3, n as Vector3):
    """
    Constructor.
    Param p: Position vector.
    Param n: Normal vector.
    """
        pos     = p
        normal  = n
        color   = 0.0f

    def constructor(p as Vector3, n as Vector3, c as single):
    """
    Constructor.
    Param p: Position vector.
    Param n: Normal vector.
    Param c: 1D Texture coordinate.
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
            p = Tuple[of uint, uint, VertexAttribPointerType](0                  ,  3, VertexAttribPointerType.Float)
            n = Tuple[of uint, uint, VertexAttribPointerType](sizeof(Vector3)    ,  3, VertexAttribPointerType.Float)
            c = Tuple[of uint, uint, VertexAttribPointerType](sizeof(Vector3) * 2,  1, VertexAttribPointerType.Float)

            return (p, n, c)

    pos as Vector3
    normal as Vector3
    color as single