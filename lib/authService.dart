import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  /// Retourne true si un userID existe dans les SharedPreferences
  Future<bool> login() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userIDShared = prefs.getString('userID');
    // Debug facultatif
    // debugPrint("userIDShared: $userIDShared");
    return userIDShared != null && userIDShared.isNotEmpty;
  }

  /// Déconnexion : efface les clés de session basiques
  Future<void> logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userID');
    await prefs.remove('email');
    // Ajoutez ici d'autres clés si nécessaire
    await Future<void>.delayed(const Duration(milliseconds: 300));
  }
}
