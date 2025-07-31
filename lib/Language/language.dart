import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart' show setAppLocale;
import '../Home/homeActivity.dart';
import '../Login/login.dart';
import '../Colors/colors.dart';

class LanguageActivity extends StatefulWidget {
  final bool fromHome;
  const LanguageActivity({Key? key, required this.fromHome}) : super(key: key);

  @override
  State<LanguageActivity> createState() => _LanguageActivityState();
}

class _LanguageActivityState extends State<LanguageActivity> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo
                Image.asset('images/logotransparents.png', height: 160),
                const SizedBox(height: 24),

                // Bouton Play
                GestureDetector(
                  onTap: () {
                    // TODO: lancer démo audio/vidéo si besoin
                  },
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      size: 36,
                      color: Colors.black54,
                    ),
                  ),
                ),
                const SizedBox(height: 48),

                // English
                _LangButton(
                  text: 'English',
                  color: accentColor,
                  onTap: () => _pick('en'),
                ),
                const SizedBox(height: 16),

                // العربية
                _LangButton(
                  text: 'العربية',
                  color: primaryColor,
                  onTap: () => _pick('ar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pick(String lang) async {
    await setAppLocale(lang);
    final prefs = await SharedPreferences.getInstance();
    final isLogged = (prefs.getString('userID') ?? '').isNotEmpty;

    if (!mounted) return;
    if (widget.fromHome) {
      Navigator.pop(context);
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => isLogged ? HomeActivity(false) : LoginActivity()),
        (_) => false,
      );
    }
  }
}

class _LangButton extends StatelessWidget {
  final String text;
  final Color color;
  final VoidCallback onTap;
  const _LangButton({
    Key? key,
    required this.text,
    required this.color,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: onTap,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontFamily: 'cocon-next-arabic-regular',
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
