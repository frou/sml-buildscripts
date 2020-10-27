
<#

.SYNOPSIS
Use Poly/ML to run a Standard ML program defined in a .mlb file

.EXAMPLE
polyrun example.mlb datafile.txt
Run the Standard ML program defined in example.mlb using Poly/ML, passing datafile.txt as an argument to the program

#>

if ($args.Count -lt 1) {
  "Usage: polyrun file.mlb [args...]"
  exit 1
}

$mlb = $args[0]

if ($mlb -notmatch "[.]mlb$") {
  "Error: argument must be a .mlb file"
  exit 1
}

$mydir = Split-Path -Parent $PSCommandPath

. $mydir/smlbuild-include.ps1

$lines = @(processMLB $mlb)

if ($lines -match "^Error: ") {
  $lines -match "^Error: "
  exit 1
}

$outro = @"
val _ = main ();
val _ = OS.Process.exit (OS.Process.success);
"@ -split "[\r\n]+"

$script = @()
$script += $lines
$script += $outro

$tmpfile = ([System.IO.Path]::GetTempFileName()) -replace "[.]tmp",".sml"

$script | Out-File -Encoding "ASCII" $tmpfile

cat $tmpfile | polyml $args[1..$args.Length] | Out-Host

if (-not $?) {
    del $tmpfile
    exit $LastExitCode
}

del $tmpfile

