import 'dart:convert';

import 'package:shelf/shelf.dart';

class StatusHandler {
  Future<Response> getStatus(Request request) async {
    try {
      return Response.ok(
        jsonEncode({
          "errorCode": 0,
          "errorMessage": "Service is running smoothly.",
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          "errorCode": -1,
          "errorMessage": "An error occurred while checking service status.",
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }
}
