// Somehow this places Nant in an infinite loop?
namespace Spectral.Gwen

import System

import System.Runtime.InteropServices
import System.Collections.Generic
import OpenTK.Graphics.OpenGL
import Boo.Lang.PatternMatching

class Renderer(Gwen.Renderer.Base):
    [StructLayout(LayoutKind.Sequential, Pack: 1)]
    struct Vertex:
        x as short
        y as short

        u as single
        v as single

        r as byte
        g as byte
        b as byte
        a as byte

        def ToString():
            return "($x, $y), ($u, $v), ($r, $g, $b, $a)"

    struct FontString:
        def constructor(str as string, f as Gwen.Font):
            String  = str
            Font     = f

        String as string
        Font as Gwen.Font

    TextCacheSize as int:
        get:
            return m_StringCache.Count

    DrawCallCount as int:
        get:
            return m_DrawCallCount

    VertexCount as int:
        get:
            return m_VertNum

    Program as GwenProgram:
        get:
            return m_Program

    override DrawColor as System.Drawing.Color:
        get:
            return m_Color
        set:
            m_Color = value

    private static final MaxVerts as int = 1024
    private m_Color as System.Drawing.Color
    private m_VertNum as int
    private final m_Vertices as (Vertex)
    private final m_VertexSize as int

    private final m_StringCache as Dictionary[of FontString, TextRenderer]
    private final m_Graphics as System.Drawing.Graphics
    private m_DrawCallCount as int
    private m_ClipEnabled as bool
    private m_TextureEnabled as bool
    private static m_LastTextureID as int

    private m_WasBlendEnabled as bool
    private m_WasDepthTestEnabled as bool
    private m_WasCullingEnabled as bool

    private m_PrevBlendSrc as int
    private m_PrevBlendDst as int
    private m_PrevAlphaFunc as int
    private m_PrevAlphaRef as single
    private m_RestoreRenderState as bool

    private m_StringFormat as System.Drawing.StringFormat

    // OpenGL
    private m_Buffers as (uint)
    private m_Program as GwenProgram
    private m_VAO as (uint)

    def constructor(restoreRenderState as bool):
        super()

        m_Vertices                     = array(Vertex, MaxVerts)
        m_VertexSize                 = Marshal.SizeOf(m_Vertices[0])
        m_StringCache                 = Dictionary[of FontString, TextRenderer]()
        m_Graphics                     = System.Drawing.Graphics.FromImage(System.Drawing.Bitmap(1024, 1024, System.Drawing.Imaging.PixelFormat.Format32bppArgb))
        m_StringFormat                 = System.Drawing.StringFormat(System.Drawing.StringFormat.GenericTypographic)
        m_StringFormat.FormatFlags |= System.Drawing.StringFormatFlags.MeasureTrailingSpaces
        m_RestoreRenderState         = restoreRenderState

        // OpenGL 3.2
        m_Buffers = array(uint, 1)
        GL.GenBuffers(1, m_Buffers)

        m_VAO = array(uint, 1)
        GL.GenVertexArrays(1, m_VAO)
        GL.BindVertexArray(m_VAO[0])

        GL.BindBuffer(BufferTarget.ArrayBuffer, m_Buffers[0])
        GL.BufferData(BufferTarget.ArrayBuffer, IntPtr(sizeof(Vertex) * MaxVerts), IntPtr.Zero, BufferUsageHint.StreamDraw)

        GL.EnableVertexAttribArray(0)
        GL.EnableVertexAttribArray(1)
        GL.EnableVertexAttribArray(2)

        GL.VertexAttribPointer(0, 2, VertexAttribPointerType.Short, false, sizeof(Vertex), 0)
        GL.VertexAttribPointer(1, 4, VertexAttribPointerType.UnsignedByte, true, sizeof(Vertex), 2 * (sizeof(short) + sizeof(single)))
        GL.VertexAttribPointer(2, 2, VertexAttribPointerType.Float, false, sizeof(Vertex), 2 * sizeof(short))

        GL.BindVertexArray(0)

        m_Program = GwenProgram()

    override def Dispose():
        FlushTextCache()
        GL.DeleteBuffers(1, m_Buffers)
        GL.DeleteVertexArrays(1, m_VAO)
        m_Program.Dispose()
        super.Dispose()

    override def Begin():
        if (m_RestoreRenderState):
            GL.GetInteger(GetPName.BlendSrc, m_PrevBlendSrc)
            GL.GetInteger(GetPName.BlendDst, m_PrevBlendDst)
            GL.GetInteger(GetPName.AlphaTestFunc, m_PrevAlphaFunc)
            GL.GetFloat(GetPName.AlphaTestRef, m_PrevAlphaRef)

            m_WasBlendEnabled         = GL.IsEnabled(EnableCap.Blend)
            m_WasDepthTestEnabled     = GL.IsEnabled(EnableCap.DepthTest)
            m_WasCullingEnabled        = GL.IsEnabled(EnableCap.CullFace)

        // Set default values and enable/disable caps.
        GL.BlendFunc(BlendingFactorSrc.SrcAlpha, BlendingFactorDest.OneMinusSrcAlpha)
        GL.AlphaFunc(AlphaFunction.Greater, 1.0f)
        GL.Enable(EnableCap.Blend)
        GL.Disable(EnableCap.DepthTest)
        GL.Disable(EnableCap.CullFace)

        m_VertNum             = 0
        m_DrawCallCount        = 0
        m_ClipEnabled         = false
        m_TextureEnabled     = false
        m_LastTextureID     = -1

        m_Program.Use()

    override def End():
        Flush()

        if m_RestoreRenderState:
            GL.BindTexture(TextureTarget.Texture2D, 0);

            // Restore the previous parameter values.
            GL.BlendFunc(m_PrevBlendSrc cast BlendingFactorSrc, m_PrevBlendDst cast BlendingFactorDest)
            GL.AlphaFunc(m_PrevAlphaFunc cast AlphaFunction, m_PrevAlphaRef)

            if not m_WasBlendEnabled:
                GL.Disable(EnableCap.Blend)

            if m_WasDepthTestEnabled:
                GL.Enable(EnableCap.DepthTest)

            if m_WasCullingEnabled:
                GL.Enable(EnableCap.CullFace)

        GL.UseProgram(0)

    def FlushTextCache():
        for textRenderer in m_StringCache.Values:
            textRenderer.Dispose()

        m_StringCache.Clear()

    def Flush():
        if m_VertNum == 0:
            return

        GL.BindVertexArray(m_VAO[0])
        GL.BufferSubData(BufferTarget.ArrayBuffer, IntPtr.Zero, IntPtr(sizeof(Vertex) * m_VertNum), m_Vertices)

        GL.DrawArrays(BeginMode.Quads, 0, m_VertNum)

        GL.BindVertexArray(0)

        m_DrawCallCount++
        m_VertNum = 0

    override def DrawFilledRect(rect as System.Drawing.Rectangle):
        if m_TextureEnabled:
            Flush()
            m_TextureEnabled = false
            m_Program.Textured(false)

        rect = Translate(rect)

        DrawRect(rect, 0, 0, 1, 1)

    override def StartClip():
        m_ClipEnabled = true

    override def EndClip():
        m_ClipEnabled = false

    def DrawTexturedRect(t as Gwen.Texture, rect as System.Drawing.Rectangle):
        DrawTexturedRect(t, rect, 0, 0, 1, 1)

    def DrawTexturedRect(t as Gwen.Texture, rect as System.Drawing.Rectangle, u1 as single):
        DrawTexturedRect(t, rect, u1, 0, 1, 1)

    def DrawTexturedRect(t as Gwen.Texture, rect as System.Drawing.Rectangle, u1 as single, v1 as single):
        DrawTexturedRect(t, rect, u1, v1, 1, 1)

    def DrawTexturedRect(t as Gwen.Texture, rect as System.Drawing.Rectangle, u1 as single, v1 as single, u2 as single):
        DrawTexturedRect(t, rect, u1, v1, u2, 1)

    override def DrawTexturedRect(t as Gwen.Texture, rect as System.Drawing.Rectangle, u1 as single, v1 as single, u2 as single, v2 as single):
        if t.RendererData is null:
            DrawMissingImage(rect)
            return

        tex as int = t.RendererData cast int
        rect = Translate(rect)

        differentTexture as bool = tex != m_LastTextureID
        if (not m_TextureEnabled) or differentTexture:
            Flush()

        unless m_TextureEnabled:
            m_TextureEnabled = true
            m_Program.Textured(true)

        if differentTexture:
            GL.BindTexture(TextureTarget.Texture2D, tex)
            m_LastTextureID = tex

        DrawRect(rect, u1, v1, u2, v2)

    private def DrawRect(rect as System.Drawing.Rectangle, u1 as single, v1 as single, u2 as single, v2 as single):
        if m_VertNum + 4 >= MaxVerts:
            Flush()

        if m_ClipEnabled:
            oldHeight as int
            delta as int
            du as single
            dv as single

            if rect.Y < ClipRegion.Y:
                oldHeight     = rect.Height
                delta          = ClipRegion.Y - rect.Y
                rect.Y         = ClipRegion.Y
                rect.Height -= delta

                if rect.Height <= 0:
                    return

                dv  = delta cast single / oldHeight cast single
                v1 += dv * (v2 - v1)

            if (rect.Y + rect.Height) > (ClipRegion.Y + ClipRegion.Height):
                oldHeight     = rect.Height
                delta         = (rect.Y + rect.Height) - (ClipRegion.Y + ClipRegion.Height)
                rect.Height -= delta

                if rect.Height <= 0:
                    return

                dv  = delta cast single / oldHeight cast single
                v2 -= dv * (v2 - v1)

            if rect.X < ClipRegion.X:
                oldWidth     = rect.Width
                delta         = ClipRegion.X - rect.X
                rect.X         = ClipRegion.X
                rect.Width -= delta

                if rect.Width <= 0:
                    return

                du  = delta cast single / oldWidth cast single
                u1 += du * (u2 - u1)

            if (rect.X + rect.Width) > (ClipRegion.X + ClipRegion.Width):
                oldWidth    = rect.Width
                delta         = (rect.X + rect.Width) - (ClipRegion.X + ClipRegion.Width)
                rect.Width -= delta

                if rect.Width <= 0:
                    return

                du  = delta cast single / oldWidth cast single
                u2 -= du * (u2 - u1)

        vertexIndex as int = m_VertNum
        m_Vertices[vertexIndex].x = rect.X cast short
        m_Vertices[vertexIndex].y = rect.Y cast short
        m_Vertices[vertexIndex].u = u1
        m_Vertices[vertexIndex].v = v1
        m_Vertices[vertexIndex].r = m_Color.R
        m_Vertices[vertexIndex].g = m_Color.G
        m_Vertices[vertexIndex].b = m_Color.B
        m_Vertices[vertexIndex].a = m_Color.A

        vertexIndex++
        m_Vertices[vertexIndex].x = (rect.X + rect.Width) cast short
        m_Vertices[vertexIndex].y = rect.Y cast short
        m_Vertices[vertexIndex].u = u2
        m_Vertices[vertexIndex].v = v1
        m_Vertices[vertexIndex].r = m_Color.R
        m_Vertices[vertexIndex].g = m_Color.G
        m_Vertices[vertexIndex].b = m_Color.B
        m_Vertices[vertexIndex].a = m_Color.A

        vertexIndex++
        m_Vertices[vertexIndex].x = (rect.X + rect.Width) cast short
        m_Vertices[vertexIndex].y = (rect.Y + rect.Height) cast short
        m_Vertices[vertexIndex].u = u2
        m_Vertices[vertexIndex].v = v2
        m_Vertices[vertexIndex].r = m_Color.R
        m_Vertices[vertexIndex].g = m_Color.G
        m_Vertices[vertexIndex].b = m_Color.B
        m_Vertices[vertexIndex].a = m_Color.A

        vertexIndex++
        m_Vertices[vertexIndex].x = rect.X cast short
        m_Vertices[vertexIndex].y = (rect.Y + rect.Height) cast short
        m_Vertices[vertexIndex].u = u1
        m_Vertices[vertexIndex].v = v2
        m_Vertices[vertexIndex].r = m_Color.R
        m_Vertices[vertexIndex].g = m_Color.G
        m_Vertices[vertexIndex].b = m_Color.B
        m_Vertices[vertexIndex].a = m_Color.A

        m_VertNum += 4

    override def LoadFont(font as Gwen.Font) as bool:
        font.RealSize = font.Size * Scale
        sysFont as System.Drawing.Font = font.RendererData cast System.Drawing.Font

        if sysFont is not null:
            sysFont.Dispose()

        sysFont = System.Drawing.Font(font.FaceName, font.Size)
        font.RendererData = sysFont

        return true

    override def FreeFont(font as Gwen.Font):
        if font.RendererData is null:
            return

        sysFont as System.Drawing.Font = font.RendererData cast System.Drawing.Font
        if sysFont is null:
            raise InvalidOperationException("Freeing empty font.")

        sysFont.Dispose()
        font.RendererData = null

    override def MeasureText(font as Gwen.Font, text as string) as System.Drawing.Point:
        sysFont as System.Drawing.Font = font.RendererData cast System.Drawing.Font

        if sysFont is null or Math.Abs(font.RealSize - font.Size * Scale) > 2:
            FreeFont(font)
            LoadFont(font)
            sysFont = font.RendererData cast System.Drawing.Font

        key as FontString = FontString(text, font)

        if m_StringCache.ContainsKey(key):
            tex = m_StringCache[key].Texture
            return System.Drawing.Point(tex.Width, tex.Height)

        size as System.Drawing.SizeF = m_Graphics.MeasureString(text, sysFont, System.Drawing.Point.Empty, m_StringFormat)
        return System.Drawing.Point(Math.Round(size.Width) cast int, Math.Round(size.Height) cast int)

    override def RenderText(font as Gwen.Font, position as System.Drawing.Point, text as string):
        Flush()

        sysFont as System.Drawing.Font = font.RendererData cast System.Drawing.Font

        if sysFont is null or Math.Abs(font.RealSize - font.Size * Scale) > 2:
            FreeFont(font)
            LoadFont(font)
            sysFont = font.RendererData cast System.Drawing.Font

        key as FontString = FontString(text, font)
        tr as TextRenderer

        if not m_StringCache.ContainsKey(key):
            size as System.Drawing.Point = MeasureText(font, text)
            tr = TextRenderer(size.X, size.Y, self)
            tr.DrawString(text, sysFont, System.Drawing.Brushes.White, System.Drawing.Point.Empty, m_StringFormat)

            DrawTexturedRect(tr.Texture, System.Drawing.Rectangle(position.X, position.Y, tr.Texture.Width, tr.Texture.Height))
            m_StringCache[key] = tr

        else:
            tr = m_StringCache[key]
            DrawTexturedRect(tr.Texture, System.Drawing.Rectangle(position.X, position.Y, tr.Texture.Width, tr.Texture.Height))

    static def LoadTextureInternal(t as Gwen.Texture, bmp as System.Drawing.Bitmap):
        lock_format as System.Drawing.Imaging.PixelFormat = System.Drawing.Imaging.PixelFormat.Undefined

        match bmp.PixelFormat:
            case System.Drawing.Imaging.PixelFormat.Format32bppArgb:
                lock_format = System.Drawing.Imaging.PixelFormat.Format32bppArgb
            case System.Drawing.Imaging.PixelFormat.Format24bppRgb:
                lock_format = System.Drawing.Imaging.PixelFormat.Format32bppArgb //@todo Uhm? I copied this form the source ...
            otherwise:
                t.Failed = true
                return

        glTex as (int) = array(int, 1)

        // Create the opengl texture
        GL.GenTextures(1, glTex)
        GL.BindTexture(TextureTarget.Texture2D, glTex[0])
        GL.TexParameter(TextureTarget.Texture2D, TextureParameterName.TextureMinFilter, TextureMinFilter.Nearest cast int)
        GL.TexParameter(TextureTarget.Texture2D, TextureParameterName.TextureMagFilter, TextureMagFilter.Nearest cast int)

        // Sort out our GWEN texture
        t.RendererData     = glTex[0]
        t.Width         = bmp.Width
        t.Height         = bmp.Height

        data as System.Drawing.Imaging.BitmapData = bmp.LockBits(System.Drawing.Rectangle(0, 0, bmp.Width, bmp.Height), System.Drawing.Imaging.ImageLockMode.ReadOnly, lock_format)

        if lock_format == System.Drawing.Imaging.PixelFormat.Format32bppArgb:
            GL.TexImage2D(TextureTarget.Texture2D, 0, PixelInternalFormat.Rgba, t.Width, t.Height, 0, OpenTK.Graphics.OpenGL.PixelFormat.Bgra, PixelType.UnsignedByte, data.Scan0)

        bmp.UnlockBits(data)

        m_LastTextureID = glTex[0]

    override def LoadTexture(t as Gwen.Texture):
        bmp as System.Drawing.Bitmap
        try:
            bmp = System.Drawing.Bitmap(t.Name)

        except ex:
            t.Failed = true
            return

        LoadTextureInternal(t, bmp)
        bmp.Dispose()

    override def LoadTextureStream(t as Gwen.Texture, data as System.IO.Stream):
        bmp as System.Drawing.Bitmap
        try:
            bmp = System.Drawing.Bitmap(data)

        except ex:
            t.Failed = true
            return

        LoadTextureInternal(t, bmp)
        bmp.Dispose()

    override def LoadTextureRaw(t as Gwen.Texture, pixelData as (byte)):
        bmp as System.Drawing.Bitmap

        try:
            fixed pixelData, ptr:
                bmp = System.Drawing.Bitmap(t.Width, t.Height, 4 * t.Width, System.Drawing.Imaging.PixelFormat.Format32bppArgb, ptr)

        except ex:
            t.Failed = true
            return

        glTex as (int) = array(int, 1)

        // Create the opengl texture
        GL.GenTextures(1, glTex)
        GL.BindTexture(TextureTarget.Texture2D, glTex[0])
        GL.TexParameter(TextureTarget.Texture2D, TextureParameterName.TextureMinFilter, TextureMinFilter.Nearest cast int)
        GL.TexParameter(TextureTarget.Texture2D, TextureParameterName.TextureMagFilter, TextureMagFilter.Nearest cast int)

        t.RendererData = glTex[0]

        data = bmp.LockBits(System.Drawing.Rectangle(0, 0, bmp.Width, bmp.Height), System.Drawing.Imaging.ImageLockMode.ReadOnly, System.Drawing.Imaging.PixelFormat.Format32bppArgb)
        GL.TexImage2D(TextureTarget.Texture2D, 0, PixelInternalFormat.Rgba, t.Width, t.Height, 0, OpenTK.Graphics.OpenGL.PixelFormat.Rgba, PixelType.UnsignedByte, data.Scan0)
        
        m_LastTextureID = glTex[0]

        bmp.UnlockBits(data)
        bmp.Dispose()

    override def FreeTexture(t as Gwen.Texture):
        if t.RendererData is null:
            return

        tex as int = t.RendererData cast int
        if tex == 0:
            return

        GL.DeleteTextures(1, tex)
        t.RendererData = null

    override def PixelColor(texture as Gwen.Texture, x as uint, y as uint, defaultColor as System.Drawing.Color) as System.Drawing.Color:
        if texture.RendererData is null:
            return defaultColor

        tex as int = texture.RendererData cast int
        if tex == 0:
            return defaultColor

        pixel as System.Drawing.Color
        GL.BindTexture(TextureTarget.Texture2D, tex)
        offset as long = 4 * (x + y * texture.Width)
        data as (byte) = array(byte, 4 * texture.Width * texture.Height)

        fixed data, ptr:
            GL.GetTexImage(TextureTarget.Texture2D, 0, OpenTK.Graphics.OpenGL.PixelFormat.Rgba, PixelType.UnsignedByte, ptr)
            pixel = System.Drawing.Color.FromArgb(data[offset + 3], data[offset + 0], data[offset + 1], data[offset + 2])

        return pixel