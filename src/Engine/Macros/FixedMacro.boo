import Boo.Lang.Compiler
import Boo.Lang.Compiler.Ast

macro fixed:
    raise "usage: fixed <name>, <ptr_name>: where name references to the variable, and ptr_name to the IntPtr" if len(fixed.Arguments) != 2

    name = ReferenceExpression(fixed.Arguments[0].ToString())
    handle = ReferenceExpression(Context.GetUniqueName(fixed.Arguments[0].ToString(), fixed.Arguments[1].ToString()))
    addr = ReferenceExpression(fixed.Arguments[1].ToString())

    allocate = [|
        $handle = GCHandle.Alloc($name, GCHandleType.Pinned)
        $addr = $handle.AddrOfPinnedObject()
    |]

    free = [| $handle.Free() |]

    yield allocate
    yield fixed.Body
    yield free