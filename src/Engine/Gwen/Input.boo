namespace Spectral.Gwen

import System
import Boo.Lang.PatternMatching

class Input:
    private m_Canvas as Gwen.Control.Canvas = null

    private m_MouseX as int = 0
    private m_MouseY as int = 0

    private m_AltGr as bool = false

    def constructor(window as OpenTK.GameWindow):
        window.KeyPress += KeyPress

    def Initialize(c as Gwen.Control.Canvas):
        m_Canvas = c

    private def TranslateKeyCode(key as OpenTK.Input.Key) as Gwen.Key:
        match key:
            case OpenTK.Input.Key.BackSpace:
                return Gwen.Key.Backspace

            case OpenTK.Input.Key.Enter:
                return Gwen.Key.Return

            case OpenTK.Input.Key.Escape:
                return Gwen.Key.Escape

            case OpenTK.Input.Key.Tab:
                return Gwen.Key.Tab

            case OpenTK.Input.Key.Space:
                return Gwen.Key.Space

            case OpenTK.Input.Key.Up:
                return Gwen.Key.Up

            case OpenTK.Input.Key.Down:
                return Gwen.Key.Down

            case OpenTK.Input.Key.Left:
                return Gwen.Key.Left

            case OpenTK.Input.Key.Right:
                return Gwen.Key.Right

            case OpenTK.Input.Key.Home:
                return Gwen.Key.Home

            case OpenTK.Input.Key.End:
                return Gwen.Key.End

            case OpenTK.Input.Key.Delete:
                return Gwen.Key.Delete

            case OpenTK.Input.Key.LControl:
                m_AltGr = true;
                return Gwen.Key.Control

            case OpenTK.Input.Key.LAlt:
                return Gwen.Key.Alt

            case OpenTK.Input.Key.LShift:
                return Gwen.Key.Shift

            case OpenTK.Input.Key.RControl:
                return Gwen.Key.Control

            case OpenTK.Input.Key.RAlt: 
                if m_AltGr:
                    m_Canvas.Input_Key(Gwen.Key.Control, false)

                return Gwen.Key.Alt

            case OpenTK.Input.Key.RShift:
                return Gwen.Key.Shift

            otherwise:
                return Gwen.Key.Invalid

    private static def TranslateChar(key as OpenTK.Input.Key) as char:
        if key >= OpenTK.Input.Key.A and key <= OpenTK.Input.Key.Z:
            a        = char('a') cast int
            plus     = key cast int - OpenTK.Input.Key.A cast int
            output     = a + plus

            return Convert.ToChar(output)

        return char(' ')

    def ProcessMouseMessage(args as duck) as bool:
        if m_Canvas is null:
            return false

        if args isa OpenTK.Input.MouseMoveEventArgs:
            ev1 as OpenTK.Input.MouseMoveEventArgs = args cast OpenTK.Input.MouseMoveEventArgs
            dx as int = ev1.X - m_MouseX
            dy as int = ev1.Y - m_MouseY

            m_MouseX = ev1.X
            m_MouseY = ev1.Y

            return m_Canvas.Input_MouseMoved(m_MouseX, m_MouseY, dx, dy)

        if args isa OpenTK.Input.MouseButtonEventArgs:
            ev2 as OpenTK.Input.MouseButtonEventArgs = args cast OpenTK.Input.MouseButtonEventArgs
            return m_Canvas.Input_MouseButton(ev2.Button cast int, ev2.IsPressed)

        if args isa OpenTK.Input.MouseWheelEventArgs:
            ev3 as OpenTK.Input.MouseWheelEventArgs = args cast OpenTK.Input.MouseWheelEventArgs
            return m_Canvas.Input_MouseWheel(ev3.Delta * 60) // @todo Make framerate independant

        return false

    def ProcessKeyDown(args as duck) as bool:
        ev as OpenTK.Input.KeyboardKeyEventArgs = args cast OpenTK.Input.KeyboardKeyEventArgs
        ch as char = TranslateChar(ev.Key)

        if Gwen.Input.InputHandler.DoSpecialKeys(m_Canvas, ch):
            return false

        iKey as Gwen.Key = TranslateKeyCode(ev.Key)

        return m_Canvas.Input_Key(iKey, true)

    def ProcessKeyUp(args as duck) as bool:
        ev as OpenTK.Input.KeyboardKeyEventArgs = args cast OpenTK.Input.KeyboardKeyEventArgs
        ch as char = TranslateChar(ev.Key)
        
        if Gwen.Input.InputHandler.DoSpecialKeys(m_Canvas, ch):
            return false

        iKey as Gwen.Key = TranslateKeyCode(ev.Key)

        return m_Canvas.Input_Key(iKey, false)

    def KeyPress(sender as object, e as OpenTK.KeyPressEventArgs):
        m_Canvas.Input_Character(e.KeyChar)