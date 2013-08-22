namespace Universe

import System
import System.IO
import System.Linq
import System.Math as SMath
import System.Threading
import System.Collections.Generic
import OpenTK
import OpenTK.Graphics
import OpenTK.Graphics.OpenGL
import Spectral
import Spectral.Audio
import Spectral.Graphics.Vertices
import NAudio.Dsp

partial class Transformation:
"""This class transforms a sound file from time-domain to frequency domain using a Fast Fourier Transform."""

    private struct TransformationData:
    """Data needed to for the transformation thread."""

        def constructor(_i as uint, _j as uint, _m as uint, _chunkData as (byte), _numChannels as uint):
        """
        Constructor.
        Param _i: The i-th channel.
        Param _j: The j-th transformation.
        Param _m: The 2^m-th sample size.
        Param _chunkData: The data to fetch the channel information from.
        Param _numChannels: The total number of channels.
        """
            i               = _i
            j               = _j
            m               = _m
            chunkData       = _chunkData
            numChannels     = _numChannels

        public i as uint
        public j as uint
        public m as uint
        public chunkData as (byte)
        public numChannels as uint

    Samples as uint:
    """Returns the number of samples used for each transform."""
        get:
            return _samples

    SampleRate as uint:
    """Returns the samplerate of the original audio."""
        get:
            return 0 unless Transformed
            return _sampleRate

    Channels as uint:
    """Returns the number of channels the data consists of after any possible downsampling."""
        get:
            return 0 unless Transformed
            return len(Data, 0)

    OriginalChannels as uint:
    """Returns the original number of channels the data consists of before any possible downsampling."""
        get:
            return 0 unless Transformed
            return _originalChannels

    Transforms as uint:
    """The amount of Fourier transforms for each channel after any possible downsampling."""
        get:
            return 0 unless Transformed
            return len(Data, 1)

    OriginalTransforms as uint:
    """The original amount of Fourier transforms for each channel before any possible downsampling."""
        get:
            return 0 unless Transformed
            return _originalTransforms

    Bins as uint:
    """Returns the number of bins produced by a fourier transform with real data after any possible downsampling."""
        get:
            return 0 unless Transformed
            return len(Data, 2)

    OriginalBins as uint:
    """Returns the original number of bins produced by a fourier transform with real data before any possible downsampling."""
        get:
            return 0 unless Transformed
            return _originalBins

    Transformed as bool:
    """Whether the class instance has transformed data."""
        get:
            return (Data is not null)

    Data as (single, 3):
    """Returns the amplitudes of a transformation. The first index is the i-th channel, the second is the j-th transformation."""
        get:
            return _data

    Length as uint:
    """The length of the total transformation in seconds."""
        get:
            return _length

    private _samples as uint
    private _sampleRate as uint
    private _data as (single, 3)
    private _length as uint

    private _originalBins as uint
    private _originalTransforms as uint
    private _originalChannels as uint

    def constructor():
    """Constructor."""
        _samples = 0
        _levels = null

    def Transform(path as string, begin as uint, end as int, samples as uint):
    """
    Performs a Fourier transform on an audio file.
    Param path: Location to the audio file.
    Param begin: The starting location of the audio file in seconds.
    Param end: The end location of the audio file in seconds. -1 Denotes to the EOF.
    Param samples: The number of samples per transformation.
    Raises IOException: Unsupported format, or error in reading the file.
    Raises ArgumentException: end >= 0 => end > begin.
    """
        raise ArgumentException("End has to be bigger than begin.") if end <= begin and end >= 0

        # The sample size has to be a power of 2.
        unless samples > 1 and (samples & (samples - 1)) == 0:
            raise ArgumentException("The block of samples for the transformation is not a power of 2.")

        _samples = samples

        # Read the audio file.
        using audio = AudioUtility.AudioFileStream(path):
            raise IOException("For now, only music with a samplesize of 16 bits per sample is supported.") if audio.WaveFormat.BitsPerSample / 8 != 2
            raise ArgumentException("The ending location is beyond the length of the audio length.") if end > audio.TotalTime.TotalSeconds

            bytesPerSample      = audio.WaveFormat.BitsPerSample / 8
            bytesPerSecond      = audio.WaveFormat.AverageBytesPerSecond
            numChannels         = audio.WaveFormat.Channels
            _sampleRate         = audio.WaveFormat.SampleRate

            bins                = samples / 2 + 1
            chunkSize           = samples * bytesPerSample * numChannels

            # How many Fourier transforms for each channel.
            if end >= 0:
                transforms      = bytesPerSecond * (end - begin) / numChannels / (samples * bytesPerSample)
                _length         = end - begin
            else:
                transforms      = (audio.Length - (bytesPerSecond * begin)) / numChannels / (samples * bytesPerSample)
                _length         = audio.TotalTime.TotalSeconds - begin

            # Set the initial size of our data array so it fits all data.
            _data               = matrix(single, numChannels, transforms, bins)
            _originalBins       = Bins
            _originalTransforms = Transforms
            _originalChannels   = Channels

            # Needed value for NAudio's FFT. This calculates x for the equation 2^x = samples
            m as int            = SMath.Log(samples, 2)

            # Place the seeker at the beginning of our segment.
            audio.CurrentTime   = TimeSpan.FromSeconds(begin)

            # We need need to read in as many chunks of data as we need to transform.
            for j in range(0, transforms):
                chunkData       = array(byte, chunkSize)
                raise IOException("Readed chunk's size does not match expected chunksize.") if audio.Read(chunkData, 0, chunkSize) != chunkSize

                # Create and start the thread for each channel to transform the data.
                for i in range(0, numChannels):
                    data as object = TransformationData(i, j, m, chunkData, numChannels)
                    TransformChannel(data)

    def Transform(path as string, samples as uint):
    """
    Performs a Fourier transform on an audio file.
    Param path: Location to the audio file.
    Param samples: The number of samples per transformation.
    Raises IOException: Unsupported format, or error in reading the file.
    """
        Transform(path, 0, -1, samples)

    private def TransformChannel(ref data as object):
    """
    Transformates a single channel.
    Param data: A TransformationData object casted as System.Object. Conatins all the data this function needs.
    """
        tdata = (data cast TransformationData)

        # Our FFT expects an array of Complex as its input.
        channelData = (GetChannelSingle(tdata.i, tdata.chunkData, tdata.numChannels)
                        .Select({x | c = Complex(); c.X = x; c.Y = 0.0f; return c})
                        .ToArray())

        # Perform the actual FFT.
        FastFourierTransform.FFT(true, tdata.m, channelData)

        # Copy the bins of the transformed chunk over into the output data matrix.
        for k in range(0, Bins):
            _data[tdata.i, tdata.j, k] = 20.0f * SMath.Log(SMath.Sqrt(channelData[k].X ** 2 +
                                                                      channelData[k].Y ** 2), 10f) + 100f

    def Normalize():
    """
    Normalizes the data.
    Raises Exception: There has to be transformed data.
    """
        raise "You have not yet transformed the data!" unless Transformed
        
        for i in range(0, Channels):
            NormalizeChannel(i)

    private def NormalizeChannel(channel as uint):
    """
    Normalizes 1 channel.
    Param channel: The channel to normalize.
    Raises Exception: There has to be transformed data.
    Raises ArgumentException: The channel has to be within boundaries.
    """
        raise "You have not yet transformed the data!" unless Transformed
        raise ArgumentException("Channel not within boundaries.") if channel >= Channels

        max = ChannelMax(channel)

        for j in range(0, Transforms):
            for k in range(0, Bins):
                Data[channel, j, k] = Utility.Clamp[of single](Data[channel, j, k] / max, 0.0f, 1.0f)

    def ChannelMax(channel as uint) as single:
    """
    Returns the maximum value of a channel.
    Param channel: The channel to find the maximum value of.
    Raises Exception: There has to be transformed data.
    Raises ArgumentException: The channel has to be within boundaries.
    """
        raise "You have not yet transformed the data!" unless Transformed
        raise ArgumentException("Channel not within boundaries.") if channel >= Channels

        max = System.Single.MinValue

        for j in range(0, Transforms):
            for k in range(0, Bins):
                max = Data[channel, j, k] if Data[channel, j, k] > max

        return max

    def GaussianBlur(dev as single):
    """
    Unleashes a two-pass gaussian blur upon the data.
    Param dev: The standard deviation to be used by the gaussian blur formula.
    Raises Exception: There has to be transformed data.
    """
        raise "You have not yet transformed the data!" unless Transformed

        gaussian = {x as single, d as single | return (1 / (SMath.Sqrt(Spectral.Math.Tau) * d) * SMath.Pow(SMath.E, -1 * ((x ** 2) / 2 * d ** 2)))}
        x0          = gaussian(0, dev)
        x1          = gaussian(1, dev)

        temp1 as single
        temp2 as single

        # Blur left and right first over the time axis.
        for i in range(0, Channels):
            for k in range(1, Bins - 1):
                temp1 = Data[i, 0, k]

                for j in range(1, Transforms - 1):
                    temp2 = Data[i, j, k]        # Save current middle position.
                    _data[i, j, k] = x0 * Data[i, j, k] + x1 * Data[i, j + 1, k] + x1 * temp1
                    temp1 = temp2                # The previous element of the next round will be the left one of the old round.

        # Blur up and down over the frequency axis.
        for i in range(0, Channels):
            for j in range(1, Transforms - 1):
                temp1 = Data[i, j, 0]

                for k in range(1, Bins - 1):
                    temp2 = Data[i, j, k]        # Save current middle position.
                    _data[i, j, k] = x0 * Data[i, j, k] + x1 * Data[i, j, k + 1] + x1 * temp1
                    temp1 = temp2                # The previous element of the next round will be the one below of the old round.

    def Downsample(stepI as uint, stepJ as uint, stepK as uint):
    """
    Copies the data and replaces it, only with a variable stepsize in order to downsample.
    Param stepI: The step size for the channelnumber. (Entire channels)
    Param stepJ: The step size for the transform number. (Time samples)
    Param stepK: The step size for the sample number. (Frequency bins)
    Raises Exception: There has to be transformed data.
    Raises ArgumentException: All values must be bigger than or equal to 1.
                              All values cannot be bigger than the index of the corresponding step factor.
    """
        raise "You have not yet transformed the data!" unless Transformed
        raise ArgumentException("All values must be bigger than or equal to 1.") if stepI <= 0 or stepJ <= 0 or stepK <= 0
        raise ArgumentException("Step value can not be bigger than the corresponding step factor.") if stepI > Channels or stepJ > Transforms or stepK > Bins

        asize = SMath.Ceiling(Channels cast single / stepI)
        bsize = SMath.Ceiling(Transforms cast single / stepJ)
        csize = SMath.Ceiling(Bins cast single / stepK)
        data = matrix(single, asize, bsize, csize)

        a as uint = 0
        b as uint = 0
        c as uint = 0

        for i in range(0, Channels, stepI):
            for j in range(0, Transforms, stepJ):
                for k in range(0, Bins, stepK):
                    data[a, b, c] = Data[i, j, k]
                    c = (c + 1) % csize
                b = (b + 1) % bsize
            a++

        _data = data

    def CreateHeatMap(path as string, channelNr as uint):
    """
    Creates a heatmap for debugging purposes like GNUPlot.
    Param path: File to save the data to.
    Param channelNr: The channel number to export, starting at 0.
    Raises Exception: There has to be transformed data.
    Raises IndexOutOfRangeException: There is no such channel number in the data.
    """
        raise "You have not yet transformed the data!" unless Transformed
        raise IndexOutOfRangeException("Channel number is out of bounds") if channelNr >= Channels

        using sw = StreamWriter(path):
            for j in range(0, Transforms, 2):
                for k in range(0, Bins, 2):
                    sw.WriteLine("$(j cast single / Transforms) $(k cast single / Bins) $(Data[channelNr, j, k])")

    def CreateSpectralModel() as (VertexNormal1D):
    """
    Creates a model for the Spectral Engine.
    Raises Exception: There has to be transformed data.
    Returns: An array of vertices to be drawn as seperate quads.
    """
        raise "You have not yet transformed the data!" unless Transformed

        transforms as single = Transforms
        bins as single          = Bins
        vertices              = array(VertexNormal1D, (transforms - 1) * (bins - 1) * 4)
        vCounter              = 0

        data = AverageChannels()

        for j in range(0, transforms - 1):
            for k in range(0, bins - 1):

                # Calculate the 4 vector points.
                v0 = Vector3(j cast single / transforms,       data[j    , k],           k cast single / bins)        # Lower left.
                v1 = Vector3(j cast single / transforms,        data[j    , k + 1], (k + 1) cast single / bins) # Upper left.
                v2 = Vector3((j + 1) cast single / transforms, data[j + 1, k + 1], (k + 1) cast single / bins) # Upper right.
                v3 = Vector3((j + 1) cast single / transforms, data[j + 1, k],           k cast single / bins)        # Lower right.

                # Calculate the normal by averaging the normal of all 4 vertices.
                n0 = Vector3.Cross(v3 - v0, v1 - v0) # Normal lower left.
                n1 = Vector3.Cross(v0 - v1, v2 - v1) # Normal upper left.
                n2 = Vector3.Cross(v1 - v2, v3 - v2) # Normal upper right.
                n3 = Vector3.Cross(v2 - v3, v0 - v3) # Normal lower right.
                n  = -Vector3.Normalize(n0 + n1 + n2 + n3)

                # The colour is the average height of all 4 vertices.
                # I assume the data to be normalized in [0, 1].
                c  = (v0.Y + v1.Y + v2.Y + v3.Y) / 4f

                # Add the 4 vertices (quad) to the array.
                vertices[vCounter++] = VertexNormal1D(v0, n, c)
                vertices[vCounter++] = VertexNormal1D(v1, n, c)
                vertices[vCounter++] = VertexNormal1D(v2, n, c)
                vertices[vCounter++] = VertexNormal1D(v3, n, c)

        return vertices

    private def AverageChannels() as (single, 2):
    """
    Takes the average of each channel.
    Raises Exception: There has to be transformed data.
    Returns: A new double matrix with the average amplitude of all channels for each transformation and sample.
    """
        raise "You have not yet transformed the data!" unless Transformed

        transforms  = Transforms
        bins         = Bins
        channels     = Channels
        data = matrix(single, transforms, bins)

        for j in range(0, transforms):
            for k in range(0, bins):
                sum as single = 0

                for i in range(0, channels):
                    sum += Data[i, j, k]

                data[j, k] = sum / channels

        return data

    private def GetChannelSingle(n as uint, data as (byte), numChannels as uint) as IEnumerable[of single]:
    """
    Extracts a single channel from all the audio data in single format in the range [-1, 1].
    Remarks: The data is assumed to be encoded in 16 bits per sample.
    Param n: The 0-based channel number, which has to be smaller than numChannels.
    Param data: The raw sound data.
    Param numChannels: The total number of channels in the data.
    Returns: An array of raw audio data for the n-th channel in single format.
    Raises ArgumentException: n has to be smaller than numChannels.
    """
        channel   = GetChannel(n, data, numChannels, 2).ToArray()
        converted = array(short, channel.Length)
        Buffer.BlockCopy(channel, 0, converted, 0, channel.Length)

        return converted.Select({x | (x cast single) / Int16.MinValue})

    private def GetChannel(n as uint, data as (byte), numChannels as uint, bytesPerSample as uint) as IEnumerable[byte]:
    """
    Extracts a single channel from all the audio data.
    Param n: The 0-based channel number, which has to be smaller than numChannels.
    Param data: The raw sound data.
    Param numChannels: The total number of channels in the data.
    Param bytesPerSample: The number of bytes per sample per channel.
    Returns: An array of raw audio data for the n-th channel.
    Raises ArgumentException: n has to be smaller than numChannels.
    """
        raise ArgumentException("n has to be smaller than numChannels.") if n >= numChannels

        return (data.Skip(bytesPerSample * n)
                    .Where({x, i | i % (numChannels * bytesPerSample) < bytesPerSample}))