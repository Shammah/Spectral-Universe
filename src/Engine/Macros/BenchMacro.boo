import Boo.Lang.Compiler
import Boo.Lang.Compiler.Ast

macro bench:
    raise "usage: bench <message>, |<level>|: <block>" if len(bench.Arguments) < 1

    message = bench.Arguments[0]

    yield [| Log.StartTimer() |]
    yield bench.Body

    if len(bench.Arguments) == 1:
        yield [| Log.Print($message, true); Log.StopTimer() |]
    else:
        level = bench.Arguments[1]
        yield [| Log.Print($level, $message, false); Log.StopTimer() |]