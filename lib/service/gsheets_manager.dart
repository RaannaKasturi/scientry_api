import 'package:dio/dio.dart';
import 'package:scientry_api/commons/models/user.dart';
import 'package:scientry_api/service/dio_instance.dart';
import 'package:scientry_api/service/secrets_manager.dart';

class GsheetsManager {
  // This class is responsible for managing Google Sheets operations.

  static final String _fetchUsersEndpoint = SecretsManager.fetchUsersEndpoint;
  static final String _addUpdateUsersEndpoint =
      SecretsManager.addUpdateUsersEndpoint;

  Future<UserModel?> getUserByField({
    required String field,
    required String value,
  }) async {
    try {
      Response response = await DioInstance.instance.get(
        _fetchUsersEndpoint,
        queryParameters: {'field': field, 'data': value},
      );
      if (response.data['status'] == 'success') {
        final data = response.data['user'];
        return UserModel.fromJson(data);
      } else {
        return null;
      }
    } catch (e) {
      print("Error fetching user by $field: $value - $e");
      return null;
    }
  }

  Future<bool> addUpdateUser(UserModel user) async {
    try {
      // Make POST request without following redirects automatically
      Response response = await DioInstance.instance.post(
        _addUpdateUsersEndpoint,
        data: user.toJson()
          ..addEntries([MapEntry('secret', 'SileruAgarthaPassword')]),
        options: Options(
          followRedirects: false,
          validateStatus: (status) => status != null && status < 400,
        ),
      );

      // If it's a redirect (typically 302 or 301)
      if (response.isRedirect == true ||
          (response.statusCode != null &&
              response.statusCode! >= 300 &&
              response.statusCode! < 400)) {
        final redirectedUrl = response.headers.value('location');
        if (redirectedUrl != null) {
          final redirectedResponse = await DioInstance.instance.get(
            redirectedUrl,
          );
          if (redirectedResponse.data['result'] == 'added' ||
              redirectedResponse.data['result'] == 'updated') {
            return true;
          } else {
            return false;
          }
        } else {
          return false;
        }
      } else {
        if (response.data['result'] == 'added' ||
            response.data['result'] == 'updated') {
          return true;
        } else {
          return false;
        }
      }
    } catch (e) {
      print("Error adding/updating user: $e");
      return false;
    }
  }
}
