namespace Spectral.Commands

import System
import Spectral

class Exit(Command):
"""Exits the engine."""
    def constructor():
        Command     = "exit"
        Description = "Exits the engine."
        Usage       = "exit"

    override def Execute(command as string, engine as Engine):
        engine.Log.Print("Exiting engine...")
        engine.Exit()