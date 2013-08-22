namespace Universe.Programs

import System
import OpenTK.Graphics.OpenGL
import Spectral.Graphics
import Spectral.Graphics.Programs

class PlayerProgram(MVPLightProgram):
"""Shader for the player spaceship."""

    def constructor():
    """Constructor."""
        super()

        vertex as Shader    = Shader.LoadFromFile(ShaderType.VertexShader, "./Resources/Shaders/Game/player.vs")
        fragment as Shader  = Shader.LoadFromFile(ShaderType.FragmentShader, "./Resources/Shaders/Game/player.fs")
        AddShader(vertex)
        AddShader(fragment)

        Shininess           = 256