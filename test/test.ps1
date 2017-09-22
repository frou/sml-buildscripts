
Set-StrictMode -Version 2.0
$ErrorActionPreference = "Stop"

$mydir = Split-Path $MyInvocation.MyCommand.Path -Parent

cd $mydir

if (-not (Test-Path "fxp")) {
    git clone https://github.com/cannam/fxp
}

""
"==> Running directly in SML/NJ (smlrun)"
""

Get-Content -Path .\fxp\doc\fxp-xsa.xml | ..\smlrun.ps1 .\fxp\src\Apps\Canon\canon.mlb --validate=no

""
"==> Done"
""
