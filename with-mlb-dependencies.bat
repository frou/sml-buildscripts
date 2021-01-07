@echo off
set args=%*
if defined args set args=%args:-=_DASH_%
if defined args set args=%args:"=\"%
PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& %~dpn0.ps1 %args%"
