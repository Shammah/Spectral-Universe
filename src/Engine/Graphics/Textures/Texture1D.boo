namespace Spectral.Graphics.Textures

import System
import System.Drawing
import System.Drawing.Imaging
import OpenTK.Graphics.OpenGL

class Texture1D(Texture):
"""A 1-Dimensional texture for OpenGL."""

    def constructor(path as string):
    """
    Loads a 1D image from file.
    Remarks: Supported formats are BMP, GIF, EXIF, JPG, PNG and TIFF.
    Param path: Path of the image file to load.
    Raises IOException: File could not be found.
    Todo: Fix pixel format, RGB when it should be BGR?
    """
        super(TextureTarget.Texture1D)
        bmp as Bitmap         = Bitmap(path)
        bmpData as BitmapData = bmp.LockBits(Rectangle(0, 0, bmp.Width, 1), ImageLockMode.ReadOnly, bmp.PixelFormat)
        data as IntPtr        = bmpData.Scan0

        Init(bmp.Width, 0, PixelInternalFormat.Rgba, OpenTK.Graphics.OpenGL.PixelFormat.Bgr, PixelType.UnsignedByte, data)

        bmp.UnlockBits(bmpData)

    def constructor(width as uint, levels as uint, iFormat as PixelInternalFormat,
                    format as OpenTK.Graphics.OpenGL.PixelFormat, type as PixelType, data as IntPtr):
    """
    Creates an instance of a 1D Texture.
    Param width: The width of the texture in pixels.
    Param levels: The number of levels of mipmapping.
    Param iFormat: The internal format of the data in OpenGL.
    Param format: The format the bytes of data is organized into.
    Param type: The type of data each pixel data is build of, eg double, short etc.
    Param data: Pointer to the data itself.
    """
        super(TextureTarget.Texture1D)
        Init(width, levels, iFormat, format, type, data)

    private def Init(width as uint, levels as uint, iFormat as PixelInternalFormat,
                    format as OpenTK.Graphics.OpenGL.PixelFormat, type as PixelType, data as IntPtr):
    """
    Intializes the texture class.
    Param width: The width of the texture in pixels.
    Param levels: The number of levels of mipmapping.
    Param iFormat: The internal format of the data in OpenGL.
    Param format: The format the bytes of data is organized into.
    Param type: The type of data each pixel data is build of, eg double, short etc.
    Param data: Pointer to the data itself.
    """
        oldTex as int
        GL.GetInteger(GetPName.TextureBinding1D, oldTex)
        GL.BindTexture(Target, Handle)

        GL.TexImage1D(Target, levels, iFormat, width, 0, format, type, data)

        SetParameter(TextureParameterName.TextureMinFilter, TextureMinFilter.Linear)
        SetParameter(TextureParameterName.TextureMagFilter, TextureMagFilter.Linear)
        SetParameter(TextureParameterName.TextureWrapS, TextureWrapMode.Clamp)
        SetParameter(TextureParameterName.TextureWrapT, TextureWrapMode.Clamp)

        GL.BindTexture(Target, oldTex)