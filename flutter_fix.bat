@echo off
chcp 65001 >nul
echo Corrigindo problemas do Flutter...

REM Definir variáveis
set FLUTTER_ROOT=D:\src\flutter
set DART_SDK=%FLUTTER_ROOT%\bin\cache\dart-sdk
set DART_EXE=%DART_SDK%\bin\dart.exe

REM Verificar se o Dart existe
if not exist "%DART_EXE%" (
    echo Erro: Dart não encontrado em %DART_EXE%
    pause
    exit /b 1
)

REM Executar pub get diretamente
echo Executando pub get...
"%DART_EXE%" pub get

echo Processo concluído!
pause