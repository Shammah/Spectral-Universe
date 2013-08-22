namespace Spectral.Test

import System
import Spectral.Actors

class PointLightTest(LightTestCases):

    def constructor():
        Instance = PointLight("TestPointLight")
        super()