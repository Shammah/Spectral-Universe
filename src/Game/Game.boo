namespace Universe

import System
import OpenTK.Graphics
import Spectral

partial class Game(Engine):
    private _music as string

    def constructor(width as int, height as int, gm as GraphicsMode, title as string, music as string):
        super(width, height, gm, title)
        _music = music

    override def OnLoad(e as EventArgs):
        super(e)

        # Load map.
        m           = GameMap(self)
        m.CreateMap("./Resources/Music/Game/" + _music, 2048)
        Map         = m

        Camera.ZFar = 300