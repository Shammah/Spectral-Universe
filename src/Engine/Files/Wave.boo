namespace Spectral

import System
import System.IO

class Wave:
"""This class is based on the canonical WAVE form as described by the webpage of: https://ccrma.stanford.edu/courses/422/projects/WaveFormat/"""

    Data as (double):
    """The raw file data in double"""
        get:
            dataSize    = (SampleSize / NumChannels) // How big is one sample of one channel in bytes?
            temp       = array(short, ByteData.Length / dataSize)
            data       = array(double, ByteData.Length / dataSize)
            Buffer.BlockCopy(ByteData, 0, temp, 0, ByteData.Length)

            for i in range(0, temp.Length):
                data[i] = temp[i]

            return data

    /// Raw data in bytes.
    [Getter(ByteData)]
    private _byteData as (byte)

    /// Returns the number of channels. 1 = mono, 2 = stereo, etc ...
    [Getter(NumChannels)]
    private _numChannels as int

    /// Returns the sample rate, eg 8000 or 44100
    [Getter(SampleRate)]
    private _sampleRate as int

    /// The number of bits of each sample, eg 8 bit or 16 bit
    [Getter(BitsPerSample)]
    private _bitsPerSample as int

    /// A value of 1 means Linair Quantization (PCM), which is uncompressed
    [Getter(AudioFormat)]
    private _audioFormat as int

    # The total size in bytes of the actual sound data
    private _subchunk2Size as int

    NumSamples as int:
    """The total number of samples in the entirety of the sound file."""
        get:
            return (_subchunk2Size / NumChannels / BitsPerSample * 8)

    ByteRate as int:
    """The byterate of the file; the number of bytes per second."""
        get:
            return (SampleRate * NumChannels * BitsPerSample / 8)

    SampleSize as int:
    """The total size of a single sample, for all channels, in bytes."""
        get:
            return (NumChannels * BitsPerSample / 8);

    def constructor(path as string):
    """Constructor."""
        LoadFile(path)

    private def LoadFile(path as string):
    """
    Loads an entire .wav file from a given path location.
    Remarks: Loaded data will be loaded into the Data property
    Param path: Path to the .wav file to load.
    """
        unless File.Exists(path):
            raise FileNotFoundException("Could not find the .wav file: " + path + ".")

        file as FileStream = null

        try:
            file               = File.Open(path, FileMode.Open)
            raise FileLoadException(path + " is smaller than 44 bytes, thus can't be a valid .wav file") if (file.Length < 44)

            data               = array(byte, file.Length)
            bytesToRead as int = file.Length
            bytesRead   as int = 0

            # Keep on reading until everything has been read
            while (bytesToRead > 0):
                read as int  = file.Read(data, bytesRead, bytesToRead)
                bytesToRead -= read
                bytesRead   += read

            # A quick check to see if this really is a .wav file
            if (System.Text.Encoding.UTF8.GetString(data[8:12])   != "WAVE" or
                System.Text.Encoding.UTF8.GetString(data[:4])     != "RIFF" or
                System.Text.Encoding.UTF8.GetString(data[12:16])  != "fmt " or
                System.Text.Encoding.UTF8.GetString(data[36:40])  != "data"):
                raise FileLoadException(path + " is not a proper .wav file!")

            # Fill in the file properties
            _numChannels    = BitConverter.ToInt16(data[22:24], 0)
            _sampleRate     = BitConverter.ToInt32(data[24:28], 0)
            _bitsPerSample  = BitConverter.ToInt16(data[34:36], 0)
            _subchunk2Size  = BitConverter.ToInt32(data[40:44], 0)
            _audioFormat    = BitConverter.ToInt16(data[20:22], 0)
            _byteData       = data[44:]

        except ex:
            raise ex

        ensure:
            if file is not null:
                file.Close() 
                file.Dispose()

    override def ToString() as string:
        s1 = "Channels: \t\t" + NumChannels + "\n"
        s2 = "Sample rate: \t\t" + SampleRate + " Hz\n"
        s3 = "Bits per sample: \t" + BitsPerSample + "\n"
        s4 = "Byte rate: \t\t" + ByteRate + " bytes/s\n"
        s5 = "AudioFormat: \t\t" + AudioFormat + "\n"
        s6 = "Sample size: \t\t" + SampleSize + " bytes\n"
        s7 = "Number of samples: \t" + NumSamples + "\n"

        return (s1 + s2 + s3 + s4 + s5 + s6 + s7)

    def GetChannel(channelNr as int) as (double):
    """
    Returns the raw sound data for a given channel as an array of floating point values between -1.0f and 1.0f.
    Param channelNr: The channel number, with a minimal value of 1 (mono).
    """
        raise ArgumentException("The given channel number has to be at least 1.") if channelNr < 1
        raise ArgumentException("There are only " + NumChannels + " sound channels, you asked for number " + channelNr + "?") if channelNr > NumChannels

        samples as (double) = Data
        output as (double) = array(double, samples.Length / NumChannels)

        for i in range(channelNr - 1, output.Length):
            output[i] = samples[channelNr - 1 + i * NumChannels]

        return output