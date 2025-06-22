import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:scientry_api/service/secrets_manager.dart';

class JWTManager {
  static final String _accessSecret = SecretsManager.accessSecret;
  static final String _refreshSecret = SecretsManager.refreshSecret;

  static const Duration _accessExpiry = Duration(days: 356);
  static const Duration _refreshExpiry = Duration(days: 356 * 10);

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
}
