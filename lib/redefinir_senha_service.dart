import 'dart:convert';
import 'package:http/http.dart' as http;

class RedefinirSenhaService {
  static const String baseUrl = 'http://localhost:8080/redefinir-senha';
  
  static String? _emailAtual;
  static String? _codigoAtual;
  
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
      final response = await http.post(
        Uri.parse('$baseUrl/enviar-codigo'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );
      
      if (response.statusCode == 200) {
        _emailAtual = email;
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Erro ao enviar código: $e');
      return null;
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
        return true;
      }
      return false;
    } catch (e) {
      print('Erro ao verificar código: $e');
      return false;
    }
  }
  
  static Future<bool> redefinirSenha(String novaSenha) async {
    if (_emailAtual == null || _codigoAtual == null) return false;
    
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/nova-senha'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailAtual,
          'codigo': _codigoAtual,
          'novaSenha': novaSenha,
        }),
      );
      
      if (response.statusCode == 200) {
        _limparDados();
        return true;
      }
      return false;
    } catch (e) {
      print('Erro ao redefinir senha: $e');
      return false;
    }
  }
  
  static void _limparDados() {
    _emailAtual = null;
    _codigoAtual = null;
  }
  
  static String? get emailAtual => _emailAtual;
}