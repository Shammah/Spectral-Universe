namespace Spectral.Graphics

import System

interface IRenderable:
"""Things that can be rendered on the screen."""
    
    def Render()
    """Renders the renderable using the current OpenGL context."""