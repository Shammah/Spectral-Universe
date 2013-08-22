namespace Spectral.Graphics

import System
import System.IO
import OpenTK.Graphics.OpenGL

class Shader:
"""
The shader class enables us to load a shader, compile and and returns us its handle needed for OpenGL.
Todo: Create a constructor for direct shaders instead of forcing it to be read from a file.
"""
    class ShaderException(Exception):
    """Exception throw upon an error concerning a shader."""
        [Getter(Shader)]
        private _shader as Shader

        def constructor(shader as Shader, message as string):
        """
        Constructor.
        Param shader: The shader for which this exception was thrown.
        Param message: The error message.
        """
            super(message)

            _shader = shader

    Handle as uint:
    """The handle (or ID) of the shader. Needed by OpenGL in order to work with the shader."""
        get:
            return _shader

    Source as string:
    """
    The source code of the shader.
    Remarks: You may edit the source to dynamically create shaders, but this is at your own risk!
    """
        get:
            return _source
        set:
            _source = value

    Type as ShaderType:
    """The type of shader, like for example a VertexShader or FragmentShader."""
        get:
            return _type

    Path as string:
    """The path to the file that contains the shader's sourcecode."""
        get:
            return _path

    Compiled as bool:
    """Whether the shader has been compiled or not."""
        get:
            return _compiled

    private _shader as uint # Shader ID
    private _source as string
    private _type as ShaderType
    private _path as string
    private _compiled as bool

    private def constructor(type as ShaderType, source as string, path as string):
    """
    Constructor.
    Param type: The type of shader, like for example a VertexShader or FragmentShader.
    Param source: The shader source code.
    Param path: The path to the file that contains the shader's sourcecode. This is empty if the shader is loaded from memory.
    Raises ShaderException: Failing to load the shader file.
    """
        _shader   = GL.CreateShader(type)
        _type       = type
        _path       = path
        _compiled = false
        _source   = source

    static def LoadFromMemory(type as ShaderType, source as string):
    """
    Loads a shader in directory from memory.
    Param type: The type of shader, like for example a VertexShader or FragmentShader.
    Param source: The shader source code.
    Returns: The newly created instance of the shader.
    """
        return Shader(type, source, String.Empty)

    static def LoadFromFile(type as ShaderType, path as string):
    """
    Loads a shader from a given file.
    Param type: The type of shader, like for example a VertexShader or FragmentShader.
    Param path: The path to the file that contains the shader's sourcecode.
    Returns: The newly created instance of the shader.
    """
        source as string = String.Empty

        try:
            using sr = StreamReader(path):
                source = sr.ReadToEnd()

            return Shader(type, source, path)

        except ex:
            raise ShaderException(null, "Failed to load $type: $path\n$ex")

    def Compile():
    """
    Compiles the shader.
    Remarks: If the shader has been compiled succesfully, Compiled will be set to true.
    Raises ShaderException: The shader has failed to compile.
    """
        GL.ShaderSource(_shader, _source)
        GL.CompileShader(_shader)

        status as int
        GL.GetShader(_shader, ShaderParameter.CompileStatus, status)

        if status == 0:
            info as string
            GL.GetShaderInfoLog(_shader, info)

            raise ShaderException(self, "Error while compiling $_type '$_path'!\n$info")

        _compiled = true

    override def ToString():
        return ("$_type - $_path")