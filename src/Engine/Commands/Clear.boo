namespace Spectral.Commands

import System
import Spectral

class Clear(Command):
"""Clears the console."""
    def constructor():
        Command     = "clear"
        Description = "Clears the console."
        Usage       = "clear"

    override def Execute(command as string, engine as Engine):
        pass
        //engine.Gwenterface.Console.Clear()