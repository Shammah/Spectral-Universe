namespace Spectral.Test

import System
import Xunit
import OpenTK
import Spectral.Physics.Collision

class BoundingSphereTest:

    [Fact]
    def InvalidRadiusTest():
        func1 as Assert.ThrowsDelegate = { BoundingSphere(Vector3.Zero, -2f) }
        func2 as Assert.ThrowsDelegate = { BoundingSphere(Vector3.Zero, 0) }
        func3 as Assert.ThrowsDelegate = { sphere = BoundingSphere(Vector3.Zero); sphere.Radius = -3 }
        func4 as Assert.ThrowsDelegate = { sphere = BoundingSphere(Vector3.Zero); sphere.Radius = 0 }

        Assert.Throws[of System.ArgumentException](func1)
        Assert.Throws[of System.ArgumentException](func2)
        Assert.Throws[of System.ArgumentException](func3)
        Assert.Throws[of System.ArgumentException](func4)

    [Fact]
    def RadiusTest():
        ran = Random()

        for i in range(0, 25):
            radius as single = ran.Next()
            sphere = BoundingSphere(Vector3.One, radius)
            Assert.Equal(radius, sphere.Radius)

    [Fact]
    def CollisionTest():
        sphere1 = BoundingSphere(Vector3.One, 1f) # (1, 1, 1)
        sphere2 = BoundingSphere(2 * Vector3.One, 1f) #(2, 2, 2)

        Assert.True(sphere1.CollidesWith(sphere2))
        Assert.True(sphere2.CollidesWith(sphere1))
        Assert.True(sphere1 & sphere2)
        Assert.True(sphere2 & sphere1)

        sphere1 = BoundingSphere(Vector3(-5, -5, -5), 1f)
        sphere2 = BoundingSphere(Vector3.One, 2f)

        Assert.False(sphere1.CollidesWith(sphere2))
        Assert.False(sphere2.CollidesWith(sphere1))
        Assert.False(sphere1 & sphere2)
        Assert.False(sphere2 & sphere1)

        sphere1 = BoundingSphere(Vector3.Zero, 1f)
        sphere2 = BoundingSphere(Vector3.One * Math.Sqrt(4f/3f), 1f)

        Assert.True(sphere1.CollidesWith(sphere2))
        Assert.True(sphere2.CollidesWith(sphere1))
        Assert.True(sphere1 & sphere2)
        Assert.True(sphere2 & sphere1)

        sphere1 = BoundingSphere(Vector3.Zero, 1f)
        sphere2 = BoundingSphere(Vector3.One * Math.Sqrt(4f/3f + 0.01f), 1f)

        Assert.False(sphere1.CollidesWith(sphere2))
        Assert.False(sphere2.CollidesWith(sphere1))
        Assert.False(sphere1 & sphere2)
        Assert.False(sphere2 & sphere1)

        sphere1 = BoundingSphere(Vector3.Zero, 1f)
        sphere2 = BoundingSphere(Vector3.One * Math.Sqrt(4f/3f - 0.01f), 1f)

        Assert.True(sphere1.CollidesWith(sphere2))
        Assert.True(sphere2.CollidesWith(sphere1))
        Assert.True(sphere1 & sphere2)
        Assert.True(sphere2 & sphere1)

    [Fact]
    def PenetrationTest():
        sphere1 = BoundingSphere(Vector3.Zero)
        sphere2 = BoundingSphere(Vector3(1, 1, 0))

        Assert.Equal(2f - Math.Sqrt(2) cast single, sphere1.Penetration(sphere2))
        Assert.Equal(2f - Math.Sqrt(2) cast single, sphere2.Penetration(sphere1))
        Assert.Equal(2f - Math.Sqrt(2) cast single, sphere1 - sphere2)
        Assert.Equal(2f - Math.Sqrt(2) cast single, sphere2 - sphere1)

        sphere1 = BoundingSphere(Vector3(1, 1, 0))
        sphere2 = BoundingSphere(Vector3(5, 3, 0))

        Assert.Equal(2f - Math.Sqrt(20) cast single, sphere1.Penetration(sphere2))
        Assert.Equal(2f - Math.Sqrt(20) cast single, sphere2.Penetration(sphere1))
        Assert.Equal(2f - Math.Sqrt(20) cast single, sphere1 - sphere2)
        Assert.Equal(2f - Math.Sqrt(20) cast single, sphere2 - sphere1)