namespace Spectral

import System
import System.Diagnostics
import System.Collections.Generic
import Boo.Lang.PatternMatching

class Log:
"""
Basic logging class with a nifty timer to time some processes.
"""
    Log as List[of string]:
    """Returns the list of recorded log messages."""
        get:
            return _log

    Engine as Engine:
    """
    Gets and sets the engine that may be attached to the logger.
    Remarks: If a new engine has been set, that engine's console output will be cleared and the entire log history
             will be inserted into the engine console.
    """
        get:
            return _engine
        set:
            if value is not null and (_engine is null or _engine != value):
                _engine = value
                //_engine.Gwenterface.Console.Clear()
                //_engine.Gwenterface.Console.Insert(Log)

    private _sw    as Stopwatch
    private _log as List[of string]
    private _engine as Engine

    enum Level:
    """The level (or priority) of a log message."""
        Info
        Warning
        Error
        Debug

    def constructor():
    """Constructor."""
        _sw        = Stopwatch()
        _log    = List[of string]()

    def Print(str as string):
    """
    Just prints a log message. Default Level is Level.Info.
    Param str: The message itself.
    """
        Print(Level.Info, str, false)

    def Print(l as Level, str as string):
    """
    Just prints a log message.
    Param l The leven of the message.
    Param str: The message itself.
    """
        Print(l, str, false)

    def Print(str as string, timed as bool):
    """
    Just prints a log message. Default Level is Level.Info.
    Param str: The message itself.
    Param timed: Whether you have enabled timing or not.
    """
        Print(Level.Info, str, timed)

    def Print(l as Level, str as string, timed as bool):
    """
    Just prints a log message.
    Param l: The level of the message.
    Param str: The message itself.
    Param timed: Whether you have enabled timing or not.
    """
        output as string

        match l:
            case Level.Info:
                output = "[Info]: "
            case Level.Warning:
                output = "[Warning]: "
            case Level.Error:
                output = "[Error]: "
            case Level.Debug:
                output = "[Debug]: "
            otherwise:
                output = "[Log]: "

        output += str

        if (timed and _sw.IsRunning):
            output += " (" + _sw.ElapsedMilliseconds + " ms)"

        Console.WriteLine(output)
        Log.Add(output)

        //if _engine is not null and _engine.Gwenterface is not null:
        //    _engine.Gwenterface.Console.Print(output)

    def StartTimer():
    """
    Starts the timer in case you wanted to log something and the time it took.
    Remarks: Resets the timer if it was already running.
    """
        _sw.Reset()
        _sw.Start()

    def StopTimer():
    """Stops the timer."""
        _sw.Stop()