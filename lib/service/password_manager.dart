import 'dart:math';

import 'package:bcrypt/bcrypt.dart';

class PasswordManager {
  Future<String?> isStrongPassword(String password) async {
    if (password.length < 8 || password.length > 25) {
      return "Password must be between 8–25 characters long";
    }
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return "Password must contain at least one uppercase letter";
    }
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return "Password must contain at least one lowercase letter";
    }
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return "Password must contain at least one number";
    }
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      return "Password must contain at least one special character";
    }
    return null;
  }

  Future<String> encodePassword(String password) async {
    return BCrypt.hashpw(
      password,
      BCrypt.gensalt(
        secureRandom: Random(DateTime.now().millisecondsSinceEpoch % 1000),
      ),
    );
  }

  Future<bool> verifyPassword(
    String plainPassword,
    String hashedPassword,
  ) async {
    try {
      return BCrypt.checkpw(plainPassword, hashedPassword);
    } catch (e) {
      return false;
    }
  }
}
