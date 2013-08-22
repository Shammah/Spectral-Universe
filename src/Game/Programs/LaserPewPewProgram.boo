namespace Universe.Programs

import System
import OpenTK.Graphics.OpenGL
import Spectral.Graphics
import Spectral.Graphics.Programs

class LaserPewPewProgram(MVPProgram):
"""Shader for the laser rays."""

    def constructor():
    """Constructor."""
        super()

        vertex as Shader    = Shader.LoadFromFile(ShaderType.VertexShader, "./Resources/Shaders/Game/laser.vs")
        fragment as Shader  = Shader.LoadFromFile(ShaderType.FragmentShader, "./Resources/Shaders/Game/laser.fs")
        AddShader(vertex)
        AddShader(fragment)