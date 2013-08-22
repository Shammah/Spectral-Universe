namespace Universe

import System
import OpenTK.Graphics

def Main(argv as (string)):
    if argv.Length <= 0:
        print "You need to specify a filename. The file should be located in /bin/Resources/Music/Game/"
        return 1

    game as Game = Game(800, 600, GraphicsMode(ColorFormat(8, 8, 8, 8 ), 16), "Spectral Universe", argv[0])

    using game:
        game.Run()