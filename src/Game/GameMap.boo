namespace Universe

import OpenTK
import OpenTK.Graphics
import Spectral
import Spectral.Actors
import Universe.Actors

class GameMap(Spectral.Map):

    Terrain as Terrain:
    """The terrain of the map."""
        get:
            return _terrain

    Player as Player:
    """The player himself."""
        get:
            return _player

    Enemies as List[of Enemy]:
    """The enemies the player has to kill."""
        get:
            return _enemies

    private _terrain as Terrain
    private _player as Player
    private _enemies as List[of Enemy]

    def constructor(engine as Engine):
    """Constructor."""
        super(engine)

        _enemies = List[of Enemy]()

    def CreateMap(file as string, samples as uint):
    """Creates the terrain model from a music file."""
        sun                     = PointLight("sun", Vector3(0, -1, 0), Color4(1, 1, 1, 1), 30, true)
        sun.Map                 = self

        # Create terrain
        _terrain                = Terrain(self, file, 30, samples, 200)
        _terrain.Play()

        # Add player
        _player                 = Player("player")
        _player.Position        = Vector3(0, 25, _terrain.Width / 2)
        _player.Scale           = Vector3(1.5f, 1.5f, 1.5f)
        _player.Orientation     = Quaternion.Identity
        _player.Map             = self

        # Add a test enemy
        enemy                   = Enemy()
        enemy.Position          = Vector3(25, 25, _terrain.Width / 2)
        enemy.Scale             = Vector3(1.5f, 1.5f, 1.5f)
        enemy.Orientation       = Quaternion.FromAxisAngle(Vector3(0, 1, 0), 0.5f * Spectral.Math.Tau)
        enemy.Map               = self
        enemy.OnDestroyed      += { x | Enemies.Remove(x) }
        Enemies.Add(enemy)

        # Position camera behind player.
        Engine.Camera.Position  = _player.Position - Vector3(40, -25, 0)
        Engine.Camera.Target    = _player.Position - Vector3(10, -18, 0)
        Engine.Camera.Attach    = _player

    override def Update(elapsedTime as single):
        super(elapsedTime)
        
        _terrain.Update(elapsedTime)

        # Make sure the the player does not leave the bounds of the map (terrain).
        # Todo: Add margin bounds for the player model.
        if _player.Position.Z < 0:
            _player.Position = Vector3(_player.Position.X, _player.Position.Y, 0)
        elif _player.Position.Z > _terrain.Width:
            _player.Position = Vector3(_player.Position.X, _player.Position.Y, _terrain.Width)

        if _player.Position.Y < 0:
            _player.Position = Vector3(_player.Position.X, 0, _player.Position.Z)
        elif _player.Position.Y > _terrain.Height * 2:
            _player.Position = Vector3(_player.Position.X, _terrain.Height * 2, _player.Position.Z)

    override def Dispose():
        return if _disposed

        _terrain.Dispose() if _terrain is not null
        _player.Dispose() if _player is not null

        super()