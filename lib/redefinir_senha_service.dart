import 'dart:convert';
import 'package:http/http.dart' as http;
 
class RedefinirSenhaService {
  static const String baseUrl = 'http://localhost:8080/redefinir-senha';
 
  static String? _emailAtual;
  static String? _codigoAtual;
  static bool _isEmailReal = false;
 
  static Future<List<String>?> listarEmailsDisponiveis() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/emails-disponiveis'));
      if (response.statusCode == 200) {
        List<dynamic> emails = jsonDecode(response.body);
        return emails.cast<String>();
      }
      return null;
    } catch (e) {
      print('Erro ao listar emails: $e');
      return null;
    }
  }
 
  static Future<Map<String, dynamic>?> enviarCodigo(String email) async {
    try {
      _emailAtual = email;
      _isEmailReal = _checkIfRealEmail(email);
     
      // Escolher endpoint baseado no tipo de email
      final endpoint = _isEmailReal
        ? '$baseUrl/enviar-codigo-real'  // Para emails reais (Gmail, etc.)
        : '$baseUrl/enviar-codigo';      // Para emails do banco
     
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );
     
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        print('✅ Código ${_isEmailReal ? "enviado para email real" : "salvo no banco"}: $email');
        return result;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Erro ao enviar código');
      }
    } catch (e) {
      print('❌ Erro ao enviar código: $e');
      rethrow;
    }
  }
 
  static Future<bool> verificarCodigo(String codigo) async {
    if (_emailAtual == null) return false;
   
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/verificar-codigo'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailAtual,
          'codigo': codigo,
        }),
      );
     
      if (response.statusCode == 200) {
        _codigoAtual = codigo;
        print('✅ Código verificado com sucesso');
        return true;
      } else {
        print('❌ Código inválido ou expirado');
        return false;
      }
    } catch (e) {
      print('❌ Erro ao verificar código: $e');
      return false;
    }
  }
 
  static Future<bool> redefinirSenha(String novaSenha) async {
    if (_emailAtual == null || _codigoAtual == null) {
      print('❌ Email ou código não encontrado');
      return false;
    }
   
    try {
      print('🔄 Enviando nova senha para: $_emailAtual');
      final response = await http.post(
        Uri.parse('$baseUrl/nova-senha'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailAtual,
          'codigo': _codigoAtual,
          'novaSenha': novaSenha,
        }),
      );
     
      print('📡 Status da resposta: ${response.statusCode}');
      print('📄 Corpo da resposta: ${response.body}');
     
      if (response.statusCode == 200) {
        print('✅ Senha redefinida com sucesso');
        _limparDados();
        return true;
      } else {
        final errorBody = jsonDecode(response.body);
        print('❌ Erro do servidor: ${errorBody['message'] ?? 'Erro desconhecido'}');
        return false;
      }
    } catch (e) {
      print('❌ Erro ao redefinir senha: $e');
      return false;
    }
  }
 
  static void _limparDados() {
    _emailAtual = null;
    _codigoAtual = null;
    _isEmailReal = false;
  }
 
  static bool _checkIfRealEmail(String email) {
    if (!email.contains('@')) return false;
   
    final domain = email.toLowerCase().substring(email.indexOf('@'));
    final realProviders = [
      '@gmail.com', '@yahoo.com', '@hotmail.com', '@outlook.com',
      '@live.com', '@icloud.com', '@protonmail.com', '@uol.com.br',
      '@bol.com.br', '@terra.com.br'
    ];
   
    return realProviders.contains(domain);
  }
 
  static String? get emailAtual => _emailAtual;
  static bool get isEmailReal => _isEmailReal;
}
 