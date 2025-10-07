@echo off
echo Atualizando URLs nos arquivos Dart...

REM Substituir localhost por configuracao dinamica nos arquivos
powershell -Command "(Get-Content 'lib\cadastro_cartao.dart') -replace 'const String cartaoApiUrl = \"http://localhost:8080/cadcartao\";', 'import ''config/api_config.dart'';^n^nString get cartaoApiUrl => ApiConfig.cadCartaoUrl;' | Set-Content 'lib\cadastro_cartao.dart'"

powershell -Command "(Get-Content 'lib\cadCartao.dart') -replace 'const String baseUrl = \"http://localhost:8080\";', 'import ''config/api_config.dart'';^n^nString get baseUrl => ApiConfig.baseUrl;' | Set-Content 'lib\cadCartao.dart'"

powershell -Command "(Get-Content 'lib\cartoes_page.dart') -replace 'const String cartaoApiUrl = \"http://localhost:8080/cadcartao\";', 'import ''config/api_config.dart'';^n^nString get cartaoApiUrl => ApiConfig.cadCartaoUrl;' | Set-Content 'lib\cartoes_page.dart'"

powershell -Command "(Get-Content 'lib\cartoes_perfil.dart') -replace 'const String cartaoApiUrl = \"http://localhost:8080/cadcartao\";', 'import ''config/api_config.dart'';^n^nString get cartaoApiUrl => ApiConfig.cadCartaoUrl;' | Set-Content 'lib\cartoes_perfil.dart'"

echo URLs atualizadas com sucesso!
pause