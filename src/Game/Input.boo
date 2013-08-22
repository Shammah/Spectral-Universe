namespace Universe

import OpenTK
import Spectral.Graphics.Textures
import Universe.Actors
import Universe.Programs
import Universe.Armory

partial class Game(Engine):
    override def KeyboardProcess():
    """
    Todo: Maybe its an idea to let the player move forward? For future features.
    """
        m = Map cast GameMap

        if Keyboard[OpenTK.Input.Key.W]:
            m.Player.Position += Vector3(0, 1, 0) * RenderPeriod * 50

        if Keyboard[OpenTK.Input.Key.S]:
            m.Player.Position += Vector3(0, -1, 0) * RenderPeriod * 50

        if Keyboard[OpenTK.Input.Key.A]:
            m.Player.Position += Vector3(0, 0, -1) * RenderPeriod * 50

        if Keyboard[OpenTK.Input.Key.D]:
            m.Player.Position += Vector3(0, 0, 1) * RenderPeriod * 50

    override def Mouse_Move(sender as Object, e as OpenTK.Input.MouseMoveEventArgs):
        pass

    override def Mouse_ButtonDown(sender as Object, e as OpenTK.Input.MouseButtonEventArgs):
        (Map cast GameMap).Player.FireLaser(Camera.Raycast(Mouse.X, Mouse.Y))