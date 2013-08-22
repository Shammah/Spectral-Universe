namespace Universe.Armory

import Universe.Actors
import Universe.Programs

class LaserPewPew(Projectile):
"""Laser rays projectile which moves around the world."""

    static private _counter as ulong
    
    # This will cause an exception at the 18,446,744,073,709,551,616th bullet... :(
    def constructor(owner as Spectral.Actors.Actor):
    """Constructs a laser ray."""
        super("LaserPewPew" + _counter++, owner, "ray", LaserPewPewProgram())

        Speed = 10

    override def Update(elapsedTime as single):
    """Updates the state of the ray."""
        Position += Direction * Speed

        # Check for collision.
        for actor in Map.Actors:
            if actor isa Enemy:
                enemy = actor cast Enemy
                if OBB & enemy.OBB and Owner is not enemy:
                    enemy.Destroy()
                    Destroy()

                    return

        # Dispose if outside of field of view.
        Destroy() if Map is not null and (Position - Map.Engine.Camera.Position).Length > (Map.Engine.Camera.ZFar * 1.5f)