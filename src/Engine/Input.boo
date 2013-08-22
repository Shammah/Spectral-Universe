namespace Spectral

import System

/// @todo Allow rebindable keys, and possible save them as well. Provide a default config.
partial class Engine(GameWindow):
    private virtual def KeyboardProcess():
    """This will handle the input for now. Probably best if we move this to a seperate Input class?"""
        if Keyboard[OpenTK.Input.Key.W]:
            vector = (Camera.Target - Camera.Position) * RenderPeriod * 50
            Camera.Position += vector
            Camera.Target   += vector

        if Keyboard[OpenTK.Input.Key.S]:
            vector = (Camera.Target - Camera.Position) * RenderPeriod * 50
            Camera.Position -= vector
            Camera.Target   -= vector

        if Keyboard[OpenTK.Input.Key.A]:
            vector              = Vector3.Cross((Camera.Target - Camera.Position), Camera.Up) * RenderPeriod * 50
            Camera.Position -= vector
            Camera.Target   -= vector

        if Keyboard[OpenTK.Input.Key.D]:
            vector              = Vector3.Cross((Camera.Target - Camera.Position), Camera.Up) * RenderPeriod * 50
            Camera.Position += vector
            Camera.Target   += vector

        if Keyboard[OpenTK.Input.Key.Escape]:
            Exit()

    private virtual def Keyboard_KeyDown(sender as Object, e as OpenTK.Input.KeyboardKeyEventArgs):
        pass
        /* Old GWEN console
        Gwenterface.Input.ProcessKeyDown(e)

        if Keyboard[OpenTK.Input.Key.Tilde]:
            Gwenterface.Console.Toggle()

        if Keyboard[OpenTK.Input.Key.Escape]:
            if Gwenterface.Console.ConsoleMode == Gwenterface.Console.Mode.Minimal:
                Gwenterface.Console.Toggle()
                Gwenterface.Console.Toggle()
            elif Gwenterface.Console.ConsoleMode == Gwenterface.Console.Mode.Fullscreen:
                Gwenterface.Console.Toggle()
            else:
                Exit()
        */

    private virtual def Keyboard_KeyUp(sender as Object,  e as OpenTK.Input.KeyboardKeyEventArgs):
        //Gwenterface.Input.ProcessKeyUp(e)
        pass

    private virtual def Mouse_Move(sender as Object, e as OpenTK.Input.MouseMoveEventArgs):
        rotation            = Quaternion.FromAxisAngle(Camera.Up, -e.XDelta * RenderPeriod) * Quaternion.FromAxisAngle(Vector3.Cross(Camera.Direction, Camera.Up), -e.YDelta * RenderPeriod)
        Camera.Direction    = Vector3.Transform(Camera.Direction, rotation)

        //_gwenterface.Input.ProcessMouseMessage(e)

    private virtual def Mouse_ButtonDown(sender as Object, e as OpenTK.Input.MouseButtonEventArgs):
        //_gwenterface.Input.ProcessMouseMessage(e)
        pass

    private virtual def Mouse_ButtonUp(sender as Object, e as OpenTK.Input.MouseButtonEventArgs):
        //_gwenterface.Input.ProcessMouseMessage(e)
        pass

    private virtual def Mouse_Wheel(sender as Object, e as OpenTK.Input.MouseWheelEventArgs):
        //_gwenterface.Input.ProcessMouseMessage(e)
        pass