namespace Spectral.PostProcess

import System
import Spectral.Graphics.Textures

abstract class PostProcess(PostProcessFrameBuffer):
"""Skeleton class for any post-process."""
    def Process(texture as Texture2D):
    """
    Process the shader onto a the texture.
    Param texture: The texture to process the shader onto.
    """
        Begin()

        Processing(texture)

        End()

    abstract def Processing(texture as Texture2D):
    """
    The processing of the shader onto the texture.
    Param texture: The texture to process the shader onto.
    """
        pass