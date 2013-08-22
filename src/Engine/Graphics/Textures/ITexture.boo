namespace Spectral.Graphics.Textures

import System

interface ITexture(IDisposable):
"""Basic interface for any texture."""

    def Bind()
    """Binds the texture to its target of the current OpenGL context."""