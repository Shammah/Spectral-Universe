namespace Spectral.Test

import System
import Xunit
import OpenTK.Graphics
import Spectral

class ExitTest:

    [Fact(Timeout: 2000)]
    def Clear():
    """This test should -not- be stuck here."""
        _engine = Engine(800, 600, GraphicsMode(ColorFormat(8, 8, 8, 8 ), 16), "Spectral Exit Command Test")
        _engine.Startup = { _engine.CommandCentre.Execute("exit") }
        _engine.Run()
        _engine.Dispose()