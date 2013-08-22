namespace Spectral.Test

import System
import Xunit
import OpenTK
import Spectral.Physics.Collision

class BoundingBoxTest(BoundingBox):

    [Fact]
    def InvalidPropertiesTest():
        box = BoundingBox()

        func = array(Assert.ThrowsDelegate, 12)

        func[0 ] = { box.Width = 0}
        func[1 ] = { box.Width = -1}
        func[2 ] = { box.HalfWidth = 0}
        func[3 ] = { box.HalfWidth = -1}

        func[4 ] = { box.Height = 0}
        func[5 ] = { box.Height = -1}
        func[6 ] = { box.HalfHeight = 0}
        func[7 ] = { box.HalfHeight = -1}

        func[8 ] = { box.Depth = 0}
        func[9 ] = { box.Depth = -1}
        func[10] = { box.HalfDepth = 0}
        func[11] = { box.HalfDepth = -1}

        for f in func:
            Assert.Throws[of System.ArgumentException](f)

    [Fact]
    def PropertyTests():
        box = BoundingBox()
        Assert.Equal(1f, box.Width)
        Assert.Equal(0.5f, box.HalfWidth)
        Assert.Equal(1f, box.Height)
        Assert.Equal(0.5f, box.HalfHeight)
        Assert.Equal(1f, box.Depth)
        Assert.Equal(0.5f, box.HalfDepth)

        box.Width = 20f
        Assert.Equal(20f, box.Width)
        Assert.Equal(10f, box.HalfWidth)
        Assert.Equal(1f, box.Height)
        Assert.Equal(0.5f, box.HalfHeight)
        Assert.Equal(1f, box.Depth)
        Assert.Equal(0.5f, box.HalfDepth)

        box.Height = 20f
        Assert.Equal(20f, box.Width)
        Assert.Equal(10f, box.HalfWidth)
        Assert.Equal(20f, box.Height)
        Assert.Equal(10f, box.HalfHeight)
        Assert.Equal(1f, box.Depth)
        Assert.Equal(0.5f, box.HalfDepth)

        box.Depth = 20f
        Assert.Equal(20f, box.Width)
        Assert.Equal(10f, box.HalfWidth)
        Assert.Equal(20f, box.Height)
        Assert.Equal(10f, box.HalfHeight)
        Assert.Equal(20f, box.Depth)
        Assert.Equal(10f, box.HalfDepth)

    [Fact]
    def OverlapTest():
        a = Vector2(1f, 2f)
        b = Vector2(2.1f, 3f)
        Assert.False(Overlap(a, b))
        Assert.False(Overlap(b, a))

        b = Vector2(1.5f, 3f)
        Assert.True(Overlap(a, b))
        Assert.True(Overlap(b, a))

        b = Vector2(0.5f, 1.5f)
        Assert.True(Overlap(a, b))
        Assert.True(Overlap(b, a))

        b = Vector2(1.25f, 1.75f)
        Assert.True(Overlap(a, b))
        Assert.True(Overlap(b, a))

        b = a
        Assert.True(Overlap(a, b))
        Assert.True(Overlap(b, a))

    [Fact]
    def CollisionTest():
        box1 = BoundingBox()
        box2 = BoundingBox()
        box2.Position = box1.Position
        box2.Position.X += 0.2f

        Assert.True(box1 & box2)