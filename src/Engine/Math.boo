namespace Spectral

import System
import System.Math as SMath
import OpenTK

static class Math():
"""Various math helper functions."""

    public final Tau as single = MathHelper.Pi * 2

    public def CreateRotation(alpha as single, beta as single, gamma as single) as Matrix4:
    """
    Creates a general purpose matrix for rotation.
    Remarks: This only work well for rotations -at- the origin!
    Param alpha: The rotation around the x-axis in radians.
    Param beta: The rotation around the y-axis in radians.
    Param gamma: The rotation around the z-axis in radians.
    """
        ca as single = SMath.Cos(alpha)
        cb as single = SMath.Cos(beta)
        cg as single = SMath.Cos(gamma)

        sa as single = SMath.Sin(alpha)
        sb as single = SMath.Sin(beta)
        sg as single = SMath.Sin(gamma)

        row1 = Vector4(cb * cg,
                      -cb * sg, sb,
                      0)

        row2 = Vector4(cg * sa * sb + ca * sg,
                       ca * cg - sa * sb * sg,
                       -cb * sa,
                       0)

        row3 = Vector4(sa * sg - ca * cg * sb,
                       cg * sa + ca * sb * sg,
                       ca * cb,
                       0)

        row4 = Vector4.UnitW

        return Matrix4(row1, row2, row3, row4)

    public def RadiansToDegrees(radians as single) as single:
    """
    Converts radians to degrees.
    Param radians: The amount of radians to convert.
    """
        return (radians * (360.0f / Tau))

    public def DegreesToRadians(degrees as single) as single:
    """
    Converts degrees to radians.
    Param degrees: The amount of degrees to convert.
    """
        return (degrees * (Tau / 360.0f))