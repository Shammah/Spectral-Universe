namespace Spectral.Graphics.Textures

import System
import OpenTK.Graphics.OpenGL
import Boo.Lang.PatternMatching

abstract class Texture(ITexture):
"""Basic interface class for any OpenGL texture."""

    Handle as uint:
    """Return the texture ID as allocated by OpenGL."""
        get:
            return _texture

    Target as TextureTarget:
    """Returns the target, or type on which the texture will be rendered to / as."""
        get:
            return _textureTarget

    private _texture as int
    private _textureTarget as TextureTarget

    protected _disposed as bool

    def constructor(tt as TextureTarget):
    """
    Constructor.
    Param tt: The target, or type on which the texture will be render to / as.
    """
        GL.GenTextures(1, _texture)
        _textureTarget  = tt
        _disposed       = false

    virtual def Bind():
    """Binds the texture to its target of the current OpenGL context."""
        GL.BindTexture(Target, Handle)

    virtual def BindZero():
    """Binds 0 to texture target allocated to this texture."""
        GL.BindTexture(Target, 0)

    virtual def Dispose():
    """Delete the texture from memory."""
        return if _disposed

        GL.DeleteTextures(1, _texture)

        _disposed = true

    virtual def SetParameter(parameter as TextureParameterName, val as int):
    """
    Sets a parameter for the texture.
    Param parameter: The parameter to set.
    Param val: The value of the parameter.
    """
        GL.TexParameter(Target, parameter, val)

    static public def PixelFormatToGLFormat(format as System.Drawing.Imaging.PixelFormat) as PixelFormat:
    """
    Transforms the .NET PixelFormat class into a format usable by OpenGL.
    Param format: The .NET PixelFormat to convert.
    """
        match format:
            case System.Drawing.Imaging.PixelFormat.Indexed:
                return PixelFormat.ColorIndex

            case System.Drawing.Imaging.PixelFormat.Canonical:
                return PixelFormat.Rgba

            case System.Drawing.Imaging.PixelFormat.Alpha:
                return PixelFormat.Alpha

            case System.Drawing.Imaging.PixelFormat.PAlpha:
                return PixelFormat.Alpha

            case System.Drawing.Imaging.PixelFormat.Format1bppIndexed:
                return PixelFormat.ColorIndex

            case System.Drawing.Imaging.PixelFormat.Format4bppIndexed:
                return PixelFormat.ColorIndex

            case System.Drawing.Imaging.PixelFormat.Format8bppIndexed:
                return PixelFormat.ColorIndex

            case System.Drawing.Imaging.PixelFormat.Format16bppRgb555:
                return PixelFormat.Rgb

            case System.Drawing.Imaging.PixelFormat.Format16bppRgb565:
                return PixelFormat.Rgb

            case System.Drawing.Imaging.PixelFormat.Format16bppArgb1555:
                return PixelFormat.Rgba

            case System.Drawing.Imaging.PixelFormat.Format24bppRgb:
                return PixelFormat.Rgb

            case System.Drawing.Imaging.PixelFormat.Format32bppRgb:
                return PixelFormat.Rgb

            case System.Drawing.Imaging.PixelFormat.Format32bppArgb:
                return PixelFormat.Rgba

            case System.Drawing.Imaging.PixelFormat.Format32bppPArgb:
                return PixelFormat.Rgba

            case System.Drawing.Imaging.PixelFormat.Format48bppRgb:
                return PixelFormat.Rgb

            case System.Drawing.Imaging.PixelFormat.Format64bppArgb:
                return PixelFormat.Rgba

            case System.Drawing.Imaging.PixelFormat.Format64bppPArgb:
                return PixelFormat.Rgba

            otherwise:
                return PixelFormat.Rgba