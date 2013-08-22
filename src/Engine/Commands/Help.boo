namespace Spectral.Commands

import System
import System.Collections.Generic
import Spectral

class Help(Command):
"""Shows a list of available commands and possibibly how to use them."""
    def constructor():
        Command     = "help"
        Description = "Shows a list of available commands and possibibly how to use them."
        Usage       = "help ? - Show's a list of commands.\nhelp <command> - Show's the description and usage of a command."

    override def Execute(command as string, engine as Engine):
        args = command.Split(char(' '))

        if args.Length < 2:
            engine.Log.Print(Usage)
            return

        if args[1] == "?":
            for c as Command in engine.CommandCentre.Commands.Values:
                engine.Log.Print("$(c.Command) - $(c.Description)")

        else:
            try:
                c as Command = engine.CommandCentre.Commands[args[1]]
                engine.Log.Print("$(c.Command) - $(c.Description)\nUsage: $(c.Usage)")
            except ex as KeyNotFoundException:
                engine.Log.Print("Command '$(args[1])' not found!")