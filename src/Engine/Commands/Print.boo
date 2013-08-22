namespace Spectral.Commands

import System
import Spectral

class Print(Command):
"""Prints a message to the (console) log."""
    def constructor():
        Command     = "print"
        Description = "Prints a message to the (console) log."
        Usage       = "print <string>"

    override def Execute(command as string, engine as Engine):
        args = command.Split(char(' '))

        if args.Length < 2:
            raise CommandException(command, "The command needs something to print.")

        message = command[command.IndexOf(char(' ')) + 1:]
        engine.Log.Print(message)