namespace Spectral.Graphics

import System
import System.Runtime.InteropServices
import OpenTK.Graphics.OpenGL
import Spectral.Graphics.Textures
import Spectral.Graphics.Vertices
import Spectral.Graphics.Programs

class Model[of V(IVertex)](IModel):
"""Basic 3D static geometry model class."""

    Buffers as (uint):
    """The OpenGL Data Buffers used by this model."""
        get:
            return _buffers

    VAO as uint:
    """Returns the Vertex Array Object (VAO)."""
        get:
            return _vao[0]

    Mode as BeginMode:
    """The mode of drawing the model: triangles, quads, points etc."""
        get:
            return _mode
        set:
            _mode = value

    Program as GLProgram:
    """If not null, this OpenGL Program will be used for the rendering of the model."""
        get:
            return _program
        set:
            _program = value

    Texture as ITexture:
    """A model can have an optional standard texture."""
        get:
            return _texture
        set:
            _texture = value

    private _vao as (uint)
    private _buffers as (uint) # 1st = VBO, 2nd = Elements
    private _numVertices as uint
    private _numElements as uint
    private _mode as BeginMode

    private _program as GLProgram
    private _texture as ITexture

    protected _disposed as bool

    def constructor(ref vertices as (V)):
    """
    Constructor.
    Param vertices: The array of vertices to be drawn.
    Raises ArgumentException: The vertices and (if not null) elements array must have at least 1 element.
    Raises NullReferenceException: The vertices array cannot be null.
    """
        Init(vertices, null)

    def constructor(ref vertices as (V), elements as (uint)):
    """
    Constructor.
    Param vertices: The array of vertices to be drawn.
    Param elements: The array of indices to indicate in which order to draw the vertices.
    Raises ArgumentException: The vertices and (if not null) elements array must have at least 1 element.
    Raises NullReferenceException: The vertices array cannot be null.
    """
        Init(vertices, elements)

    private def Init(ref vertices as (V), elements as (uint)):
    """
    General class initializer.
    Param vertices: The array of vertices to be drawn.
    Param elements: The array of indices to indicate in which order to draw the vertices.
    Raises ArgumentException: The vertices and (if not null) elements array must have at least 1 element.
    Raises NullReferenceException: The vertices array cannot be null.
    """
        raise NullReferenceException("The vertices array cannot be null.") if vertices is null
        raise ArgumentException("The vertices array must have at least 1 element.") if vertices.Length < 1
        Mode    = BeginMode.Triangles
        Texture = null

        if elements is null:
            _buffers = array(uint, 1)
            GL.GenBuffers(1, _buffers)
        else:
            raise ArgumentException("The elements array must have at least 1 element.") if elements.Length < 1
            _buffers = array(uint, 2)
            GL.GenBuffers(2, _buffers)

        _vao = array(uint, 1)
        GL.GenVertexArrays(1, _vao)
        GL.BindVertexArray(_vao[0])

        # Buffer vertices to the GPU memory.
        fixed vertices, ptr:
            GL.BindBuffer(BufferTarget.ArrayBuffer, _buffers[0])
            GL.BufferData(BufferTarget.ArrayBuffer, IntPtr(Marshal.SizeOf(vertices[0]) * vertices.Length), ptr, BufferUsageHint.StaticDraw)

        # Buffer indices to the GPU memory if there are any.
        if elements is not null:
            fixed elements, ptr:
                GL.BindBuffer(BufferTarget.ElementArrayBuffer, _buffers[1])
                GL.BufferData(BufferTarget.ElementArrayBuffer, IntPtr(sizeof(uint) * elements.Length), ptr, BufferUsageHint.StaticDraw)

        # Load attributes.
        attributes = vertices[0].Attributes

        for i in range(attributes.Length):
            GL.EnableVertexAttribArray(i)
            GL.VertexAttribPointer(i, attributes[i].Item2, attributes[i].Item3, false, Marshal.SizeOf(vertices[0]), attributes[i].Item1)

        GL.BindVertexArray(0)

        _numVertices = vertices.Length
        if elements is not null:
            _numElements = elements.Length
        else:
            _numElements = 0

        _disposed = false

    virtual def Render():
    """
    Renders the model using the default mode.
    """
        Render(Mode)

    virtual def Render(mode as BeginMode):
    """
    Renders the model.
    Param mode: The mode of drawing the model: triangles, quads, points etc.
    """
        GL.BindVertexArray(VAO)

        # Optional custom OpenGL Shader Program.
        if Program is not null:
            Program.Use()

        # Optional default texture.
        if Texture is not null:
            Texture.Bind()
        
        if Buffers.Length == 1:
            GL.DrawArrays(mode, 0, _numVertices)
        else:
            GL.DrawElements(mode, _numElements, DrawElementsType.UnsignedInt, 0)

        GL.BindVertexArray(0)

    virtual def Dispose():
    """Free model resources."""
        return if _disposed

        GL.DeleteBuffers(Buffers.Length, Buffers)
        GL.DeleteVertexArrays(1, _vao)

        if Texture is not null:
            Texture.Dispose()

        if Program is not null:
            Program.Dispose()

        _disposed = true