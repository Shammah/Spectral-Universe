namespace Universe

import Boo.Lang.PatternMatching

partial class Transformation:
"""This class transforms a sound file from time-domain to frequency domain using a Fast Fourier Transform."""

    class FrequencyLevels:
    """
    Levels for 6 frequency ranges:
        - SubSonics: 20Hz-40Hz
        - SubBass: 40Hz-100Hz
        - Bass: 100Hz-300Hz
        - LowerMids: 300Hz-1000Hz
        - UpperMids: 1000Hz-8000Hz
        - Treble: 8000Hz-20000Hz
    """
        SubSonics as double:
        """SubSonics: 20Hz-40Hz"""
               get:
                   return _subSonics

        SubBass as double:
        """SubBass: 40Hz-100Hz"""
            get:
                return _subBass

        Bass as double:
        """Bass: 100Hz-300Hz"""
            get:
                return _bass

        LowerMids as double:
        """LowerMids: 300Hz-1000Hz"""
            get:
                return _lowerMids

        UpperMids as double:
        """UpperMids: 1000Hz-8000Hz"""
            get:
                return _upperMids

        Treble as double:
        """Treble: 8000Hz-20000Hz"""
            get:
                return _treble

        Total as double:
        """Total level of all frequency ranges."""
            get:
                return SubSonics + SubBass + Bass + LowerMids + UpperMids + Treble

        Average as double:
        """Returns the average value of all levels."""
            get:
                return _average

        Variance as double:
        """Return the variance between the levels."""
            get:
                return _variance

        StdDev as double:
        """Returns the standard deviation of the levels."""
            get:
                return _stdev

        private _subSonics as double
        private _subBass as double
        private _bass as double
        private _lowerMids as double
        private _upperMids as double
        private _treble as double

        private _average as double
        private _variance as double
        private _stdev as double

        def constructor():
        """Constructor. Initializes everything to 0."""
            self(0, 0, 0, 0, 0, 0)

        def constructor(subSonics as double, subBass as double, bass as double, lowerMids as double, upperMids as double, treble as double):
        """
        Constructor.
        Param subSonics: 20Hz-40Hz
        Param subBass: 40Hz-100Hz
        Param bass: 100Hz-300Hz
        Param lowerMids: 300Hz-1000Hz
        Param upperMids: 1000Hz-8000Hz
        Param treble: 8000Hz-20000Hz
        """
            _subSonics  = subSonics
            _subBass    = subBass
            _bass       = bass
            _lowerMids  = lowerMids
            _upperMids  = upperMids
            _treble     = treble

            _average    = CalcAverage()
            _variance   = CalcVariance()
            _stdev      = CalcStdDev()

        override def ToString():
            subSonics       = "SubSonics:\t$(SubSonics)\n"
            subBass         = "SubBass:\t$(SubBass)\n"
            bass            = "Bass:\t\t$(Bass)\n"
            lowerMids       = "LowerMids:\t$(LowerMids)\n"
            upperMids       = "UpperMids:\t$(UpperMids)\n"
            treble          = "Treble:\t\t$(Treble)\n"
            total           = "----------\nTotal:\t\t$(Total)\n"

            return subSonics + subBass + bass + lowerMids + upperMids + treble + total

        private def CalcAverage():
        """Calculates the average of all levels."""
            return (SubSonics + SubBass + Bass + LowerMids + UpperMids + Treble) / 6.0

        private def CalcVariance():
        """Calculates the variance between the levels."""
            average     = CalcAverage()

            sum         = (SubSonics  - average) ** 2
            sum        += (SubBass    - average) ** 2
            sum        += (Bass       - average) ** 2
            sum        += (LowerMids  - average) ** 2
            sum        += (UpperMids  - average) ** 2
            sum        += (Treble     - average) ** 2

            return sum / 6.0

        private def CalcStdDev():
        """Returns the standard deviation between the levels."""
            return System.Math.Sqrt(CalcVariance())

        def ZScore(x as double):
        """
        Returns the Z-Score of a value in contrast to the levels.
        Param x: The value to calculate the Z-Score for.
        """
            return (x - Average) / StdDev

    Levels as (FrequencyLevels):
    """Returns the level data of frequency ranges after a transformation."""
        get:
            GenerateStatistics() if _levels is null
            return _levels

    BinRange as single:
    """Returns the frequency range of each bin."""
        get:
            return (SampleRate cast single / Samples cast single) * (OriginalBins cast single / Bins cast single)

    private _levels as (FrequencyLevels)

    def GenerateStatistics():
    """Generate as much statistics as possible to make publicly available, so we can do fun stuff with it."""
        return unless Transformed # Gathering stats when there has been no transformation is pointless.

        binRange        = BinRange
        _levels         = array(FrequencyLevels, Transforms)

        # These indices determine the last (exclusive) bin index which belongs to that frequency range.
        subSonicsIndex  = System.Math.Floor(40f   / binRange) + 1
        subBassIndex    = System.Math.Floor(100f  / binRange) + 1
        bassIndex       = System.Math.Floor(300f  / binRange) + 1
        lowerMidsIndex  = System.Math.Floor(1000f / binRange) + 1
        upperMidsIndex  = System.Math.Floor(8000f / binRange) + 1

        # Total volume levels for each frequency level.
        subSonics = subBass = bass = lowerMids = upperMids = treble = 0.0f

        # I did a quick benchmark, and summing is apparantly faster using threads. We'll see if this is needed later.
        # Therefore, we add a TODO mark here for any future optimizations.
        # We are generating stats per transform, thus we start with a loop of j transforms, we then start summing by i channels.
        for j in range(0, Transforms):
            for i in range(0, Channels):

                # Instead of checking for ranges, we just create some extra loops. We have a static number of ranges anyway.
                for k in range(0, subSonicsIndex):
                    subSonics   += Data[i, j, k]

                for k in range(subSonicsIndex, subBassIndex):
                    subBass     += Data[i, j, k]

                for k in range(subBassIndex, bassIndex):
                    bass        += Data[i, j, k]

                for k in range(bassIndex, lowerMidsIndex):
                    lowerMids   += Data[i, j, k]

                for k in range(lowerMidsIndex, upperMidsIndex):
                    upperMids   += Data[i, j, k]

                for k in range(upperMidsIndex, Bins):
                    treble      += Data[i, j, k]

            # We will divide by channel, to make the numbers more comprehensible. We don't need per-channel information atm anyway.
            subSonics /= Channels cast double
            subBass   /= Channels cast double
            bass      /= Channels cast double
            lowerMids /= Channels cast double
            upperMids /= Channels cast double
            treble    /= Channels cast double

            # We have the levels for a transformation.
            _levels[j] = FrequencyLevels(subSonics, subBass, bass, lowerMids, upperMids, treble)

            # Reset the values back to 0 for the next possible iteration.
            subSonics = subBass = bass = lowerMids = upperMids = treble = 0.0f