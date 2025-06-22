import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

class JWTManager {
  static const String _accessSecret = String.fromEnvironment(
    'ACCESS_SECRET',
    defaultValue: 'access-secret-key',
  );
  static const String _refreshSecret = String.fromEnvironment(
    'REFRESH_SECRET',
    defaultValue: 'refresh-secret-key',
  );

  static const Duration _accessExpiry = Duration(days: 356);
  static const Duration _refreshExpiry = Duration(days: 356 * 10);

  /// Generate access & refresh tokens
  static Map<String, String> generateTokens({
    required String userId,
    String? role,
  }) {
    final payload = {'sub': userId, if (role != null) 'role': role};

    final accessToken = JWT(
      payload,
    ).sign(SecretKey(_accessSecret), expiresIn: _accessExpiry);

    final refreshToken = JWT(
      payload,
    ).sign(SecretKey(_refreshSecret), expiresIn: _refreshExpiry);

    return {'accessToken': accessToken, 'refreshToken': refreshToken};
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
