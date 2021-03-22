@echo off
hugo -t jane
xcopy .\public\* .\..\docs\ /s /y
rmdir /s /q public