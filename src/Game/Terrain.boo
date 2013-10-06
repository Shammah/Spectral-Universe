namespace Universe

import System
import System.Threading
import System.Collections.Generic
import OpenTK
import OpenTK.Graphics.OpenGL
import Spectral
import Spectral.Audio
import Spectral.Graphics
import Spectral.Graphics.Vertices
import Spectral.Graphics.Textures
import Spectral.Log
import Universe.Programs

class Terrain(IDisposable):
"""Terrain manager for Spectral Universe."""

    Log as Log:
    """Log for macro purposes."""
        get:
            return _map.Engine.Log

    Width as single:
    """The width (along frequency bins) of a chunk."""
        get:
            return _terrainSize

    Length as single:
    """The length (along transformations) of a chunk."""
        get:
            return _terrainSize / _ratio

    Height as single:
    """The length (along amplitudes) of a chunk."""
        get:
            return _terrainSize * 0.2

    Playing as bool:
    """Returns whether the music and terrain are playing or not."""
        get:
            return _playing

    Music as Music:
    """Returns the music instance coupled with the terrain."""
        get:
            return _music

    Speed as single:
    """The movement speed of the terrain."""
        get:
            return Length / _bufferSize * 10

    CurrentTransformation as Transformation:
    """Returns the transformation of the front chunk."""
        get:
            return _chunks[(_index - _chunks.Length) % _chunks.Length].Transformation

    # Buffers & file.
    private _chunks as (TerrainMesh)
    private _file as string
    private _index as uint

    # Threading.
    private _chunkQueue as Queue[of Tuple[of Transformation, (VertexNormal1D)]]
    private _chunkRequests as uint
    private _thread as Thread
    private _running as bool

    # Mutexes
    private _chunkRequestsMutex as Mutex
    
    # Terrain properties.
    private _bufferSize as uint
    private _length as single
    private _samples as uint
    private _position as uint
    private _ratio as single
    private _playing as bool

    # Map properties.
    private _map as Map
    private _terrainSize as single

    # Music!
    private _music as Music

    protected _disposed as bool

    def constructor(m as Map, file as string, bufferSize as uint, samples as uint, terrainSize as single):
    """
    Creates terrain!
    Param m: The map for which the terrain will be.
    Param file: Location to the audio file to terrainify.
    Param bufferSize: The amount of seconds each chunk should contain data for.
    Param samples: The number of samples to be processed for the FFT.
    Param terrainSize: The size of the terrain.
    Raises NullReferenceException: Map may not be null.
    Raises ArgumentException: The file path cannot be empty.
    Raises ArgumentException: The terrain size should be positive.
    """
        raise NullReferenceException("Map cannot be null.") if m is null
        raise ArgumentException("File path cannot be empty.") if file == String.Empty
        raise ArgumentException("The terrain size should be positive.") if terrainSize <= 0

        _map                = m
        _file               = file
        _bufferSize         = bufferSize
        _samples            = samples
        _terrainSize        = terrainSize
        _playing            = false

        # Mutexes
        _chunkRequestsMutex = Mutex()

        using audio = AudioUtility.AudioFileStream(file):
            _length         = audio.TotalTime.TotalSeconds

        _index              = 0
        _position           = 0
        _chunks             = array(TerrainMesh, 3) # A triple buffer should suffice.

        _chunkRequests      = _chunks.Length
        _chunkQueue         = Queue[of Tuple[of Transformation, (VertexNormal1D)]]()
        _running            = true

        for i in range(0, _chunks.Length):
            bench "Generated terrain chunk...", Level.Debug:
                GenerateChunk()
                AddChunk()

        _thread             = Thread(ThreadStart(ChunkThread))
        _thread.Priority    = ThreadPriority.Lowest
        _thread.Start()

        _music = Music(file, 5f)
        _disposed = false

    def Update(elapsedTime as single):
    """
    Updates the terrain for a given amount of seconds.
    Param elapsedTime: The number of seconds since the last update.
    """
        lock _chunks:
            for chunk in _chunks:

                # Move the chunk if possible.
                if chunk is not null:
                    chunk.Position -= Vector3(Speed * elapsedTime, 0, 0) if _playing

                    # Do we need to generate a new chunk?
                    # We need a new chunk if the end of one buffer has gone beyond the X-axis origin: 0.
                    # Todo: Add a bit of offset before dissapearing, because the camera is behind and 
                    # may spot a sudden piece of terrain disappearing.
                    if chunk.Position.X <= -Length:
                        chunk.Dispose()
                        chunk = null
                        _chunkRequestsMutex.WaitOne()
                        _chunkRequests++
                        _chunkRequestsMutex.ReleaseMutex()

        # Check the chunk queue, and process one chunk if there is one in the queue to be added.
        AddChunk() if _chunkQueue.Count > 0

    private def GenerateChunk():
    """
    Generates a chunk of terrain.
    Remarks: If the buffer exceeds the audio length, just return nothing.
    Adds the newly processed model to the _chunkQueue, and reduces the number of _chunkRequests by 1.
    """
        # Don't do anything if we're at the end of file.
        return if _position + _bufferSize > _length

        # Create raw terrain data from a piece of the audio file.
        t as Transformation = Transformation()
        t.Transform(_file, _position, _position + _bufferSize, _samples)
        t.GenerateStatistics()

        t.Downsample(1, 1, 2)

        for i in range(3):
            t.GaussianBlur(0.8f)

        t.Normalize()
        _ratio              = t.Bins cast single / t.Transforms cast single

        # Create the model and set rendermode to quads.
        lock _chunkQueue:
            _chunkQueue.Enqueue(Tuple[of Transformation, (VertexNormal1D)](t, t.CreateSpectralModel()))

        # One request has been processed!
        _chunkRequestsMutex.WaitOne()
        _chunkRequests--
        _chunkRequestsMutex.ReleaseMutex()

    private def AddChunk():
    """
    Adds a chunk by creating its actor and adding it to the map.
    Remarks: If there are no chunks in the _chunkQueue, the function will return immediatly.
    """
        # Create the model from the raw chunk data
        lock _chunkQueue:
            return if _chunkQueue.Count <= 0
            chunkData       = _chunkQueue.Dequeue()
            transformation  = chunkData.Item1
            modelData       = chunkData.Item2

            model           = Model[of VertexNormal1D](modelData)
            model.Mode      = BeginMode.Quads

        # Generate the offset.
        offset = 0
        lock _chunks:
            for chunk in _chunks:
                offset = chunk.Position.X + Length if chunk is not null and chunk.Position.X >= offset

        # Create the actor, scale and locate it and set it to the map.
        chunk               = TerrainMesh("Terrain/Chunk/" + _position, model, transformation)
        chunk.Model.Texture = Texture1D("./Resources/Textures/Game/terrain.png")
        chunk.Model.Program = TerrainProgram()
        chunk.Scale         = Vector3(Length, Height, Width)
        chunk.Position      = Vector3(offset, 0, 0)
        chunk.Map           = _map

        # Get rid of the old chunk, add a new one and increment the buffer index.
        _chunks[_index++]     = chunk

        # Set the index back to 0 if it exceeded the circular's buffer length.
        _index %= _chunks.Length
        _position += _bufferSize

    private def ChunkThread():
    """This thread will occasionally check for a new chunk."""
        while _running:
            GenerateChunk() if _chunkRequests > 0
            Thread.Sleep(1)

    def Play():
    """Plays the music and sets the terrain moving."""
        _playing = true
        _music.Play()

    def Pause():
    """Pauses the music and the terrain movement."""
        _playing = false
        _music.Pause()

    def Dispose():
    """Stops the thread from running and disposes chunks if not disposable by map."""
        return if _disposed

        _running = false
        _thread.Join()

        _music.Dispose()

        for chunk in _chunks:
            chunk.Dispose() if chunk is not null and chunk.Map is null

        _disposed = true