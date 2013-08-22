namespace Spectral.Commands

import System
import Spectral

class MusicVolume(Command):
"""Changes the volume of the music."""
    def constructor():
        Command     = "music_volume"
        Description = "Changes the volume of the music."
        Usage       = "music_volume [0, 100]"

    override def Execute(command as string, engine as Engine):
        args = command.Split(char(' '))

        if args.Length < 2:
            raise CommandException(command, "The command needs a volume.")

        volume as single

        unless single.TryParse(args[1], volume):
            raise CommandException(command, "The given argument for volume is not a valid floating point number.")

        if volume < 0 or volume > 100:
            raise CommandException(command, "The volume has to be between 0 and 100.")

        for music in engine.Map.Music.Values:
            music.Volume = volume / 100f

        engine.Log.Print("New music volume: $(args[1]).")

class MusicPitch(Command):
"""Changes the pitch of the music."""
    def constructor():
        Command     = "music_pitch"
        Description = "Changes the volume of the music."
        Usage       = "music_pitch [0.5, 2]"

    override def Execute(command as string, engine as Engine):
        args = command.Split(char(' '))

        if args.Length < 2:
            raise CommandException(command, "The command needs a pitch.")

        pitch as single

        unless single.TryParse(args[1], pitch):
            raise  CommandException(command, "The given argument for pitch is not a valid floating point number.")

        if pitch < 0.5f or pitch > 2.0f:
            raise CommandException(command, "The pitch has to be between 0.5 and 2.")

        for music in engine.Map.Music.Values:
            music.Pitch = pitch

        engine.Log.Print("New music pitch: $(args[1]).")