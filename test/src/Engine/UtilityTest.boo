namespace Spectral.Test

import System
import System.Collections.Generic
import Xunit
import Spectral

class UtilityTest:

    [Fact]
    def ClampTest():
        Assert.Equal(5.25f, Clamp[of single](5.25f, 3f, 6f))
        Assert.Equal(4f, Clamp[of single](-1, 4, 6))
        Assert.Equal(6f, Clamp[of single](10, 4, 6))

        func as Assert.ThrowsDelegate = { Clamp[of single](5, 4, 3) }
        Assert.Throws[of System.ArgumentException](func)

    [Fact]
    def AsVector4():
        rand = Random()

        list = List[of (single)]()

        for i in range(0, 25):
            list.Add((rand.Next() cast single, rand.Next() cast single, rand.Next() cast single, rand.Next() cast single))

        i = 0
        for vec in Spectral.AsVector4(list):
            Assert.Equal(list[i][0], vec[0])
            Assert.Equal(list[i][1], vec[1])
            Assert.Equal(list[i][2], vec[2])
            Assert.Equal(list[i][3], vec[3])
            i++

    [Fact]
    def AsVector3():
        rand = Random()

        list = List[of (single)]()

        for i in range(0, 25):
            list.Add((rand.Next() cast single, rand.Next() cast single, rand.Next() cast single))

        i = 0
        for vec in Spectral.AsVector3(list):
            Assert.Equal(list[i][0], vec[0])
            Assert.Equal(list[i][1], vec[1])
            Assert.Equal(list[i][2], vec[2])
            i++

    [Fact]
    def AsVector2():
        rand = Random()

        list = List[of (single)]()

        for i in range(0, 25):
            list.Add((rand.Next() cast single, rand.Next() cast single))

        i = 0
        for vec in Spectral.AsVector2(list):
            Assert.Equal(list[i][0], vec[0])
            Assert.Equal(list[i][1], vec[1])
            i++