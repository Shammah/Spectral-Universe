namespace Spectral

import System
import System.IO
import Boo.Lang.Compiler
import Boo.Lang.Compiler.IO
import Boo.Lang.Compiler.Pipelines

class Scripts:
"""Loads and compiles all scripts in /Resources/Scripts/"""

    Assembly as System.Reflection.Assembly:
    """Returns the compiled assembly."""
        get:
            return _context.GeneratedAssembly if _context is not null

    private _compiler as BooCompiler
    private _context as CompilerContext
    
    def constructor():
        _compiler                       = BooCompiler()
        _compiler.Parameters.Pipeline   = CompileToMemory()
        _compiler.Parameters.Ducky      = true

    def Compile():
        # All files boo files in that directory will be compiled.
        files = Directory.GetFiles(Directory.GetCurrentDirectory() + """/Resources/Scripts/""", "*.boo", SearchOption.AllDirectories)

        for file in files:
            print "Adding script: " + file
            _compiler.Parameters.Input.Add(FileInput(file))

        _context = _compiler.Run()

        print join(e for e in _context.Errors, "\n") if _context.GeneratedAssembly is null

    def GetModule(filename as string) as duck:
        return null if Assembly is null

        filename = filename[0].ToString().ToUpper() + filename.Substring(1).Replace(".boo", "") + "Module"
        return Assembly.GetType(filename)