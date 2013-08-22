namespace Universe.Programs

import System
import OpenTK.Graphics.OpenGL
import Spectral.Graphics
import Spectral.Graphics.Programs

class TerrainProgram(MVPLightProgram):
"""Shader for the terrain."""

    def constructor():
    """Constructor."""
        super()

        vertex as Shader    = Shader.LoadFromFile(ShaderType.VertexShader, "./Resources/Shaders/Game/terrain.vs")
        fragment as Shader  = Shader.LoadFromFile(ShaderType.FragmentShader, "./Resources/Shaders/Game/terrain.fs")
        AddShader(vertex)
        AddShader(fragment)

        Shininess           = 64