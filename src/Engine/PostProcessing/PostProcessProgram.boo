namespace Spectral.PostProcess

import System
import OpenTK.Graphics.OpenGL
import Spectral.Graphics.Programs

class PostProcessProgram(GLProgram):
"""Programs used for shading post-procces, which include screen width and height."""

    Width as uint:
    """
    Width of the texture for the fragment shader in pixels.
    Remarks: Private variable _widthChanged will be set to true if changed.
    """
        get:
            return _width
        set:
            _width         = value
            _widthChanged  = true

    Height as uint:
    """
    Height of the texture for the fragment shader in pixels.
    Remarks: Private variable _heightChanged will be set to true if changed.
    """
        get:
            return _height
        set:
            _height         = value
            _heightChanged  = true

    private _width as uint
    private _height as uint

    private _widthChanged as bool
    private _heightChanged as bool

    private _width_uniform as int
    private _height_uniform as int

    def constructor():
    """Constructor."""
        super()

        Width  = 1
        Height = 1

    override def Link():
    """Compiles the shaders, then links the program together, and finally locates the uniform variables in the shader."""
        super.Link()

        # Once linked up, we can retrieve our uniform variables.
        _width_uniform  = GL.GetUniformLocation(Handle, "width")
        _height_uniform = GL.GetUniformLocation(Handle, "height")

    override def Use():
    """Use the program, and update the width and height if neccessary."""
        super.Use()

        if _widthChanged and _width_uniform != -1:
            GL.Uniform1(_width_uniform, Width)
            _widthChanged = false

        if _heightChanged and _height_uniform != 1:
            GL.Uniform1(_height_uniform, Height)
            _heightChanged = false