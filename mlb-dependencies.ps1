
Set-StrictMode -Version 2.0
$ErrorActionPreference = "Stop"

if ($args.Count -ne 1) {
  "Usage: mlb-dependencies file.mlb"
  exit 1
}

$mlb = $args[0]

if ($mlb -notmatch "[.]mlb$") {
  "Error: argument must be a .mlb file"
  exit 1
}

$mydir = Split-Path -Parent $PSCommandPath

. $mydir/smlbuild-include.ps1

$lines = @(listMLB $mlb)

if ($lines -match "^Error: ") {
  $lines -match "^Error: "
  exit 1
}

$target = $mlb -replace "[.]mlb$",".exe"

if (!([System.IO.Path]::IsPathRooted($target))) {
  $target = (Join-Path $mydir $target)
}

foreach ($line in $lines) {
  "${target}: $line"
}
  
