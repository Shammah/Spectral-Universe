namespace Spectral.Graphics.Vertices

import System
import OpenTK.Graphics.OpenGL

interface IVertex():
"""Basic interface for any vertex."""

    Attributes as (Tuple[of uint, uint, VertexAttribPointerType]):
    """
    Returns an array of all attributes the vertex hold.
    Each attribute is represented as a Tuple, consisting of an offset in the data pointer, together with its amount of elements and element type.

    Item1 = offset
    Item2 = amount
    Item3 = type
    """
        get