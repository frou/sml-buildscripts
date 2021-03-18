@echo off
set args=%*
"C:\msys64\usr\bin\bash.exe" -x -c 'export PATH=/usr/bin:/mingw64/bin:$PATH ; /c/mlton-20201002-1.amd64-mingw-gmp-dynamic/bin/mlton %args%'
