namespace Spectral.Graphics.Programs

import System
import System.Collections.Generic
import OpenTK
import OpenTK.Graphics
import OpenTK.Graphics.OpenGL
import Spectral.Actors
import Spectral.Graphics

class MVPLightProgram(MVPProgram):
"""An extended MVPProgram that supports lights."""

    Lights as List[of Light]:
    """The lights allocated to this shader program."""
        get:
            return _lights

    Ambient as Color4:
    """
    The ambient color of our shader.
    Remarks: Private variable _ambientChanged will be true.
    """
        get:
            return _ambientColor
        set:
            _ambientColor   = value
            _ambientChanged = true

    Shininess as single:
    """
    The shininess of the shader.
    Remarks: Private variable _shininessChanged will be true.
    Raises ArgumentException: Shininess cannot be a negative value.
    """
        get:
            return _shininess
        set:
            raise ArgumentException("The shininess of a shader can not be set to a negative value.") if value < 0
            _shininess        = value
            _shininessChanged = true

    private _lights as List[of Light]
    private _ambientColor as Color4
    private _shininess as single

    private _ambientChanged as bool
    private _shininessChanged as bool

    private _lightPos_uniform as int
    private _lightColor_uniform as int
    private _lightIntensity_uniform as int
    private _ambientColor_uniform as int
    private _shininess_uniform as int

    def constructor():
    """Constructor."""
        super()

        _lights             = List[of Light]()
        _ambientColor       = Color4(0, 0, 0, 0)
        _shininess          = 1

        _ambientChanged     = true
        _shininessChanged   = true

    override def Link():
    """Compiles the shaders, then links the program together, and finally locates the uniform variables in the shader."""
        # Before we compile and link this shit, we have to update the %numLights% variable.
        for vs as Shader in VertexShaders:
            if _lights.Count == 0:
                vs.Source = vs.Source.Replace("%numLights%", "1") // Be warry, we cannot have an array of 0 elements!
            else:
                vs.Source = vs.Source.Replace("%numLights%", _lights.Count.ToString())

        super.Link()

        _lightPos_uniform = GL.GetUniformLocation(Handle, "lightPos")
        raise GLProgramException(self, "Unable to locate uniform shader variable 'lightPos' in BasicShader'.") if (_lightPos_uniform == -1)

        _lightColor_uniform = GL.GetUniformLocation(Handle, "lightColor")
        raise GLProgramException(self, "Unable to locate uniform shader variable 'lightColor' in BasicShader'.") if (_lightColor_uniform == -1)

        _lightIntensity_uniform = GL.GetUniformLocation(Handle, "lightIntensity")
        raise GLProgramException(self, "Unable to locate uniform shader variable 'lightIntensity' in BasicShader'.") if (_lightIntensity_uniform == -1)

        _ambientColor_uniform = GL.GetUniformLocation(Handle, "ambientColor")
        raise GLProgramException(self, "Unable to locate uniform shader variable 'ambientColor' in BasicShader'.") if (_ambientColor_uniform == -1)

        _shininess_uniform = GL.GetUniformLocation(Handle, "shininess")
        raise GLProgramException(self, "Unable to locate uniform shader variable 'shininess' in BasicShader'.") if (_shininess_uniform == -1)

    override def Use():
    """Tells OpenGL to use this program. Updates uniform matrices if they have changed."""
        super()

        # Update light positions. We already do this for all lights, since it's probably more efficient this way.
        pos as (single)         = array(single, _lights.Count * 4)
        color as (single)       = array(single, _lights.Count * 4)
        intensity as (single)   = array(single, _lights.Count)
        i as int                = 0

        /// @todo Only do if any of the lights have changed.
        for light as PointLight in Lights:
            # If casting has failed, this isn't a PointLight thus we should continue!
            continue if light is null

            lightPos as Vector4

            if light.Directional:
                lightPos = Vector4.Transform(Vector4(light.Position.X, light.Position.Y, light.Position.Z, 0.0f), View)
            else:
                lightPos = Vector4.Transform(Vector4(light.Position.X, light.Position.Y, light.Position.Z, 1.0f), View)

            pos[0 + i * 4]   = lightPos.X
            pos[1 + i * 4]   = lightPos.Y
            pos[2 + i * 4]   = lightPos.Z
            pos[3 + i * 4]   = lightPos.W

            color[0 + i * 4] = light.Color.R
            color[1 + i * 4] = light.Color.G
            color[2 + i * 4] = light.Color.B
            color[3 + i * 4] = light.Color.A

            intensity[i]     = light.Intensity

            i++

        GL.Uniform4(_lightPos_uniform, _lights.Count, pos)
        GL.Uniform4(_lightColor_uniform, _lights.Count, color)
        GL.Uniform1(_lightIntensity_uniform, _lights.Count, intensity)

        if _ambientChanged:
            # Somehow colors are not accepted, eh?
            GL.Uniform4(_ambientColor_uniform, 1, (_ambientColor.R, _ambientColor.G, _ambientColor.B, _ambientColor.A))
            _ambientChanged = false

        if _shininessChanged:
            GL.Uniform1(_shininess_uniform, 1, _shininess)
            _shininessChanged = false

    def AddLight(light as Light):
    """
    Adds a pointLight to the shader.
    Param light: The light to be added.
    """
        Lights.Add(light)

        # Recompile program.
        Link()

    def RemoveLight(light as Light):
    """
    Removes a pointLight from the shader.
    Param light: The light to be removed.
    """
        Lights.Remove(light)

        # Recompile program.
        Link() if Lights.Count > 0 # Prevents a 0 zero light crash for now: TODO FIX

    def ClearLights():
        Lights.Clear()
        Linked = false