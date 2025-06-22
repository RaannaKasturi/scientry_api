import 'package:dotenv/dotenv.dart';

class SecretsManager {
  static final DotEnv env = DotEnv(includePlatformEnvironment: true)..load();

  static final String accessSecret = env['ACCESS_SECRET'] ?? "";
  static final String refreshSecret = env['REFRESH_SECRET'] ?? "";
  static final String fetchUsersEndpoint = env['FETCH_USERS_ENDPOINT'] ?? "";
  static final String addUpdateUsersEndpoint =
      env['ADD_UPDATE_USERS_ENDPOINT'] ?? "";
}
