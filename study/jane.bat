@echo off
del /f /s /q public
hugo -t jane
xcopy .\public\* .\..\docs\ /s /y