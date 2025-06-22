import 'package:dotenv/dotenv.dart';

class SecretsManager {
  static final DotEnv env = DotEnv(includePlatformEnvironment: true)..load();

  static final String accessSecret = env['ACCESS_SECRET'] ?? "";
  static final String refreshSecret = env['REFRESH_SECRET'] ?? "";
  static final String emailVerificationSecret =
      env['EMAIL_VERIFICATION_SECRET'] ?? "";
  static final String resetPasswordSecret = env['RESET_PASSWORD_SECRET'] ?? "";

  static final String fetchUsersEndpoint = env['FETCH_USERS_ENDPOINT'] ?? "";
  static final String addUpdateUsersEndpoint =
      env['ADD_UPDATE_USERS_ENDPOINT'] ?? "";

  static final String brevoMailAPIKey = env['BREVO_MAIL_API_KEY'] ?? "";

  static final String host = env['HOST'] ?? "http://localhost:3000";
}
