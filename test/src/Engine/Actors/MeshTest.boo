namespace Spectral.Test

import System
import OpenTK
import OpenTK.Graphics
import Spectral
import Spectral.Actors
import Spectral.Graphics
import Spectral.Graphics.Vertices

class MeshTest(ActorTestCases, IDisposable):

    protected _engine as Engine

    def constructor():
        _engine = Engine(800, 600, GraphicsMode(ColorFormat(8, 8, 8, 8 ), 16), "Spectral Mesh Test")

        v1 = VertexNormal1D(Vector3(1, 0, 0))
        v2 = VertexNormal1D(Vector3(0, 1, 0))
        v3 = VertexNormal1D(Vector3(0, 0, 1))
        model = Model[of VertexNormal1D]((v1, v2, v3), (1 cast uint, 2 cast uint, 3 cast uint))

        Instance = Mesh("MeshTest", model)
        super()

    def Dispose():
        _engine.Dispose() if _engine is not null