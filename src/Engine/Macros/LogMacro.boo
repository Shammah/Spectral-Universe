import Boo.Lang.Compiler
import Boo.Lang.Compiler.Ast

macro log:
    raise "usage: log <message>, |<level>|" if len(log.Arguments) < 1

    message = log.Arguments[0]

    if len(log.Arguments) == 1:
        yield [| Log.Print(Log.Level.Info, $message, false) |]
    else:
        level = log.Arguments[1]
        yield [| Log.Print($level, $message, false) |]