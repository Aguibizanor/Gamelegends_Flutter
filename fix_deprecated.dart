import 'dart:io';

void main() {
  final directory = Directory('lib');
  final files = directory.listSync(recursive: true)
      .where((file) => file.path.endsWith('.dart'))
      .cast<File>();

  for (final file in files) {
    String content = file.readAsStringSync();
    
    // Fix withOpacity -> withValues
    content = content.replaceAllMapped(
      RegExp(r'\.withOpacity\(([^)]+)\)'),
      (match) => '.withValues(alpha: ${match.group(1)})',
    );
    
    // Fix value -> initialValue in form fields
    content = content.replaceAllMapped(
      RegExp(r'(\s+)value:\s*([^,\n]+),'),
      (match) => '${match.group(1)}initialValue: ${match.group(2)},',
    );
    
    file.writeAsStringSync(content);
    print('Fixed: ${file.path}');
  }
  
  print('All deprecated warnings fixed!');
}