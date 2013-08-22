namespace Spectral.Gwen

import System
import OpenTK.Graphics

class TextRenderer(IDisposable):
    final bmp as System.Drawing.Bitmap
    final gfx as System.Drawing.Graphics
    final texture as Gwen.Texture
    disposed as bool

    Texture as Gwen.Texture:
        get:
            return texture

    def constructor(width as int, height as int, renderer as Renderer):
        if width <= 0:
            raise ArgumentOutOfRangeException("width")

        if height <= 0:
            raise ArgumentOutOfRangeException("height")

        if GraphicsContext.CurrentContext is null:
            raise InvalidOperationException("No GraphicsContext is current on the calling thread.")

        bmp = System.Drawing.Bitmap(width, height, System.Drawing.Imaging.PixelFormat.Format32bppArgb)
        gfx = System.Drawing.Graphics.FromImage(bmp)

        gfx.TextRenderingHint = System.Drawing.Text.TextRenderingHint.AntiAliasGridFit
        gfx.Clear(System.Drawing.Color.Transparent)

        texture = Gwen.Texture(renderer)
        texture.Width = width
        texture.Height = height

    def DrawString(text as string, font as System.Drawing.Font, brush as System.Drawing.Brush, point as System.Drawing.Point, format as System.Drawing.StringFormat):
        gfx.DrawString(text, font, brush, point, format)
        Renderer.LoadTextureInternal(texture, bmp)

    def Dispose(manual as bool):
        if not disposed:
            if manual:
                bmp.Dispose()
                gfx.Dispose()
                texture.Dispose()

            disposed = true

    def Dispose():
        Dispose(true)
        GC.SuppressFinalize(self)