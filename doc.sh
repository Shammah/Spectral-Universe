monodocer -pretty -importslashdoc:./lib/SpectralEngine.xml -assembly:./lib/SpectralEngine.exe -path:./doc/Engine/docer
mdoc export-html -o=./doc/Engine ./doc/Engine/docer
rm -rf ./doc/Engine/docer
