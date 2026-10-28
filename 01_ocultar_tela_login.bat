@echo off
setlocal EnableExtensions
chcp 65001 >nul

:: Solicita privilegios de administrador
fltmc >nul 2>&1
if errorlevel 1 (
    echo Solicitando privilegios de administrador...
    powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

echo.
echo =====================================================
echo  OCULTAR INTERFACE DO LOGIN AUTOMATICO - WINDOWS IOT
echo =====================================================
echo.
echo Este script nao configura o login automatico nem altera o shell.
echo Ele apenas ativa o Custom Logon e oculta os elementos visuais.
echo.

:: Ativa o recurso Custom Logon
Dism.exe /Online /Enable-Feature /FeatureName:Client-EmbeddedLogon /All /NoRestart

if errorlevel 1 goto :erro

:: Oculta a foto, o nome do usuario, a rodinha e o "Bem-vindo"
reg.exe add "HKLM\SOFTWARE\Microsoft\Windows Embedded\EmbeddedLogon" /v HideAutoLogonUI /t REG_DWORD /d 1 /f

if errorlevel 1 goto :erro

:: Oculta a animacao do primeiro login
reg.exe add "HKLM\SOFTWARE\Microsoft\Windows Embedded\EmbeddedLogon" /v HideFirstLogonAnimation /t REG_DWORD /d 1 /f

if errorlevel 1 goto :erro

:: Desativa animacoes adicionais da interface de login
reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI" /v AnimationDisabled /t REG_DWORD /d 1 /f

if errorlevel 1 goto :erro

:: Desativa a tela de bloqueio
reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Personalization" /v NoLockScreen /t REG_DWORD /d 1 /f

if errorlevel 1 goto :erro

echo.
echo Configuracao concluida com sucesso.
echo Reinicie o computador para aplicar todas as alteracoes.
echo.
choice /C SN /N /M "Deseja reiniciar agora? [S/N]: "

if errorlevel 2 goto :fim

shutdown.exe /r /t 5 /c "Reinicializacao para aplicar o Custom Logon"

goto :fim

:erro
echo.
echo ERRO: nao foi possivel concluir todas as alteracoes.
echo O login automatico e o shell nao foram modificados.
echo.
pause
exit /b 1

:fim
endlocal
