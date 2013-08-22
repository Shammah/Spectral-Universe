namespace Spectral.Audio

import System

interface IAudio(IDisposable):
"""Basic audio interface, which should work no matter what kind of audio implementation has been used."""
    def Play() as bool
    """Plays the audio, or resumes it if it were paused."""

    def Stop() as bool
    """Stops the audio if possible and resets it to the beginning."""

    def Pause() as bool
    """Pauses the audio if it were playing. Call Play() to resume."""

    Volume as single:
    """Volume of the audio ranged [0, inf]."""
        get
        set

    Pitch as single:
    """Pitch of the audio ranged [0.5, 2]."""
        get
        set

    Looping as bool:
    """Whether the sound is looping or not."""
        get
        set

    Position as single:
    """The position of the sound in seconds."""
        get
        set

    Length as single:
    """The entire duration / length of the audio file in seconds."""
        get

    IsPlaying as bool:
    """Returns whether the audio file is currently playing or not."""
        get