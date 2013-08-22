namespace Spectral.Commands

import System
import Spectral

class Fov(Command):
"""
Changes the camera's horizontal field of view in degrees.
Todo: A fov >= 180 crashes, fovy out of range?
"""
    def constructor():
        Command     = "fov"
        Description = "Changes the camera's horizontal field of view in degrees."
        Usage       = "fov <angle>"

    override def Execute(command as string, engine as Engine):
        args = command.Split(char(' '))

        if args.Length < 2:
            raise CommandException(command, "The command needs an angle in degrees as an argument.")

        fov as single

        unless single.TryParse(args[1], fov):
            raise CommandException(command, "The given argument for degrees is not a valid floating point number.")

        if fov <= 0 or fov >= 180:
            raise CommandException(command, "The fov has to be between 0 and 360.")

        fov = Math.DegreesToRadians(fov)

        engine.Camera.Fov = fov
        engine.Log.Print("New camera FoV: $(args[1]) degrees | $(fov) radians.")