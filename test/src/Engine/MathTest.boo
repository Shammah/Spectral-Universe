namespace Spectral.Test

import System
import Xunit

class MathTest:

    [Fact]
    def RadiansToDegrees():
        Assert.Equal(57.3f, Spectral.Math.RadiansToDegrees(1), 0.1f)
        Assert.Equal(317.4f, Spectral.Math.RadiansToDegrees(5.54), 0.1f)
        Assert.Equal(-11459f, Spectral.Math.RadiansToDegrees(-200), 0.2f)

    [Fact]
    def DegreesToRadians():
        Assert.Equal(8.9, Spectral.Math.DegreesToRadians(510), 0.1)
        Assert.Equal(0.0548, Spectral.Math.DegreesToRadians(3.14), 0.01)
        Assert.Equal(-0.1271, Spectral.Math.DegreesToRadians(-7.28), 0.01)