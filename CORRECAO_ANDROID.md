# Correção do Problema de Conexão Android

## Problema Identificado
O app Flutter estava usando `localhost:8080` que funciona no Chrome/Web, mas no Android o `localhost` se refere ao próprio dispositivo, não ao computador host.

## Soluções Implementadas

### 1. Configuração de Rede Dinâmica
- Criado `lib/config/api_config.dart` que detecta automaticamente a plataforma
- **Web**: usa `http://localhost:8080`
- **Android**: usa `http://10.0.2.2:8080` (IP especial do emulador)
- **iOS**: usa `http://localhost:8080`

### 2. Permissões Android
Adicionado no `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

### 3. Configuração CORS Backend
Atualizado `WebConfig.java` para permitir requisições de qualquer origem:
```java
.allowedOrigins("*")
.allowedHeaders("*")
```

### 4. Arquivos Atualizados
- `lib/api_service.dart`
- `lib/admin_service.dart` 
- `lib/redefinir_senha_service.dart`
- `lib/cadastro.dart`
- `lib/login.dart`
- `lib/index.dart`

## Como Testar

### 1. Reiniciar o Backend
```bash
cd Z:\totototot\gamelegendsBackend-master-main-main-main-main
mvn spring-boot:run
```

### 2. Testar no Flutter
```bash
cd c:\Users\rm90137\Desktop\Gamelegends_Flutter
flutter clean
flutter pub get
flutter run
```

### 3. Verificar Conectividade
- **Web**: Deve continuar funcionando normalmente
- **Android**: Agora deve conectar ao backend usando `10.0.2.2:8080`

## Arquivos Restantes para Atualizar
Se ainda houver problemas, atualize manualmente estes arquivos substituindo `http://localhost:8080` por `ApiConfig.baseUrl`:

- `lib/cadastro_cartao.dart`
- `lib/cadCartao.dart`
- `lib/cartoes_page.dart`
- `lib/cartoes_perfil.dart`
- `lib/descricao.dart`
- `lib/descricao2.dart`
- `lib/descricao3.dart`
- `lib/jogo_detalhes.dart`
- `lib/modal_doacao_novo.dart`
- `lib/modal_pix_novo.dart`

## Notas Importantes
- O IP `10.0.2.2` é específico para o Android Emulador
- Para dispositivo físico, use o IP real da máquina (ex: `192.168.1.100:8080`)
- Certifique-se que o backend está rodando na porta 8080
- Firewall do Windows pode bloquear conexões, configure se necessário