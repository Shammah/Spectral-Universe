namespace Spectral.Test

import System
import Xunit
import OpenTK.Graphics
import Spectral
import Spectral.Audio

abstract class AudioTestCases(IDisposable):

    Instance as IAudio:
    """
    The main audio testing instance.
    Raises NullReferenceException: Actor cnanot be null.
    """
        virtual set:
            raise NullReferenceException("Actor testing instance is null.") if value is null
            audio = value
        virtual get:
            return audio

    protected audio as IAudio
    private _engine as Engine

    def constructor():
        _engine = Engine(800, 600, GraphicsMode(ColorFormat(8, 8, 8, 8 ), 16), "Spectral Audio Test")

    [Fact]
    def PlayTest():
        Assert.False(audio.IsPlaying)

        audio.Play()
        Assert.True(audio.IsPlaying)

        audio.Pause()
        Assert.False(audio.IsPlaying)

        audio.Play()
        Assert.True(audio.IsPlaying)

        audio.Stop()
        Assert.False(audio.IsPlaying)

    [Fact]
    def LengthTest():
        Assert.Equal(10f, audio.Length, 0.2f)

    [Fact]
    def VolumeTest():
        Assert.Equal(1f, audio.Volume, 0.01f)

        audio.Volume = 0.4f
        Assert.Equal(0.4f, audio.Volume, 0.01f)

        audio.Volume = 0f
        Assert.Equal(0f, audio.Volume, 0.01f)

        audio.Volume = -0.4f
        Assert.Equal(0f, audio.Volume, 0.01f)

    [Fact]
    def PitchTest():
        Assert.Equal(1f, audio.Pitch, 0.01f)

        audio.Pitch = 2f
        Assert.Equal(2f, audio.Pitch, 0.01f)

        audio.Pitch = 0.5f
        Assert.Equal(0.5f, audio.Pitch, 0.01f)

        audio.Pitch = 0.2f
        Assert.Equal(0.5f, audio.Pitch, 0.01f)

        audio.Pitch = -0.2f
        Assert.Equal(0.5f, audio.Pitch, 0.01f)

        audio.Pitch = 2.5f
        Assert.Equal(2f, audio.Pitch, 0.01f)

    [Fact(Skip: "Position is not working yet for music.")]
    def LoopTest():
        audio.Looping = true
        Assert.True(audio.Looping)

        audio.Play()
        Assert.True(audio.IsPlaying)

        System.Threading.Thread.Sleep(11000)
        Assert.True(audio.Position < 5f)

    [Fact(Skip: "Position is not working yet for music.")]
    def PositionTest():
        pass

    def Dispose():
        audio.Dispose() if audio is not null
        _engine.Dispose() if _engine is not null