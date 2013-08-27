Spectral Universe
=================

Spectral Universe is music-driven space shooter that runs on Mono and OpenGL and has been developed entirely in the Boo programming language.

[Spectral Universe on IndieDB](http://www.indiedb.com/games/spectral-universe)

Dependencies
------------
* Mono
* OpenAL

Installation
------------
You **will** need to run the program through Mono, as running it through .NET creates a couple of bugs. At the moment, the user has to launch the game through Mono itself, as mkbundle seems to be broken.

1. Clone the repository on your local machine.
2. Open up a command prompt, go to the main repository directory and either run the build.sh script or type: mono ./booc/booi.exe build.boo

If the script ran successfully, all additional libraries are created in /lib, the binaries are placed in /bin. Finally, all libraries and resources needed to deploy the game are copied over to /bin. To deploy your game, you should be able to just zip up the entire /bin directory and send it out!

Usage
-----
1. Put the music you want to play with in /bin/Resources/Music/Game.
2. Either use the launch script launch.sh in /bin or run the program directly through mono. As an argument, you pass on the filename of the music file you want to play with.

Example: mono SpectralUniverse.exe mySong.wav

Audio Formats
-------------
At the moment, only .wav is supported on all platforms. Because of licensing issues, .mp3 are only supported under Windows. In the future, we hope to have .flac and .ogg support as well.