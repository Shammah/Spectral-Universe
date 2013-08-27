import System
import System.IO
import System.Linq
import Boo.Lang.Compiler
import Boo.Lang.Compiler.IO
import Boo.Lang.Compiler.Pipelines

def Main(argv as (string)):
    return unless CompileEngine()
    return unless CompileGame()

    Deploy()

def CompileEngine() as bool:
"""Compiles the engine and puts it in ./lib/SpectralEngine.dll"""

    compiler                       = BooCompiler()
    compiler.Parameters.Pipeline   = CompileToFile()
    compiler.Parameters.OutputType = CompilerOutputType.Library
    compiler.Parameters.Ducky      = true
    compiler.Parameters.LibPaths.Add("./lib")
    compiler.Parameters.OutputAssembly = "./lib/SpectralEngine.dll"

    # Add libraries.
    compiler.Parameters.References.Add(compiler.Parameters.LoadAssembly("OpenTK.dll"))
    compiler.Parameters.References.Add(compiler.Parameters.LoadAssembly("NAudio.dll"))
    compiler.Parameters.References.Add(compiler.Parameters.LoadAssembly("Boo.Lang.dll"))
    compiler.Parameters.References.Add(compiler.Parameters.LoadAssembly("Boo.Lang.Parser.dll"))
    compiler.Parameters.References.Add(compiler.Parameters.LoadAssembly("Boo.Lang.Compiler.dll"))
    
    # Take all boo files from the Engine source directory.
    files = (Directory.GetFiles(Directory.GetCurrentDirectory() + """/src/Engine""", "*.boo", SearchOption.AllDirectories)
                .Where({file as string | return not file.Contains("Gwen")})) # Filter out old GWEN files.

    for file in files:
        print "Adding file: " + file
        compiler.Parameters.Input.Add(FileInput(file))
    
    print "Compiling to ./lib/SpectralEngine.dll"
    context = compiler.Run()

    if context.GeneratedAssembly is null:
        print "Failed to compile:\n" + join(e for e in context.Errors, "\n")
        return false
    else:
        return true

def CompileGame():
"""Compiles the game itself."""
    
    compiler                       = BooCompiler()
    compiler.Parameters.Pipeline   = CompileToFile()
    compiler.Parameters.OutputType = CompilerOutputType.ConsoleApplication
    compiler.Parameters.Ducky      = true
    compiler.Parameters.LibPaths.Add("./lib")
    compiler.Parameters.OutputAssembly = "./bin/SpectralUniverse.exe"

    compiler.Parameters.References.Add(compiler.Parameters.LoadAssembly("SpectralEngine.dll"))
    
    # Take all boo files from the Engine source directory.
    files = (Directory.GetFiles(Directory.GetCurrentDirectory() + """/src/Game""", "*.boo", SearchOption.AllDirectories))

    for file in files:
        print "Adding file: " + file
        compiler.Parameters.Input.Add(FileInput(file))
    
    print "Compiling to ./bin/SpectralUniverse.exe"
    context = compiler.Run()

    if context.GeneratedAssembly is null:
        print "Failed to compile:\n" + join(e for e in context.Errors, "\n")
        return false
    else:
        return true

def Deploy():
    # Copy over neccessary files for deployment.
    File.Copy("./lib/SpectralEngine.dll", "./bin/SpectralEngine.dll", true)
    File.Copy("./lib/OpenTK.dll", "./bin/OpenTK.dll", true)
    File.Copy("./lib/OpenTK.dll.config", "./bin/OpenTK.dll.config", true)
    File.Copy("./lib/NAudio.dll", "./bin/NAudio.dll", true)
    File.Copy("./lib/Boo.Lang.dll", "./bin/Boo.Lang.dll", true)
    File.Copy("./lib/Boo.Lang.Parser.dll", "./bin/Boo.Lang.Parser.dll", true)
    File.Copy("./lib/Boo.Lang.Compiler.dll", "./bin/Boo.Lang.Compiler.dll", true)

    # Copy over a fresh instance of the resources directory.
    Directory.Delete("./bin/Resources", true) if Directory.Exists("./bin/Resources")
    DirectoryCopy("./res", "./bin/Resources", true)

def DirectoryCopy(sourceDirName as string, destDirName as string, copySubDirs as bool):
    raise DirectoryNotFoundException("Source directory does not exist or could not be found: " + sourceDirName) unless Directory.Exists(sourceDirName)

    # Get the subdirectories for the specified directory.
    dir     = DirectoryInfo(sourceDirName)
    dirs    = dir.GetDirectories()

    Directory.CreateDirectory(destDirName) unless Directory.Exists(destDirName) # If the destination directory doesn't exist, create it. 

    # Get the files in the directory and copy them to the new location.
    files   = dir.GetFiles()
    for file as FileInfo in files:
        temppath = Path.Combine(destDirName, file.Name)
        file.CopyTo(temppath, false)

    # If copying subdirectories, copy them and their contents to new location. 
    if copySubDirs:
        for subdir as DirectoryInfo in dirs:
            temppath = Path.Combine(destDirName, subdir.Name)
            DirectoryCopy(subdir.FullName, temppath, copySubDirs)