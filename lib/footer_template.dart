import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class FooterTemplate extends StatelessWidget {
  const FooterTemplate({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 30),
        Container(
          width: double.infinity,
          color: const Color(0xFF90017F),
          padding: const EdgeInsets.symmetric(vertical: 35, horizontal: 20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Colors.white, Color(0xFFB19CD9), Colors.white],
                    ).createShader(bounds),
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: "Game",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: "Legends"),
                        ],
                      ),
                      style: GoogleFonts.blackOpsOne(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "🎮 Game Legends é uma plataforma dedicada a jogos indie, fornecendo uma maneira fácil para desenvolvedores distribuírem seus jogos e para jogadores descobrirem novas experiências! 🚀",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        height: 1.6,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity( 0.3),
                            offset: const Offset(2, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 35),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 40,
                    runSpacing: 20,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF00D4FF), Color(0xFF007BFF)],
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.phone, color: Colors.white, size: 22),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            "(99) 99999-9999",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFFFF6B35), Color(0xFFFF8E53)],
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.email, color: Colors.white, size: 22),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            "info@gamelegends.com",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 35),
                  const Text(
                    "🌟 Siga-nos nas Redes Sociais 🌟",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildColorfulSocialButton(
                        Icons.facebook,
                        [Color(0xFF1877F2), Color(0xFF42A5F5)],
                        () => launchUrl(Uri.parse('https://www.facebook.com/profile.php?id=61578797307500')),
                      ),
                      const SizedBox(width: 20),
                      _buildColorfulSocialButton(
                        Icons.camera_alt,
                        [Color(0xFFB19CD9), Color(0xFFD1C4E9)],
                        () {},
                      ),
                      const SizedBox(width: 20),
                      _buildColorfulSocialButton(
                        Icons.alternate_email,
                        [Color(0xFFE91E63), Color(0xFFFF6B9D)],
                        () => launchUrl(Uri.parse('https://www.instagram.com/game._legends/')),
                      ),
                      const SizedBox(width: 20),
                      _buildColorfulSocialButton(
                        Icons.business,
                        [Color(0xFF0077B5), Color(0xFF00A0DC)],
                        () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  InkWell(
                    onTap: () => Navigator.pushNamed(context, '/privacidade'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6A0DAD), Color(0xFF9C27B0)],
                        ),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity( 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.privacy_tip, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text(
                            "Política de Privacidade",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    "© Game Legends ✨ | Feito com 💜 pelo nosso time incrível!",
                    style: TextStyle(
                      color: Colors.white.withOpacity( 0.9),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildColorfulSocialButton(IconData icon, List<Color> colors, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: colors.first.withOpacity( 0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 28),
        onPressed: onPressed,
        splashRadius: 30,
      ),
    );
  }
}
