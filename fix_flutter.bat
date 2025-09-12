@echo off
echo Limpando cache do Flutter...

REM Remover pastas de cache se existirem
if exist "build" rmdir /s /q "build"
if exist ".dart_tool" rmdir /s /q ".dart_tool"

REM Tentar executar flutter clean com path completo
echo Executando flutter clean...
flutter clean

REM Reinstalar dependências
echo Reinstalando dependências...
flutter pub get

echo Processo concluído!
pause