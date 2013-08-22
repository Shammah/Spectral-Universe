import System
import System.Linq
import OpenTK

class EnemyAI:
"""Basic enemy AI."""

    Levels as (FrequencyLevels):
    """Gets or sets the level data of frequency ranges after a transformation."""
        get:
            return _levels
        set:
            _levels = value

    Accuracy as double:
    """The accuracy as a value in the range [0, 1]"""
        get:
            return 0.5

    private _levels as (FrequencyLevels)
    private _totalTime as single

    def Move(elapsedTime as single) as Vector3:
    """This function should return a delta Vector3 on how much to move each update."""
        _totalTime = (_totalTime + elapsedTime) % (2 * Math.PI)

        return Vector3(Math.Sin(_totalTime), 0, Math.Cos(_totalTime))