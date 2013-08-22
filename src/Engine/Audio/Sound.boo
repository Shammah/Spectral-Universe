namespace Spectral.Audio

import System
import OpenTK.Audio.OpenAL

class Sound(IAudio):
"""Basic sound class, which will be stored in memory, unlike streaming music."""

    Buffer as uint:
    """The audiobuffer."""
        get:
            return _buffer

    Source as uint:
    """OpenAL audio source."""
        get:
            return _source

    Looping as bool:
    """Whether the sound is looping or not."""
        get:
            return _loop
        set:
            AL.Source(_source, ALSourceb.Looping, true)
            _loop = value

    Volume as single:
    """
    Sets the volume of the sound. 1.0 = original. Range >= 0.
    Remarks: Clamps the value between the range.
    """
        get:
            return _volume
        set:
            vol = Spectral.Utility.Clamp[of single](value, 0, System.Single.MaxValue)
            AL.Source(_source, ALSourcef.Gain, vol)
            _volume = vol

    Pitch as single:
    """
    Sets the pitch of the sound. 1.0 = original. 0.5 &lt;= Range &lt;= 2.0
    Remarks: Clamps the value between the range.
    """
        get:
            return _pitch
        set:
            pit = Spectral.Utility.Clamp[of single](value, 0.5f, 2.0f)
            AL.Source(_source, ALSourcef.Pitch, pit)
            _pitch = pit

    Length as single:
    """The total length of the audio file in seconds."""
        get:
            return _length

    Position as single:
    """
    Gets or sets the current position of the music stream in seconds.
    Remarks: Clamps the position to the range from 0 to the music length in seconds.
    """
        get:
            byteOffset as int
            AL.GetSource(_source, ALGetSourcei.ByteOffset, byteOffset)
            return byteOffset cast double / _bytesPerSecond cast double

        set:
            pos = Spectral.Utility.Clamp[of single](value, 0, Length - 0.01f) # The max-value is exclusive, not inclusive.

            playing as bool = false
            playing         = true if IsPlaying

            AL.SourceRewind(_source)
            AL.Source(_source, ALSourcei.ByteOffset, pos * _bytesPerSecond)

            if playing:
                AL.SourcePlay(_source)

    IsPlaying as bool:
    """Returns whether the sound is currently playing or not."""
        get:
            state as int
            AL.GetSource(_source, ALGetSourcei.SourceState, state)
            return state == ALSourceState.Playing

    private _buffer as int
    private _source as int

    private _loop as bool
    private _volume as single
    private _pitch as single

    private _length as single
    private _bytesPerSecond as int

    protected _disposed as bool

    def constructor(path as string):
    """
    Constructor.
    Param sound: Path to the sound file.
    """
        _buffer     = AL.GenBuffer()
        _source     = AL.GenSource()

        _loop       = false
        _volume     = 1.0f
        _pitch      = 1.0f

        _disposed   = false

        Load(path)

    private def Load(path as string):
    """
    Loads a sound from a file and puts it into the sound buffer.
    Param path: Path to the sound file to load and buffer.
    Raises AudioException: Unsupport sound format.
    """
        using sound = AudioUtility.AudioFileStream(path):
            format as ALFormat  = AudioUtility.AudioFileFormat(sound)

            data as (byte)      = array(byte, sound.Length)
            sound.Read(data, 0, sound.Length)

            AL.BufferData(_buffer, format, data, data.Length, sound.WaveFormat.SampleRate)
            AL.Source(_source, ALSourcei.Buffer, _buffer)

            _length             = sound.TotalTime.TotalSeconds
            _bytesPerSecond     = sound.WaveFormat.AverageBytesPerSecond

    def Play() as bool:
    """
    Plays the sound if it has data in its buffer.
    Remarks: Sound will restart at the beginning if already playing. Sound will resume if it has been paused.
    Returns: Whether it has data played data or not.
    """
        return false if _buffer == 0

        if IsPlaying:
            Position = 0
        else:
            AL.SourcePlay(_source)

        return true

    def Pause() as bool:
    """
    Pauses the sound if it is playing.
    Returns: Whether the sound has been succesfully paused or not.
    """
        return false if not IsPlaying or _buffer == 0

        AL.SourcePause(_source)
        return true

    def Stop() as bool:
    """
    Stops the sound if it was already playing.
    Returns: Whether the sound has been succesfully stopped.
    """
        return false if not IsPlaying or _buffer == 0

        AL.SourceStop(_source)
        return true

    virtual def Dispose():
    """Clean up unmanaged resources."""
        return if _disposed

        AL.SourceStop(_source)
        AL.DeleteSource(_source)
        AL.DeleteBuffer(_buffer)

        _disposed = true