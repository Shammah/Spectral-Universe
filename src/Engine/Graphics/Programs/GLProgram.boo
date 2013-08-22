namespace Spectral.Graphics.Programs

import System
import System.Collections.Generic
import OpenTK.Graphics.OpenGL
import Spectral.Graphics

class GLProgram(IDisposable):
"""A program as used by OpenGL. Practically, a collection of shaders linked together."""

    class GLProgramException(Exception):
    """Exception thrown when the GLProgram fails in some way or another."""

        [Getter(Program)]
        private _program as GLProgram

        def constructor(program as GLProgram, message as string):
        """
        Constructor.
        Param program: The GLProgram for which the exception was thrown.
        Param message: The error message.
        """
            super(message)

            _program = program

    Handle as uint:
    """Handle (or ID) of the created program, as used by OpenGL."""
        get:
            return _program

    VertexShaders as List[of Shader]:
    """Returns the list of VertexShaders added to this program."""
        get:
            return _vs
    
    FragmentShaders as List[of Shader]:
    """Returns the list of FragmentShaders added to this program."""
        get:
            return _fs

    GeometryShaders as List[of Shader]:
    """Returns the list of GeometryShaders added to this program."""
        get:
            return _gs

    Linked as bool:
    """Returns whether the program has been linked or not."""
        get:
            return _linked
        protected set:
            _linked = value

    private _program as uint
    private _vs as List[of Shader]
    private _fs as List[of Shader]
    private _gs as List[of Shader]
    private _linked as bool

    protected _disposed as bool

    def constructor():
    """Constructor."""
        _program    = GL.CreateProgram()
        _vs         = List[of Shader]()
        _fs         = List[of Shader]()
        _gs         = List[of Shader]()
        _linked     = false

        _disposed   = false

    virtual def AddShader(shader as Shader) as bool:
    """
    Adds a shader to the program.
    Param shader: The shader to be added.
    Remarks: Duplicates will not be added.
    Returns: Whether the shader has ben succesfully added to the program. Returns false if it was a duplicate.
    """
        type as ShaderType = shader.Type

        if HasShader(shader):
            return false

        else:
            if type == ShaderType.VertexShader:
                VertexShaders.Add(shader)
                return true

            elif type == ShaderType.FragmentShader:
                FragmentShaders.Add(shader)
                return true

            elif type == ShaderType.GeometryShader:
                GeometryShaders.Add(shader)
                return true

            else:
                return false

    virtual def RemoveShader(shader as Shader) as bool:
    """
    Removes a shader from the program.
    Param shader: The shader which has to be removed.
    Returns: Whether the shader has been succesfully removed from the program. Returns false if it weren't present.
    """
        type as ShaderType = shader.Type

        if type == ShaderType.VertexShader:
            return VertexShaders.Remove(shader)

        elif type == ShaderType.FragmentShader:
            return FragmentShaders.Remove(shader)

        elif type == ShaderType.GeometryShader:
            return GeometryShaders.Remove(shader)

        return false

    virtual def HasShader(shader as Shader) as bool:
    """
    Returns whether the program already has a given shader.
    Param shader: The shader to check the existance of.
    """
        if VertexShaders.Contains(shader):
            return true

        if FragmentShaders.Contains(shader):
            return true

        if GeometryShaders.Contains(shader):
            return true

    virtual def Link():
    """
    Compiles all shaders and link them together in the program.
    Remarks: Linked will be set to true if linked successfully.
    Raises GLProgramException: There has to be at least 1 vertex and 1 fragment shader.
    Raises GLProgramException: There was a compilation or linking error.
    """
        if VertexShaders.Count < 1 or FragmentShaders.Count < 1:
            raise GLProgramException(self, "Program $_program needs at least 1 vertex and 1 fragment shader in order to link.")

        try:
            for vs as Shader in VertexShaders:
                vs.Compile()
                GL.AttachShader(_program, vs.Handle)

            for fs as Shader in FragmentShaders:
                fs.Compile()
                GL.AttachShader(_program, fs.Handle)

            for gs as Shader in GeometryShaders:
                gs.Compile()
                GL.AttachShader(_program, gs.Handle)

        except ex as Shader.ShaderException:
            raise GLProgramException(self, ex.Message)

        GL.LinkProgram(_program)

        status as int
        GL.GetProgram(_program, ProgramParameter.LinkStatus, status)

        if status == 0:
            info as string
            GL.GetProgramInfoLog(_program, info)

            raise GLProgramException(self, "Error while linking a program $_program!\n$info")

        else:
            # General cleanup. Don't you worry, if the program has been succesfully linked, this will cause no harm!
            for vs as Shader in VertexShaders:
                GL.DetachShader(_program, vs.Handle)
                GL.DeleteShader(vs.Handle)

            for fs as Shader in FragmentShaders:
                GL.DetachShader(_program, fs.Handle)
                GL.DeleteShader(fs.Handle)

            for gs as Shader in GeometryShaders:
                GL.DetachShader(_program, gs.Handle)
                GL.DeleteShader(gs.Handle)

            _linked = true

    virtual def Use():
    """
    Tells OpenGL to use this specific program.
    Remarks: If the program was not yet linked, it will be just before the OpenGL call.
    """
        if not Linked:
            Link()

        # We will only switch programs if the current program is different from the one we want, as UseProgram() is an expensive operation.
        currentProgram as int
        GL.GetInteger(GetPName.CurrentProgram, currentProgram)

        GL.UseProgram(Handle) if currentProgram != Handle

    virtual def Dispose():
    """Free the program from memory."""
        return if _disposed

        GL.DeleteProgram(Handle)

        _disposed = true