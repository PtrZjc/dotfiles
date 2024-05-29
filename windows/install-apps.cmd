@echo off

rem ===== Run this first: =====
rem @powershell -NoProfile -ExecutionPolicy Bypass -Command "iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))" && SET PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin
rem choco feature enable -n=allowGlobalConfirmation
rem mkdir C:\Tools
rem choco install -y toolsroot
rem ===========================

rem ----- Essentials -----
choco install notepadplusplus

rem ----- System Utils -----
choco install sysinternals --params "/InstallDir:C:\Tools\sysinternals"
choco install veracrypt
choco install f.lux

rem ----- Network -----
choco install insync
choco install qbittorrent

rem ----- Gaming -----
choco install steam

rem ----- Other Utilities -----
choco install 7zip
choco install winrar --not-silent