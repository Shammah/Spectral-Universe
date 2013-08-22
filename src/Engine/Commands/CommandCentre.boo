namespace Spectral

import System
import System.Collections.Generic
import Spectral.Commands

class CommandCentre():
"""Class that manages commands for an engine."""

    Commands as Dictionary[of string, Command]:
    """A dictionary of commands that are present in the CommandCentre. The key is the command name, the value is the command object itself."""
        get:
            return _commands

    Log as Log:
        private get:
            return _engine.Log

    private _engine as Engine
    private _commands as Dictionary[of string, Command]

    def constructor(engine as Engine):
    """
    Constructor.
    Param engine: Reference to the game engine so the CommandCentre knows to which engine to send the commands to.
    Raises NullReferenceException: engine may not be null.
    """
        raise NullReferenceException("The engine you're passing in the constructor is null.") if engine is null

        _engine = engine
        _commands = Dictionary[of string, Command]()

        # Some standard commands provided by our engine :)
        AddCommand(Help())
        AddCommand(Exit())
        AddCommand(Fov())
        AddCommand(Clear())
        AddCommand(MusicVolume())
        AddCommand(MusicPitch())
        AddCommand(Print())

    def AddCommand(command as Command) as bool:
    """
    Add a command to the list of commands.
    Param command: The command to add to the list of commands.
    Returns: True if the command has been added, false otherwise.
    """
        if Commands.ContainsKey(command.Command):
            log "There already exists a command with the exact same syntax.", Log.Level.Error
            return false

        if Commands.ContainsValue(command):
            log "There is already an instance of the same command object in the command centre.", Log.Level.Error
            return false

        _commands.Add(command.Command, command)
        return true

    def RemoveCommand(command as Command) as bool:
    """
    Removes a command from the CommandCentre.
    Param command: The command to be removed.
    Returns: Whether the command has been successfully removed or not.
    """
        return _commands.Remove(command.Command)

    def RemoveCommand(command as string) as bool:
    """
    Removes a command from the CommandCentre by its command name.
    Param command: The command to be removed, indicated by its command name.
    Returns: Whether the command has been successfully removed or not.
    """
        return _commands.Remove(command)

    def Execute(command as string):
    """
    Executes a command to the CommandCentre.
    Param command: The command to execute.
    """
        try:
            c = Commands[command.Split(char(' '))[0].ToLower()]
            c.Execute(command, _engine)

        except ex as KeyNotFoundException:
            log "Command '$command' not found!", Log.Level.Error

        except ex as Command.CommandException:
            log "Failed to execute command '$(ex.Command)': $(ex.Message)", Log.Level.Error