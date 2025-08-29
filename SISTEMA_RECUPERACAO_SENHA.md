# 🔐 Sistema de Recuperação de Senha - Game Legends

## 📋 Funcionalidades Implementadas

### ✅ O que foi desenvolvido:
- **Envio de código por email real** (Gmail, Yahoo, Hotmail, etc.)
- **Códigos salvos no banco** para emails cadastrados no sistema
- **Verificação de código** com expiração de 15 minutos
- **Redefinição de senha** segura
- **Interface melhorada** com feedback visual
- **Identificação automática** de tipo de email

## 🎯 Como Funciona

### 1. Tela "Mandar Email" (`/mandaremail`)
- ✅ Lista emails cadastrados no sistema
- ✅ Identifica se é email real ou cadastrado
- ✅ Ícones visuais (☁️ para real, 💾 para cadastrado)
- ✅ Envio de código baseado no tipo

### 2. Tela "Código" (`/codin`)
- ✅ Interface para digitar código de 6 dígitos
- ✅ Indicação visual de onde encontrar o código
- ✅ Verificação em tempo real
- ✅ Feedback de sucesso/erro

### 3. Tela "Redefinir" (`/redefinir`)
- ✅ Formulário para nova senha
- ✅ Confirmação de senha
- ✅ Atualização no banco de dados
- ✅ Redirecionamento para login

## 🔧 Configuração Necessária

### Backend (Spring Boot)
1. **Configurar Email no `application.properties`:**
```properties
spring.mail.username=SEU_EMAIL@gmail.com
spring.mail.password=SUA_SENHA_DE_APP
```

2. **Executar SQL para criar tabela:**
```bash
# Execute o arquivo: create_codigo_verificacao_table.sql
```

3. **Iniciar o backend:**
```bash
cd gamelegendsBackend-master-main-main-main-main
./mvnw spring-boot:run
```

### Frontend (Flutter)
1. **Instalar dependências:**
```bash
cd Gamelegends_Flutter
flutter pub get
```

2. **Executar aplicação:**
```bash
flutter run -d chrome
```

## 📧 Tipos de Email Suportados

### Emails Reais (Envio por SMTP)
- Gmail (@gmail.com)
- Yahoo (@yahoo.com) 
- Hotmail (@hotmail.com)
- Outlook (@outlook.com)
- Live (@live.com)
- iCloud (@icloud.com)
- ProtonMail (@protonmail.com)
- UOL (@uol.com.br)
- BOL (@bol.com.br)
- Terra (@terra.com.br)

### Emails Cadastrados
- Qualquer email cadastrado na tabela `cadastro`
- Código salvo na tabela `codigo_verificacao`
- Ideal para testes e desenvolvimento

## 🧪 Como Testar

### Teste 1: Email Real
```
1. Acesse /mandaremail
2. Digite: seuemail@gmail.com
3. Clique "ENVIAR CÓDIGO"
4. Verifique sua caixa de entrada
5. Digite o código em /codin
6. Redefina a senha em /redefinir
```

### Teste 2: Email Cadastrado
```
1. Acesse /mandaremail
2. Digite um email da lista mostrada
3. Clique "ENVIAR CÓDIGO"
4. Consulte o código no banco:
   SELECT * FROM codigo_verificacao ORDER BY id DESC
5. Digite o código em /codin
6. Redefina a senha em /redefinir
```

## 🗃️ Estrutura do Banco

### Tabela: `codigo_verificacao`
```sql
id              BIGINT (PK, Auto)
email           NVARCHAR(255)
codigo          NVARCHAR(6)
data_expiracao  DATETIME2
usado           BIT
data_criacao    DATETIME2
```

### Consultas Úteis
```sql
-- Ver códigos ativos
SELECT * FROM codigo_verificacao 
WHERE usado = 0 AND data_expiracao > GETDATE();

-- Ver último código de um email
SELECT TOP 1 * FROM codigo_verificacao 
WHERE email = 'teste@email.com' 
ORDER BY id DESC;
```

## 🔄 Fluxo Completo

```
1. Usuário esquece senha
   ↓
2. Acessa /mandaremail
   ↓
3. Sistema identifica tipo de email
   ↓
4. Se real: envia por SMTP
   Se cadastrado: salva no banco
   ↓
5. Usuário recebe/consulta código
   ↓
6. Digita código em /codin
   ↓
7. Sistema valida código
   ↓
8. Usuário define nova senha em /redefinir
   ↓
9. Sistema atualiza senha no banco
   ↓
10. Redirecionamento para login
```

## 🚨 Segurança Implementada

- ✅ Códigos expiram em 15 minutos
- ✅ Códigos são únicos por email
- ✅ Códigos são marcados como "usados"
- ✅ Validação de formato de email
- ✅ Limpeza de códigos antigos
- ✅ Verificação de existência de email

## 📱 Interface Responsiva

- ✅ Design adaptável para mobile/desktop
- ✅ Feedback visual com cores e ícones
- ✅ Loading states durante operações
- ✅ Mensagens de erro/sucesso claras
- ✅ Navegação intuitiva entre telas

## 🎨 Melhorias Visuais

- 🎯 Ícones indicativos de tipo de email
- 🎨 Cores diferenciadas (verde=real, azul=cadastrado)
- ⏳ Indicadores de loading
- ✅ Mensagens de sucesso com emojis
- ❌ Mensagens de erro informativas
- 📱 Layout responsivo e moderno