namespace Spectral.Test

import System
import Spectral.Audio

class SoundTest(AudioTestCases, IDisposable):
    
    def constructor():
        super()
        Instance = Sound("../test/res/testsound.wav")