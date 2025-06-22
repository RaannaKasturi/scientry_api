import 'dart:math';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:scientry_api/service/secrets_manager.dart';

class JWTManager {
  static final String _accessSecret = SecretsManager.accessSecret;
  static final String _refreshSecret = SecretsManager.refreshSecret;
  static final String _emailVerificationSecret =
      SecretsManager.emailVerificationSecret;
  static final String resetPasswordSecret = SecretsManager.resetPasswordSecret;

  static const Duration _accessExpiry = Duration(days: 356);
  static const Duration _refreshExpiry = Duration(days: 356 * 10);
  static const Duration _emailVerificationExpiry = Duration(days: 1);
  static const Duration _resetPasswordExpiry = Duration(minutes: 5);

  /// Generate access token only
  static String generateAccessToken({required String userId}) {
    final payload = {'sub': userId};
    return JWT(
      payload,
      issuer: "SCIENTRY-BINARYBIOLOGY",
      jwtId: DateTime.now().millisecondsSinceEpoch.toString(),
    ).sign(SecretKey(_accessSecret), expiresIn: _accessExpiry);
  }

  /// Generate refresh token only
  static String generateRefreshToken({required String userId}) {
    final payload = {'sub': userId};
    return JWT(
      payload,
      issuer: "SCIENTRY-BINARYBIOLOGY",
      jwtId: DateTime.now().millisecondsSinceEpoch.toString(),
    ).sign(SecretKey(_refreshSecret), expiresIn: _refreshExpiry);
  }

  /// Verify Access Token
  static JWT? verifyAccessToken(String token) {
    try {
      return JWT.verify(token, SecretKey(_accessSecret));
    } catch (_) {
      return null;
    }
  }

  /// Verify Refresh Token
  static JWT? verifyRefreshToken(String token) {
    try {
      return JWT.verify(token, SecretKey(_refreshSecret));
    } catch (_) {
      return null;
    }
  }

  /// Decode without verification (e.g. for non-critical usage)
  static Map<String, dynamic>? decode(String token) {
    try {
      return JWT.decode(token).payload as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  /// Generate email verification token
  static String generateEmailVerificationToken({required String email}) {
    final payload = {'email': email};
    return JWT(
      payload,
      issuer: "SCIENTRY-BINARYBIOLOGY",
      jwtId: DateTime.now().millisecondsSinceEpoch.toString(),
    ).sign(
      SecretKey(_emailVerificationSecret),
      expiresIn: _emailVerificationExpiry,
    );
  }

  /// Verify email verification token
  static String? verifyEmailVerificationToken(String token) {
    try {
      final jwt = JWT.verify(token, SecretKey(_emailVerificationSecret));
      return jwt.payload['email'] as String?;
    } catch (_) {
      return null;
    }
  }

  // Generate code for password reset
  static String generateResetCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random.secure();
    return List.generate(6, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  // Create reset password token
  static String createResetToken(String userId, String code) {
    final jwt = JWT(
      {'code': code, 'sub': userId},
      issuer: 'SCIENTRY-BINARYBIOLOGY',
      jwtId: DateTime.now().millisecondsSinceEpoch.toString(),
    );
    return jwt.sign(
      SecretKey(resetPasswordSecret),
      expiresIn: _resetPasswordExpiry,
    );
  }

  static bool verifyResetToken(String token, String submittedCode) {
    try {
      final jwt = JWT.verify(token, SecretKey(resetPasswordSecret));
      return jwt.payload['code'] == submittedCode;
    } catch (e) {
      throw Exception('Invalid or expired token');
    }
  }
}
