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
echo  RESTAURAR INTERFACE NORMAL DE LOGIN - WINDOWS IOT
echo =====================================================
echo.
echo Este script restaura os elementos visuais da tela de login.
echo Ele nao remove o login automatico nem altera o shell configurado.
echo.

:: Remove a configuracao que oculta o login automatico
reg.exe delete "HKLM\SOFTWARE\Microsoft\Windows Embedded\EmbeddedLogon" /v HideAutoLogonUI /f >nul 2>&1

:: Restaura a animacao do primeiro login
reg.exe delete "HKLM\SOFTWARE\Microsoft\Windows Embedded\EmbeddedLogon" /v HideFirstLogonAnimation /f >nul 2>&1

:: Restaura as animacoes da interface de login
reg.exe delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI" /v AnimationDisabled /f >nul 2>&1

:: Restaura a tela de bloqueio
reg.exe delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\Personalization" /v NoLockScreen /f >nul 2>&1

:: Desativa o recurso Custom Logon
Dism.exe /Online /Disable-Feature /FeatureName:Client-EmbeddedLogon /NoRestart

if errorlevel 1 goto :erro

echo.
echo Interface normal de login restaurada com sucesso.
echo Reinicie o computador para aplicar todas as alteracoes.
echo.
choice /C SN /N /M "Deseja reiniciar agora? [S/N]: "

if errorlevel 2 goto :fim

shutdown.exe /r /t 5 /c "Reinicializacao para restaurar a interface de login"

goto :fim

:erro
echo.
echo ERRO: os valores de registro foram removidos, mas o recurso
echo Custom Logon pode nao ter sido desativado corretamente.
echo Execute novamente este arquivo como administrador.
echo.
pause
exit /b 1

:fim
endlocal
