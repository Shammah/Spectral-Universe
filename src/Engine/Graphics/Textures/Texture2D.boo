namespace Spectral.Graphics.Textures

import System
import System.Drawing
import System.Drawing.Imaging
import OpenTK.Graphics.OpenGL

class Texture2D(Texture):
"""A 2-Dimensional texture for OpenGL."""

    def constructor(path as string):
    """
    Loads a 2D image from file.
    Remarks: Supported formats are BMP, GIF, EXIF, JPG, PNG and TIFF.
    Param path: Path of the image file to load.
    Raises IOException: File could not be found.
    """
        super(TextureTarget.Texture2D)
        bmp as Bitmap         = Bitmap(path)
        bmpData as BitmapData = bmp.LockBits(Rectangle(0, 0, bmp.Width, bmp.Height), ImageLockMode.ReadOnly, bmp.PixelFormat)
        data as IntPtr        = bmpData.Scan0

        Init(bmp.Width, bmp.Height, 0, PixelInternalFormat.Rgba, PixelFormatToGLFormat(bmp.PixelFormat), PixelType.UnsignedByte, data)

        bmp.UnlockBits(bmpData)

    def constructor(width as uint, height as uint,
                    levels as uint, iFormat as PixelInternalFormat,
                    format as OpenTK.Graphics.OpenGL.PixelFormat, type as PixelType, data as IntPtr):
    """
    Creates an instance of a 2D Texture.
    Param width: The width of the texture in pixels.
    Param height: The height of the texture in pixels.
    Param levels: The number of levels of mipmapping.
    Param iFormat: The internal format of the data in OpenGL.
    Param format: The format the bytes of data is organized into.
    Param type: The type of data each pixel data is build of, eg double, short etc.
    Param data: Pointer to the data itself.
    """
        super(TextureTarget.Texture2D)
        Init(width, height, levels, iFormat, format, type, data)

    private def Init(width as uint, height as uint,
                    levels as uint, iFormat as PixelInternalFormat,
                    format as OpenTK.Graphics.OpenGL.PixelFormat, type as PixelType, data as IntPtr):
    """
    Intializes the texture class.
    Param width: The width of the texture in pixels.
    Param height: The height of the texture in pixels.
    Param levels: The number of levels of mipmapping.
    Param iFormat: The internal format of the data in OpenGL.
    Param format: The format the bytes of data is organized into.
    Param type: The type of data each pixel data is build of, eg double, short etc.
    Param data: Pointer to the data itself.
    """
        oldTex as int
        GL.GetInteger(GetPName.TextureBinding2D, oldTex)
        GL.BindTexture(Target, Handle)

        GL.TexImage2D(Target, levels, iFormat, width, height, 0, format, type, data)

        SetParameter(TextureParameterName.TextureMinFilter, TextureMinFilter.Linear)
        SetParameter(TextureParameterName.TextureMagFilter, TextureMagFilter.Linear)
        SetParameter(TextureParameterName.TextureWrapS, TextureWrapMode.Clamp)
        SetParameter(TextureParameterName.TextureWrapT, TextureWrapMode.Clamp)

        GL.BindTexture(Target, oldTex)