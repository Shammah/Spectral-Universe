namespace Spectral.Test

import System
import Xunit
import Spectral.Actors

abstract class LightTestCases(ActorTestCases):

    override Instance as Actor:
        override set:
            super(value)
            light = value cast Light

    protected light as Light

    def constructor():
        super()
        light.Intensity = 0

    [Fact]
    def IntensityPassTest():
        light.Intensity = 4
        assert light.Intensity == 4

        light.Intensity = 0
        assert light.Intensity == 0

    [Fact]
    def IntensityFailTest():
        func as Assert.ThrowsDelegate = { light.Intensity = -3 }
        Assert.Throws[of System.ArgumentException](func)