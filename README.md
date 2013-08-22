Spectral Universe
=================

Spectral Universe is music-driven space shooter that runs on Mono and OpenGL and has been developped entirely in the Boo programming language.

Installation
------------
You **will** need to run the program through Mono, as running it through .NET creates a couple of bugs. At the moment, the user has to launch the game through Mono itself, as mkbundle seems to be broken.

1. Clone the repository on your local machine.
2. Install [NAnt](http://nant.sourceforge.net/).
3. Add both the NAnt binary path and the Boo compiler folder form this repository to your SYSTEM path, so you can execute the 'nant' and 'booc' compiler in the terminal from any place.
4. Open up a command prompt, go to the main repository directory and type: nant game.
5. If everything went correctly, copy over all contents of /lib to /bin.
6. Copy over the /res folder into /bin and name it "Resources".

Usage
-----
1. Put the music you want to play with in /bin/Resources/Music/Game.
2. Either use the launch script launch.sh in /bin or run the program directly through mono. As an argument, you pass on the filename of the music file you want to play with.

Example: mono SpectralUniverse.exe mySong.wav

Audio Formats
-------------
At the moment, only .wav is supported on all platforms. Because of licensing issues, .mp3 are only supported under Windows. In the future, we hope to have .flac and .ogg support as well.