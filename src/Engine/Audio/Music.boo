namespace Spectral.Audio

import System
import System.Threading
import OpenTK.Audio.OpenAL
import NAudio.Wave

class Music(IAudio):
"""Music is audio being buffered from a file to the OpenAL drivers, instead of buffering the entire file at once like with Sound."""
    BufferSize as single:
    """The amount of seconds of audio each buffer should contain."""
        get:
            return _bufferSize

    BytesPerBuffer as single:
    """The number of bytes each buffer has."""
        get:
            # NAudio wants to read complete blocks, thus we have to make it divisible by the BlockAlign.
            size  = _file.WaveFormat.SampleRate * _file.WaveFormat.BitsPerSample / 8 * BufferSize * _file.WaveFormat.Channels
            size += _file.WaveFormat.BlockAlign - (size % _file.WaveFormat.BlockAlign)
            return size

    Looping as bool:
    """Whether the sound is looping or not."""
        get:
            return _loop
        set:
            _loop = value

    Volume as single:
    """
    Sets the volume of the sound. 1.0 = original. Range >= 0.
    Remarks: Clamps the value between the range.
    """
        get:
            return _volume
        set:
            vol     = Spectral.Utility.Clamp[of single](value, 0, System.Single.MaxValue)
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
            pit     = Spectral.Utility.Clamp[of single](value, 0.5f, 2.0f)
            AL.Source(_source, ALSourcef.Pitch, pit)
            _pitch  = pit

    Length as single:
    """The total length of the music file in seconds."""
        get:
            return _file.TotalTime.TotalSeconds

    Position as single:
    """
    Gets or sets the current position of the music stream in seconds.
    Remarks: Clamps the position to the range from 0 to the music length in seconds.
    """
        get:
            return (_file.CurrentTime.TotalSeconds - BufferSize * 3) % _file.TotalTime.TotalSeconds
        set:
            _fileMutex.WaitOne()
            _rebufferMutex.WaitOne()

            pos = Spectral.Utility.Clamp[of single](value, 0, Length - 0.01f) # The max-value is exclusive, not inclusive.
            _file.CurrentTime = TimeSpan.FromSeconds(pos)
            _rebuffer         = true

            _fileMutex.ReleaseMutex()
            _rebufferMutex.ReleaseMutex()

    IsPlaying as bool:
    """Returns whether the music is currently playing or not."""
        get:
            state as int
            AL.GetSource(_source, ALGetSourcei.SourceState, state)
            return state == ALSourceState.Playing

    private _buffers as (int)
    private _source as int

    private _file as WaveStream
    private _bufferSize as single
    private _format as ALFormat
    private _path as string

    private _thread as Thread
    private _updating as bool
    private _playing as bool
    private _rebuffer as bool

    private _loop as bool
    private _volume as single
    private _pitch as single

    # Mutexes
    private _rebufferMutex as Mutex
    private _fileMutex as Mutex

    protected _disposed as bool

    def constructor(path as string, bufferSize as single):
    """
    Constructor.
    Param path: Path to the music file that has to be buffered.
    Param bufferSize: The amount of music a buffer has to contain in seconds.
    """
        _buffers    = AL.GenBuffers(3)
        _source     = AL.GenSource()
        _bufferSize = bufferSize
        _path       = path

        _loop       = false
        _volume     = 1.0f
        _pitch      = 1.0f

        _updating   = true
        _playing    = false
        _rebuffer   = true

        _disposed   = false

        # Mutexes
        _rebufferMutex  = Mutex()
        _fileMutex      = Mutex()

        # Before we can start, we have to figure out the format.
        using _file = AudioUtility.AudioFileStream(_path):
            _format = AudioUtility.AudioFileFormat(_file)

        _thread = Thread(ThreadStart(Update))
        _thread.Start()

    def Play() as bool:
    """
    Plays the music if it has data in its buffer.
    Remarks: Music will restart at the beginning if already playing. Music will resume if it has been paused.
    Returns: Whether it has started playing music or not.
    """
        Position = 0 if IsPlaying
        _playing = true

        # Wait until any possible rebuffering is done.
        while _rebuffer:
            Thread.Sleep(1)

        AL.SourcePlay(_source) # Resume if the source has not started playing yet.

        return true

    def Pause() as bool:
    """
    Pauses the music if it is playing.
    Returns: Whether the music has been succesfully paused or not.
    """
        return false if not IsPlaying

        AL.SourcePause(_source)

        _playing = false
        return true

    def Stop() as bool:
    """
    Stops the music if it was already playing and resets the positition back to the start.
    Returns: Whether the music has been succesfully stopped.
    """
        return false if not IsPlaying

        AL.SourceStop(_source)

        _playing = false
        Position = 0

        return true

    def Update():
    """
    Peeks at the OpenAL buffers to see which have been processed and have to be refilled with new music data and be requeued again.
    """
        processed as int
        buffer as int
        data as (byte) = array(byte, BytesPerBuffer)
        
        # Keep checking if we need to update the buffer.
        using _file = AudioUtility.AudioFileStream(_path):
            while _updating:
                # If we need to rebuffer because of a position change, or maybe because the music ended.
                numBuffers as int
                AL.GetSource(_source, ALGetSourcei.BuffersQueued, numBuffers)

                if _rebuffer or numBuffers == 0:
                    Rebuffer()
                    continue

                # For each buffer that has been processed, we will empty it and refill it with data and requeue.
                # But only if the sound is playing, otherwise just idle.
                AL.GetSource(_source, ALGetSourcei.BuffersProcessed, processed)

                while(processed > 0 and _playing):
                    buffer = AL.SourceUnqueueBuffer(_source)

                    # If we're at the end of the file, set position to 0 and playing to false.
                    # If we're looping however, we keep on playing.
                    if _file.Read(data, 0, BytesPerBuffer) < BytesPerBuffer:
                        _file.CurrentTime = TimeSpan.FromSeconds(0)

                        unless Looping:
                            _playing = false

                    AL.BufferData(buffer, _format, data, data.Length, _file.WaveFormat.SampleRate)
                    AL.SourceQueueBuffer(_source, buffer)

                    processed--

                Thread.Sleep(1)

    def Dispose():
    """Cleans the allocated resources and cleanly exits the Update() thread."""
        return if _disposed

        _updating = false
        _thread.Join()

        AL.SourceStop(_source)
        AL.DeleteBuffers(_buffers)
        AL.DeleteSource(_source)

        _disposed = true

    private def Rebuffer():
    """Clears the existing buffers from the source, and queues new buffers from the current location. Sort of a flushing."""
        _rebufferMutex.WaitOne()

        # We need to stop the source if it was already playing as we're going to clear out the buffers.
        AL.SourceStop(_source)

        # First, clear out any existing buffers.
        numBuffers as int
        AL.GetSource(_source, ALGetSourcei.BuffersQueued, numBuffers)

        if numBuffers > 0:
            buffers as (int) = array(int, numBuffers)
            AL.SourceUnqueueBuffers(_source, numBuffers, buffers)

        # Reread the buffers and queue them.
        front as (byte)     = array(byte, BytesPerBuffer)
        middle as (byte)    = array(byte, BytesPerBuffer)
        back as (byte)      = array(byte, BytesPerBuffer)

        if _file.Read(front, 0, BytesPerBuffer) < BytesPerBuffer:
            _file.CurrentTime = TimeSpan.FromSeconds(0)

        if _file.Read(middle, 0, BytesPerBuffer) < BytesPerBuffer:
            _file.CurrentTime = TimeSpan.FromSeconds(0)

        if _file.Read(back, 0, BytesPerBuffer) < BytesPerBuffer:
            _file.CurrentTime = TimeSpan.FromSeconds(0)

        AL.BufferData(_buffers[0], _format, front, front.Length, _file.WaveFormat.SampleRate)
        AL.BufferData(_buffers[1], _format, middle, middle.Length, _file.WaveFormat.SampleRate)
        AL.BufferData(_buffers[2], _format, back, back.Length, _file.WaveFormat.SampleRate)

        AL.SourceQueueBuffer(_source, _buffers[0])
        AL.SourceQueueBuffer(_source, _buffers[1])
        AL.SourceQueueBuffer(_source, _buffers[2])

        # Resume if it were playing, as we've stopped it before refilling the buffers.
        if _playing:
            AL.SourcePlay(_source)

        _rebuffer = false
        _rebufferMutex.ReleaseMutex()