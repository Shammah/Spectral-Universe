namespace Spectral

import System
import System.Collections.Generic
import OpenTK

static class Utility:
"""Various utility stuff for the engine that has no real category to place in."""

    [Extension]
    public def Clamp[of T(IComparable)](this as T, min as T, max as T) as T:
    """
    Clamps the value of a single between a minimal and a maximal value.
    Param this: The value to be clamped.
    Param min: The minimal value to be clamped to.
    Param max: The maximal value to be clamped to.
    Raises ArgumentException: Minimal value may not be bigger than maximimal value.
    """
        raise ArgumentException("Minimal value $(min) is bigger than the maximum value $(max).") if min.CompareTo(max) > 0

        if this.CompareTo(max) > 0:
            return max
        elif this.CompareTo(min) < 0:
            return min
        else:
            return this

    def AsVector4(list as List[of (single)]) as (Vector4):
    """
    Tries to transform the list into an array of Vector4.
    Param list: The list of data points to transform.
    Raises NullReferenceException: list may not be null.
    Raises IndexOutOfRangeException: One of the items is not compatible with a Vector3.
    """
        raise NullReferenceException("The list of data points may not be null.") if list is null
        data as (Vector4) = array(Vector4, list.Count)

        for i in range(0, list.Count):
            data[i] = Vector4(list[i][0], list[i][1], list[i][2], list[i][3])

        return data

    def AsVector3(list as List[of (single)]) as (Vector3):
    """
    Tries to transform the list into an array of Vector3.
    Param list: The list of data points to transform.
    Raises NullReferenceException: list may not be null.
    Raises IndexOutOfRangeException: One of the items is not compatible with a Vector3.
    """
        raise NullReferenceException("The list of data points may not be null.") if list is null
        data as (Vector3) = array(Vector3, list.Count)

        for i in range(0, list.Count):
            data[i] = Vector3(list[i][0], list[i][1], list[i][2])

        return data

    def AsVector2(list as List[of (single)]) as (Vector2):
    """
    Tries to transform the list into an array of Vector2.
    Param list: The list of data points to transform.
    Raises NullReferenceException: list may not be null.
    Raises IndexOutOfRangeException: One of the items is not compatible with a Vector3.
    """
        raise NullReferenceException("The list of data points may not be null.") if list is null
        data as (Vector2) = array(Vector2, list.Count)

        for i in range(0, list.Count):
            data[i] = Vector2(list[i][0], list[i][1])

        return data