namespace Spectral.Test

import System
import Xunit
import OpenTK
import OpenTK.Graphics
import Spectral
import Spectral.Actors

abstract class ActorTestCases:

    Instance as Actor:
    """
    The main actor testing instance.
    Raises NullReferenceException: Actor cnanot be null.
    """
        virtual set:
            raise NullReferenceException("Actor testing instance is null.") if value is null
            actor = value
        virtual get:
            return actor

    protected actor as Actor

    def constructor():
        actor.Position    = Vector3.Zero
        actor.Orientation = Quaternion.Identity
        actor.Scale       = Vector3.One

    [Fact]
    def PositionTest():
        actor.Position = Vector3.One
        Assert.Equal(Vector3.One, actor.Position)

    [Fact]
    def OrientationPass():
        actor.Orientation = Quaternion(Vector3(1,2,3), 5)
        Assert.Equal(Quaternion(Vector3(1,2,3), 5), actor.Orientation)

        actor.Orientation = Quaternion(Vector3(1,-2,3), -5)
        Assert.Equal(Quaternion(Vector3(1,-2,3), -5), actor.Orientation)

        actor.Orientation = Quaternion.Identity
        Assert.Equal(Quaternion.Identity, actor.Orientation)

    [Fact]
    def ScalePass():
        actor.Scale = Vector3(3, 5, 6)
        Assert.Equal(Vector3(3, 5, 6), actor.Scale)

        actor.Scale = Vector3(0.1f, 0.00001f, 50f)
        Assert.Equal(Vector3(0.1f, 0.00001f, 50f), actor.Scale)

        actor.Scale = Vector3(100000, 10030423, 2435762)
        Assert.Equal(Vector3(100000, 10030423, 2435762), actor.Scale)

    [Fact]
    def ScaleFail1():
        func as Assert.ThrowsDelegate = { actor.Scale = Vector3.Zero }
        Assert.Throws[of System.ArgumentException](func)

    [Fact]
    def ScaleFail2():
        func1 as Assert.ThrowsDelegate = { actor.Scale = Vector3(-3, 4, 5) }
        func2 as Assert.ThrowsDelegate = { actor.Scale = Vector3(3, -4, 5) }
        func3 as Assert.ThrowsDelegate = { actor.Scale = Vector3(3, 4, -5) }

        Assert.Throws[of System.ArgumentException](func1)
        Assert.Throws[of System.ArgumentException](func2)
        Assert.Throws[of System.ArgumentException](func3)

    [Fact]
    def Map():
    """Todo: Add assertion that the map contains the actor or not."""
        engine = Engine(800, 600, GraphicsMode(ColorFormat(8, 8, 8, 8), 16), "Spectral Test")
        m = Spectral.Map(engine)

        actor.Map = m
        actor.Map = null

        engine.Dispose()