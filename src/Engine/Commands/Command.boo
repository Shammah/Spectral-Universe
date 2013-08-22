namespace Spectral.Commands

import System
import Spectral

abstract class Command():
"""A command that the CommandCentre can execute for the engine."""

    class CommandException(Exception):
    """Raised whenever a command fails to execute."""

        [Getter(Command)]
        private _command as string

        ///
        /// Constructor.
        /// Param command: The entire issued command.
        /// Param message: The error message.
        ///
        def constructor(command as string, message as string):
            super(message)

            _command = command

    Description as string:
    """A quick description of what the command does."""
        get:
            return _description
        set:
            _description = value

    Usage as string:
    """A small description on how to use the command."""
        get:
            return _usage
        set:
            _usage = value

    Command as string:
    """
    The command itself.
    Remarks: The command will be turned into lowercase.
    Raises ArgumentException: No empty commands allowed.
    """
        get:
            return _command
        set:
            raise ArgumentException("You cannot have an empty command.") if value == String.Empty
            _command = value.ToLower()

    private _command as string
    private _description as string
    private _usage as string

    abstract def Execute(command as string, engine as Engine):
    """
    The function to be called if the command has been issued.
    Param command: The command given.
    Param engine: The engine for which the command was targeted at.
    """
        pass