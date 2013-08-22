namespace Spectral.Gwen

import System
import System.Collections.Generic

class Console(Gwen.Control.Base):
"""Console GUI for Gwen."""
    enum Mode:
        Off
        Minimal
        Fullscreen

    ConsoleMode as Mode:
    """The display mode of the console."""
        get:
            return _mode

    private _engine as Spectral.Engine
    private _window as Gwen.Control.WindowControl
    private _output as Gwen.Control.ListBox
    private _command as Gwen.Control.TextBox
    private _mode as Mode

    def constructor(parent as Gwen.Control.Base, engine as Spectral.Engine):
    """
    Constructor.
    Remarks: The engine window has to exist and be running.
    Param parent: The parent control.
    Param engine: The engine to which this console will belong to.
    """
        super(parent)
        _engine = engine

        _window = Gwen.Control.WindowControl(parent, "Console", false)
        _window.Dock = Gwen.Pos.Top
        _window.SetSize(parent.Width, parent.Height / 3)
        _window.IsHidden = true

        _output = Gwen.Control.ListBox(_window)
        _output.Dock = Gwen.Pos.Fill

        _command = Gwen.Control.TextBox(_window)
        _command.Dock = Gwen.Pos.Bottom
        _command.SubmitPressed += OnCommand

    def Print(message as string):
    """
    Adds a message to the console log.
    Param message: The message to be added to the log.
    """
        _output.AddRow(message)

    def OnCommand(control as Gwen.Control.Base):
    """
    Called when the user presses enter to enter a command.
    Param control: The caller of this event.
    Todo: Scroll the listbox down automatically.
    Todo: Set focus back on textbox after issuing command.
    """
        _engine.CommandCentre.Execute(_command.Text)

        _command.Text = String.Empty

    def Toggle():
    """
    Toggles the visibility between off, minimalistic and fullscreen.
    Todo: Set focus on textbox after showing.
    """
        if _window.IsHidden:
            _mode = Mode.Minimal
            _window.SetSize(self.Parent.Width, self.Parent.Height / 4)
            _window.IsHidden = false

        elif _mode == Mode.Minimal:
            _mode = Mode.Fullscreen
            _window.SetSize(self.Parent.Width, self.Parent.Height)

        elif _mode == Mode.Fullscreen:
            _window.IsHidden = true
            _mode = Mode.Off

    def Clear():
    """Clears all log history from the console."""
        _output.Clear()

    def Insert(list as IEnumerable[of string]):
    """
    Inserts every string message from an iterarable collection to the console.
    Raises NullReferenceException: list was null.
    """
        raise NullReferenceException("The list of strings is null.") if list is null
        
        for msg as string in list:
            Print(msg)