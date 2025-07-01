import 'dart:convert';

import 'package:scientry_api/commons/models/user.dart';
import 'package:scientry_api/service/email_manager.dart';
import 'package:scientry_api/service/gsheets_manager.dart';
import 'package:scientry_api/service/jwt_manager.dart';
import 'package:shelf/shelf.dart';

class EmailVerificationHandler {
  GsheetsManager gsheetsManager = GsheetsManager();
  EmailManager emailManager = EmailManager();

  Future<Response> verifyEmail(Request request) async {
    try {
      // Extract the token from the query parameters
      final token = request.url.queryParameters['token'];

      if (token == null || token.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({
            "errorCode": -1,
            "errorMessage": "Missing or invalid token.",
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      String? isVerified = JWTManager.verifyEmailVerificationToken(token);

      if (isVerified == null) {
        return Response.forbidden(
          jsonEncode({
            "errorCode": -1,
            "errorMessage": "Invalid or expired token.",
          }),
          headers: {'Content-Type': 'application/json'},
        );
      } else if (isVerified.contains("@")) {
        UserModel? user = await gsheetsManager.getUserByField(
          field: "email",
          value: isVerified,
        );
        if (user == null || user.isDeleted == true) {
          return Response.notFound(
            jsonEncode({"errorCode": -1, "errorMessage": "User not found."}),
            headers: {'Content-Type': 'application/json'},
          );
        } else if (user.isEmailVerified == true) {
          // If the user is already verified
          return Response.ok(
            jsonEncode({
              "errorCode": 0,
              "errorMessage": "Email is already verified.",
            }),
            headers: {'Content-Type': 'application/json'},
          );
        } else {
          // Update the user's verification status
          final updatedUser = user.copyWith(
            isEmailVerified: true,
            updatedAt: DateTime.now().millisecondsSinceEpoch,
          );
          print("UserData: ${updatedUser.toJson()}");
          bool status = await gsheetsManager.addUpdateUser(updatedUser);

          if (!status) {
            return Response.internalServerError(
              body: jsonEncode({
                "errorCode": -1,
                "errorMessage": "Failed to update user.",
              }),
              headers: {'Content-Type': 'application/json'},
            );
          } else {
            // Successfully verified the email
            return Response.ok(
              jsonEncode({
                "errorCode": 0,
                "errorMessage": "Email verified successfully.",
              }),
              headers: {'Content-Type': 'application/json'},
            );
          }
        }
      } else {
        return Response.forbidden(
          jsonEncode({
            "errorCode": -1,
            "errorMessage": "Invalid token format.",
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          "errorCode": -1,
          "errorMessage": "An error occurred: ${e.toString()}",
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  Future<Response> requestEmailVerification(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body);
      String? email = data['email'];
      if (email == null || email.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({
            "errorCode": -1,
            "errorMessage": "Email is required.",
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      UserModel? user = await gsheetsManager.getUserByField(
        field: "email",
        value: email,
      );
      if (user == null || user.isDeleted == true) {
        return Response.notFound(
          jsonEncode({"errorCode": -1, "errorMessage": "User not found."}),
          headers: {'Content-Type': 'application/json'},
        );
      } else if (user.isEmailVerified == true) {
        return Response.ok(
          jsonEncode({
            "errorCode": 0,
            "errorMessage": "Email is already verified.",
          }),
          headers: {'Content-Type': 'application/json'},
        );
      } else {
        bool status = await emailManager.sendVerificationEmail(
          name: user.name!,
          email: user.email!,
        );
        if (!status) {
          return Response.internalServerError(
            body: jsonEncode({
              "errorCode": -1,
              "errorMessage": "Failed to send verification email.",
            }),
            headers: {'Content-Type': 'application/json'},
          );
        } else {
          return Response.ok(
            jsonEncode({
              "errorCode": 0,
              "errorMessage": "Verification email sent successfully.",
            }),
            headers: {'Content-Type': 'application/json'},
          );
        }
      }
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          "errorCode": -1,
          "errorMessage": "An error occurred: ${e.toString()}",
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }
}
