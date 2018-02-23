
Set-StrictMode -Version 2.0
$ErrorActionPreference = "Stop"

$mydir = Split-Path $MyInvocation.MyCommand.Path -Parent

cd $mydir

""
"==> Running simple example directly in SML/NJ (smlrun)"
""

..\smlrun.ps1 .\simple.mlb

""
"==> Done"
""

if (-not (Test-Path "fxp")) {
    "==> Checking out more complex test repo"
    ""
    cmd /c "git clone https://github.com/cannam/fxp 2>&1"
    ""
    "==> Done"
}

""
"==> Running complex example directly in SML/NJ (smlrun)"
""

Get-Content -Path .\fxp\doc\fxp-xsa.xml | ..\smlrun.ps1 .\fxp\src\Apps\Canon\canon.mlb --validate=no

""
"==> Done"
""
