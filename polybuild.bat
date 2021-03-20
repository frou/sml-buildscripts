@echo off
set args=%*
PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& %~dpn0.ps1 %args%"
