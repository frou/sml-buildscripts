
<#

.SYNOPSIS
Use SML/NJ to run a Standard ML program defined in a .mlb file

.EXAMPLE
smlrun example.mlb datafile.txt
Run the Standard ML program defined in example.mlb using SML/NJ, passing datafile.txt as an argument to the program

#>

if ($args.Count -lt 1) {
  "Usage: smlrun file.mlb [args...]"
  exit 1
}

$mlb = $args[0]

if ($mlb -notmatch "[.]mlb$") {
  "Error: argument must be a .mlb file"
  exit 1
}

$libdir = "c:/Users/Chris/Documents/mlton-20150109-all-mingw-492/lib/sml"

function script:processMLB($m) {

  if (! (Test-Path $m)) {
    "Error: file not found: " + $m
    return
  }

  $lines = @(Get-Content $m)

  # remove incompatible Basis lib and unneeded call to main
  $lines = $lines -notmatch "basis[.]mlb" -notmatch "main[.]sml"

  # remove ML-style comments
  $lines = $lines -replace "\(\*[^\*]*\*\)",""

  # expand library path
  $lines = $lines -replace "\$\(SML_LIB\)",$libdir

  # remove leading whitespace
  $lines = $lines -replace "^ *",""

  # remove trailing whitespace
  $lines = $lines -replace " *$",""

  # remove empty lines
  $lines = $lines -notmatch "^$"

  # remove lines with double-quotes in them, e.g. annotation
  $lines = $lines -notmatch """"

  $expanded = @()

  foreach ($line in $lines) {

    $path = $line

    if (!([System.IO.Path]::IsPathRooted($path))) {
      # resolve path relative to containing mlb file
      $path = (Join-Path (Split-Path -parent $m) $path)
    }

    if ($path -match "[.]mlb$") {

      # recurse to expand included mlb
      $expanded += @(processMLB $path)
      
    } elseif ($path -match "[.](sml|sig)$") {

      # SML/NJ wants forward slashes for path separators
      $path = $path -replace "\\","/";

      # add use declaration
      $path = $path -replace "^(.*)$",'use "$1";'

      $expanded += $path

    } else {
      Write-Warning "*** Warning: unsupported syntax or file in ${m}: ${line}"
    }
  }

  $expanded
}

$lines = @(processMLB $mlb)

if ($lines -match "^Error: ") {
  $lines -match "^Error: "
  exit 1
}

$intro = @"
val smlrun__cp = 
    let val x = !Control.Print.out in
        Control.Print.out := { say = fn _ => (), flush = fn () => () };
        x
    end;
val smlrun__prev = ref "";
Control.Print.out := { 
    say = fn s => 
        (if String.isSubstring " Error" s orelse String.isSubstring "failed: " s
         then (Control.Print.out := smlrun__cp;
               (#say smlrun__cp) (!smlrun__prev);
               (#say smlrun__cp) s)
         else (smlrun__prev := s; ())),
    flush = fn s => ()
};
"@ -split "[\r\n]+"

$outro = @"
val _ = main ();
val _ = OS.Process.exit (OS.Process.success);
"@ -split "[\r\n]+"

$script = @()
$script += $intro
$script += $lines
$script += $outro

$tmpfile = ([System.IO.Path]::GetTempFileName()) -replace "[.]tmp",".sml"

$script | Out-File -Encoding "ASCII" $tmpfile

$env:CM_VERBOSE="false"

$input | sml $tmpfile $args[1,$args.Length]

if (-not $?) {
    del $tmpfile
    exit $LastExitCode
}

del $tmpfile

