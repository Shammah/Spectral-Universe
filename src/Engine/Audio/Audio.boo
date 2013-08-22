namespace Spectral.Audio

import System
import System.Linq
import OpenTK.Audio
import OpenTK.Audio.OpenAL
import NAudio.Wave
import Boo.Lang.PatternMatching

static class AudioUtility():
"""Various audio helper functions."""

    public def AudioFileStream(path as string) as WaveStream:
    """
    Loads an audio file from a path in a wavestream using the corresponding NAudio class.
    Param path: Path to the sound file to load and buffer.
    Raises ArgumentException: Sound file location was empty.
    Raises ArgumentException: Sound file has no file extension (.wav etc).
    Raises NullReferenceException: Sound file location was null.
    Raises FileNotFoundException: The sound file could not be found.
    """
        raise ArgumentException("Sound file path is empty.") if path == String.Empty
        raise NullReferenceException("Sound file path is null.") if path is null

        raise ArgumentException("Sound file has no file extension (.wav etc).") if path.Split(char('.')).Length < 2
        extension as string = path.Split(char('.')).Last()
        file as WaveStream

        match extension:
            case "wav":
                file = WaveFileReader(path)
            case "mp3":
                try:
                    file = Mp3FileReader(path)
                except ex as DllNotFoundException:
                    raise AudioException("Could not find the mp3 .dll decoder, which means you're probably not on Windows. MP3 is at the moment only supported on Windows due licensing issues.")
            otherwise:
                raise AudioException("Audio extension $(extension) is not supported.")

        return file

    public def AudioFileFormat(audio as WaveStream) as ALFormat:
    """
    Returns the OpenAL audio format for playback purposes.
    Param audio: The wavestream of the audio. This can be an instance of AudioFileStream().
    Raises AudioException: Unsupport sound format.
    """
        # Make sure the format is supported by OpenAL.
        format as ALFormat

        if audio.WaveFormat.Channels == 1:
            if audio.WaveFormat.BitsPerSample == 8:
                format = ALFormat.Mono8
            elif audio.WaveFormat.BitsPerSample == 16:
                format = ALFormat.Mono16
            else:
                raise AudioException("Unsupported mono sound. BitsPerSample is neither 8 or 16.")
        elif audio.WaveFormat.Channels == 2:
            if audio.WaveFormat.BitsPerSample == 8:
                format = ALFormat.Stereo8
            elif audio.WaveFormat.BitsPerSample == 16:
                format = ALFormat.Stereo16
            else:
                raise AudioException("Unsupported stereo sound. BitsPerSample is neither 8 or 16.")
        else:
            raise AudioException("Unsupported sound. Number of channels is neither 1 or 2.")

        return format