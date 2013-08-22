#!/bin/bash

PROJECT_PATH="$(dirname $0)"
mono --debug $PROJECT_PATH/test/xunit/xunit.console.clr4.exe $PROJECT_PATH/bin/SpectralEngineTest.dll
mono --debug $PROJECT_PATH/test/xunit/xunit.console.clr4.exe $PROJECT_PATH/bin/SpectralUniverseTest.dll
