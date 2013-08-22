namespace Universe.Actors

import OpenTK
import Universe.Armory
import Universe.Programs

class Enemy(Warship, Spectral.IUpdatable):
"""The enemy! Shoot him!"""

    static private _counter as ulong
    protected _ai as duck
    
    # This will cause an exception at the 18,446,744,073,709,551,616th enemy... :(
    def constructor():
    """Creates an enemy."""
        super("enemy" + _counter++, "enemy", PlayerProgram())

        Weapons.Add("laser", Laser(self, 9999))
        OnSpawn += Spawn

    def Spawn(m as Spectral.Map):
    """
    Method which gets called after the enemy has spawned on the map.
    Param m: The map on which the enemy has spawned.
    """
        aiType      = m.Engine.Scripts.Assembly.GetType("EnemyAI", true, true)
        levelsType  = m.Engine.Scripts.Assembly.GetType("FrequencyLevels", true, true)
        
        _ai         = aiType()
        levels      = (m cast Universe.GameMap).Terrain.CurrentTransformation.Levels
        aiLevels    = array(levelsType, levels.Length)

        for i in range(0, levels.Length):
            aiLevels[i] = levelsType(levels[i].SubSonics, levels[i].SubBass, levels[i].Bass, levels[i].LowerMids, levels[i].UpperMids, levels[i].Treble)

        _ai.Levels = aiLevels

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

    def Update(elapsedTime as single):
    """
    The AI stuff will be placed in this function.
    Param elapsedTime: The elapsed time since the last call to this function in seconds.
    """
        Position += _ai.Move(elapsedTime)

        FireLaser(Vector3.Normalize((Map cast Universe.GameMap).Player.Position - Position))