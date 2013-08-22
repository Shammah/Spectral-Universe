namespace Universe.Actors

import OpenTK
import Universe.Armory
import Universe.Programs

class Player(Warship):
"""The player!"""
    
    def constructor(name as string):
    """Creates a player."""
        super(name, "player", PlayerProgram())

        Weapons.Add("laser", Laser(self, 9999))

    def FireLaser(dir as Vector3):
    """
    Fires a lazer into the world if possible.
    Param dir: The normalized direction (from camera position) the lazer is to be fired.
    """
        ray = Weapons["laser"].Fire()

        if ray is not null:

            # Shoot from alternating locations :)
            if (Weapons["laser"].Ammo + 1) % 2 == 0:
                ray.Position    = Position + Vector3(2, 1, -3) + dir
            else:
                ray.Position    = Position + Vector3(2, 1, 3) + dir

            ray.Direction       = (Map.Engine.Camera.Position + Map.Engine.Camera.ZFar * dir) - Position

            # Rotate the ray so that it always points in the direction it flies to.
            angle = Vector3.CalculateAngle(Vector3(1, 0, 0), ray.Direction)
            ray.Orientation    *= Quaternion.FromAxisAngle(Vector3.Cross(Vector3(1, 0, 0), ray.Direction), angle)

            ray.Map             = Map