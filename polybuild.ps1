
<#

.SYNOPSIS
Use Poly/ML to compile a Standard ML program defined in a .mlb file

.EXAMPLE
polybuild example.mlb
Compile the Standard ML program defined in example.mlb using Poly/ML.

The environment variable POLY_DIR must be set to a directory
containing the Poly/ML library files (PolyLib.lib, PolyLib.dll,
PolyMainLib.lib) and executable (PolyML.exe), and the clang compiler
must be in the path, for example because we are running in a
sufficiently recent Visual Studio command prompt with clang support.

#>


# NB just installing Poly/ML for Windows is not enough to get the
# Poly/ML libraries, because the export libraries such as PolyLib.lib
# are not included in the installation.

# To build them, check out Poly/ML from git or whatever, then go to
# its repo in a VC command prompt and

# > msbuild polyml.sln /p:Configuration=Release '/t:PolyLib;PolyML;PolyMainLib'

# then set the x64\Release subdir of the Poly/ML dir as $env:POLY_DIR.


Set-StrictMode -Version 2.0
$ErrorActionPreference = "Stop"

if ($args.Count -lt 1) {
  "Usage: polybuild file.mlb"
  exit 1
}

$mlb = $args[0]

if ($mlb -notmatch "[.]mlb$") {
  "Error: argument must be a .mlb file"
  exit 1
}

$poly_libdir = $env:POLY_DIR

if (! $poly_libdir -or ! (Test-Path -PathType Container $poly_libdir)) {
    "Error: POLY_DIR environment variable must be set to a valid directory"
    exit 1
}

"Poly/ML libdir is $poly_libdir"

$mydir = Split-Path -Parent $PSCommandPath

. $mydir/smlbuild-include.ps1

$lines = @(processMLB $mlb)

if ($lines -match "^Error: ") {
  $lines -match "^Error: "
  exit 1
}

$tmpfile_in = ([System.IO.Path]::GetTempFileName()) -replace "[.]tmp",".sml"
$tmpfile_out = ([System.IO.Path]::GetTempFileName()) -replace "[.]tmp",".obj"

$output_file = $mlb -replace ".mlb",""
$output_file = "$output_file.exe"

$outro = @"
val _ = PolyML.export("$tmpfile_out", main);
val _ = OS.Process.exit (OS.Process.success);
"@ -split "[\r\n]+"

$script = @()
$script += $lines
$script += $outro

$script -replace "\\","\\" | Out-File -Encoding "ASCII" $tmpfile_in

$polyml = "$poly_libdir\polyml"

cat $tmpfile_in | & $polyml -q --error-exit | Out-Host

if (-not $?) {
    del $tmpfile_in
    if (Test-Path $tmpfile_out) {
        del $tmpfile_out
    }
    exit $LastExitCode
}

del $tmpfile_in

clang -O3 $tmpfile_out -o $output_file -Xlinker /subsystem:console -Xlinker /entry:WinMainCRTStartup -Xlinker /ltcg -L"$poly_libdir" -lPolyLib -lPolyMainLib

if (-not $?) {
    del $tmpfile_out
    exit $LastExitCode
}
   
del $tmpfile_out
