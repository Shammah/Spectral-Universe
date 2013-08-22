namespace Spectral.Test

import System
import Xunit
import OpenTK
import Spectral
import Spectral.Actors

class CameraTest:

    private _camera as Camera

    def constructor():
        _camera              = Camera()
        _camera.Position     = Vector3(0, 0, 3)
        _camera.Up           = Vector3(0, 1, 0)
        _camera.Target       = Vector3(0, 0, 2)
        _camera.ZNear        = 0.1f
        _camera.ZFar         = 100f
        _camera.Width        = 100
        _camera.Height       = 100
        _camera.Fov          = 90

    [Fact]
    def Up():
        _camera.Up = Vector3(5, 0, 0)
        Assert.Equal(Vector3(1, 0, 0), _camera.Up)

        _camera.Up = Vector3(0, 5, 0)
        Assert.Equal(Vector3(0, 1, 0), _camera.Up)

        _camera.Up = Vector3(0, 0, 5)
        Assert.Equal(Vector3(0, 0, 1), _camera.Up)

    [Fact]
    def Direction():
        ran = Random()

        for i in range(0, 25):
            _camera.Position = Vector3(ran.Next(), ran.Next(), ran.Next())
            _camera.Target   = Vector3(ran.Next(), ran.Next(), ran.Next())
            Assert.Equal(Vector3.Normalize(_camera.Target - _camera.Position), _camera.Direction)

    [Fact]
    def Fov():
    """Todo: Fix this shit yo! It's breaked!"""
        rand = Random()

        for i in range(0, 10):
            angle = rand.Next()
            Assert.Equal(_camera.FovYToFovX(_camera.FovXToFovY(angle)), _camera.FovXToFovY(angle), 0.01)

        for i in range(0, 10):
            angle = rand.Next()
            Assert.Equal(_camera.FovXToFovY(_camera.FovYToFovX(angle)), _camera.FovYToFovX(angle), 0.01)

    [Fact]
    def ZNear():
        _camera.ZNear = 50f
        _camera.Perspective()

        func1 as Assert.ThrowsDelegate = { _camera.ZNear = 0f }
        func2 as Assert.ThrowsDelegate = { _camera.ZNear = -4f }
        func3 as Assert.ThrowsDelegate = { _camera.ZNear = 500f }

        Assert.Throws[of System.ArgumentException](func1)
        Assert.Throws[of System.ArgumentException](func2)
        Assert.Throws[of System.ArgumentException](func3)

    [Fact]
    def ZFar():
        _camera.ZNear = 5f
        _camera.ZFar = 50f
        _camera.Perspective()

        func1 as Assert.ThrowsDelegate = { _camera.ZFar = 0f }
        func2 as Assert.ThrowsDelegate = { _camera.ZFar = -4f }
        func3 as Assert.ThrowsDelegate = { _camera.ZFar = 3f }

        Assert.Throws[of System.ArgumentException](func1)
        Assert.Throws[of System.ArgumentException](func2)
        Assert.Throws[of System.ArgumentException](func3)

        _camera.ZFar = 500f
        _camera.Perspective()

    [Fact]
    def Width():
        _camera.Width = 200f
        Assert.Equal(2.0f, _camera.AspectRatio, 0.01f)

        func1 as Assert.ThrowsDelegate = { _camera.Width = 0 }
        func2 as Assert.ThrowsDelegate = { _camera.Width = -5f }

        Assert.Throws[of System.ArgumentException](func1)
        Assert.Throws[of System.ArgumentException](func2)

    [Fact]
    def Height():
        _camera.Height = 200f
        Assert.Equal( 0.5f, _camera.AspectRatio, 0.01f)

        func1 as Assert.ThrowsDelegate = { _camera.Height = 0 }
        func2 as Assert.ThrowsDelegate = { _camera.Height = -5f }

        Assert.Throws[of System.ArgumentException](func1)
        Assert.Throws[of System.ArgumentException](func2)

    [Fact]
    def Attach():
        actor = PointLight("test") # Test actor.
        actor.Position = Vector3(1, 1, 1)

        _camera.Position = Vector3(0, 0, 0)
        _camera.Attach = actor

        actor.Position = Vector3(2, 0, 3)
        Assert.Equal(Vector3(1, -1, 2), _camera.Position)

        _camera.Attach = null
        actor.Position = Vector3(50, 50, 50)
        Assert.Equal(Vector3(1, -1, 2), _camera.Position)

        _camera.Attach = actor
        actor.Position = Vector3(50, 50, 50)
        Assert.Equal(Vector3(1, -1, 2), _camera.Position)

        actor.Position = Vector3(51, 51, 51)
        Assert.Equal(Vector3(2, 0, 3), _camera.Position)