namespace Spectral.Test

import System
import Spectral.Audio

class MusicTest(AudioTestCases, IDisposable):
    
    def constructor():
        super()
        Instance = Music("../test/res/testsound.wav", 1f)