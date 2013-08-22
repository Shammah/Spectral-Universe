namespace Spectral.Graphics

import System
import Spectral.Graphics.Textures
import Spectral.Graphics.Programs

interface IModel(IDisposable, IRenderable):
"""Common interface any 3D model should have."""

    Texture as ITexture:
    """A model may have a texture."""
        get
        set

    Program as GLProgram:
    """A model may have a program."""
        get
        set