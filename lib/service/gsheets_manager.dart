import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:scientry_api/commons/models/user.dart';
import 'package:scientry_api/service/dio_instance.dart';

class GsheetsManager {
  // This class is responsible for managing Google Sheets operations.

  static const String _fetchUsersEndpoint =
      "https://script.google.com/macros/s/AKfycbwCBnLpgE-LA9Vey6tNVPbO5FWlva6zORgoPpmOIXSCxu3qPUXhNsVL06GPbM1b8iVapg/exec";
  static const String _addUpdateUsersEndpoint =
      "https://script.google.com/macros/s/AKfycbxFwd5B0cInrDBuAO4eCo6Ac7T0Hu8pOpXuSCBMWpCKDurWNDT4EBmrRdFgibClaPiSPQ/exec";

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
        print("Response from GSheets: ${response.data}");
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
