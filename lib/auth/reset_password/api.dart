import 'dart:convert';

import 'package:scientry_api/auth/reset_password/model.dart';
import 'package:scientry_api/commons/models/user.dart';
import 'package:scientry_api/service/email_manager.dart';
import 'package:scientry_api/service/gsheets_manager.dart';
import 'package:scientry_api/service/jwt_manager.dart';
import 'package:scientry_api/service/password_manager.dart';
import 'package:shelf/shelf.dart';

class ResetPasswordHandler {
  GsheetsManager gsheetsManager = GsheetsManager();
  EmailManager emailManager = EmailManager();
  PasswordManager passwordManager = PasswordManager();

  Future<Response> sendResetPassCode(Request request) async {
    try {
      final body = await request.readAsString();
      final data = ResetPasswordRequest.fromRawJson(body);
      if (data.emailUsername!.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({
            "errorCode": -1,
            "errorMessage": "Email/Username cannot be empty.",
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }
      UserModel? user;
      if (data.emailUsername!.contains('@')) {
        user = await gsheetsManager.getUserByField(
          field: 'email',
          value: data.emailUsername!,
        );
      } else {
        user = await gsheetsManager.getUserByField(
          field: 'username',
          value: data.emailUsername!,
        );
      }

      if (user == null || user.isDeleted == true) {
        return Response.notFound(
          jsonEncode({"errorCode": -1, "errorMessage": "User not found."}),
          headers: {'Content-Type': 'application/json'},
        );
      } else if (user.isEmailVerified == false) {
        bool status = await emailManager.sendVerificationEmail(
          name: user.name!,
          email: user.email!,
        );
        if (!status) {
          return Response.internalServerError(
            body: jsonEncode({
              "errorCode": -1,
              "errorMessage":
                  "Failed to send email verification. Please try again later.",
            }),
            headers: {'Content-Type': 'application/json'},
          );
        } else {
          // If email is not verified, send a verification email
          return Response.forbidden(
            jsonEncode({
              "errorCode": -1,
              "errorMessage":
                  "Email not verified. Please verify your email first. Email verification link has been sent to ${user.email}.",
            }),
            headers: {'Content-Type': 'application/json'},
          );
        }
      } else {
        // Generate reset password token
        final code = JWTManager.generateResetCode();
        final token = JWTManager.createResetToken(user.userId!, code);
        bool status = await emailManager.sendResetPasswordEmail(
          name: user.name!,
          email: user.email!,
          code: code,
        );
        if (status) {
          return Response.ok(
            jsonEncode({
              "errorCode": 0,
              "errorMessage":
                  "Reset password code sent successfully. Please check your email.",
              "token": token,
            }),
            headers: {'Content-Type': 'application/json'},
          );
        } else {
          return Response.internalServerError(
            body: jsonEncode({
              "errorCode": -1,
              "errorMessage":
                  "Failed to send reset password code. Please try again later.",
            }),
            headers: {'Content-Type': 'application/json'},
          );
        }
      }
    } catch (e) {
      print("Error in sendResetPassCode: ${e.toString()}");
      return Response.internalServerError(
        body: jsonEncode({
          "errorCode": -1,
          "errorMessage":
              "An error occurred while sending the reset password code: ${e.toString()}",
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  Future<Response> resetPassword(Request request) async {
    try {
      // Parse the request body
      final body = await request.readAsString();
      final data = ResetPasswordRequest.fromRawJson(body);
      if (data.emailUsername == null ||
          data.emailUsername!.isEmpty ||
          data.token == null ||
          data.password!.isEmpty ||
          data.password == null ||
          data.code == null ||
          data.code!.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({
            "errorCode": 400,
            "errorMessage":
                "Email/Username, Code and Password cannot be empty.",
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final code = data.code;
      final token = data.token;
      if (code!.isEmpty || token!.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({
            "errorCode": 400,
            "errorMessage": "Code and Token cannot be empty.",
          }),
          headers: {'Content-Type': 'application/json'},
        );
      } else {
        final decodedToken = JWTManager.verifyResetToken(token, code);
        if (!decodedToken) {
          return Response.forbidden(
            jsonEncode({
              "errorCode": -1,
              "errorMessage": "Invalid or expired reset password token.",
            }),
            headers: {'Content-Type': 'application/json'},
          );
        }
      }

      UserModel? user;
      if (data.emailUsername!.contains('@')) {
        user = await gsheetsManager.getUserByField(
          field: 'email',
          value: data.emailUsername!,
        );
      } else {
        user = await gsheetsManager.getUserByField(
          field: 'username',
          value: data.emailUsername!,
        );
      }

      if (user == null || user.isDeleted == true) {
        return Response.notFound(
          jsonEncode({"errorCode": -1, "errorMessage": "User not found."}),
          headers: {'Content-Type': 'application/json'},
        );
      } else if (user.isEmailVerified == false) {
        bool status = await emailManager.sendVerificationEmail(
          name: user.name!,
          email: user.email!,
        );
        if (!status) {
          return Response.internalServerError(
            body: jsonEncode({
              "errorCode": -1,
              "errorMessage":
                  "Failed to send email verification. Please try again later.",
            }),
            headers: {'Content-Type': 'application/json'},
          );
        } else {
          // If email is not verified, send a verification email
          return Response.forbidden(
            jsonEncode({
              "errorCode": -1,
              "errorMessage":
                  "Email not verified. Please verify your email first. Email verification link has been sent to ${user.email}.",
            }),
            headers: {'Content-Type': 'application/json'},
          );
        }
      } else {
        String? isPassStrong = await passwordManager.isStrongPassword(
          data.password!,
        );
        if (isPassStrong != null) {
          return Response.badRequest(
            body: jsonEncode({"errorCode": -1, "errorMessage": isPassStrong}),
            headers: {'Content-Type': 'application/json'},
          );
        } else {
          // Update the user's password
          final newUser = user.copyWith(
            password: await passwordManager.encodePassword(data.password!),
            updatedAt: DateTime.now().millisecondsSinceEpoch,
          );
          bool updateStatus = await gsheetsManager.addUpdateUser(newUser);
          if (updateStatus) {
            return Response.ok(
              jsonEncode({
                "errorCode": 0,
                "errorMessage": "Password updated successfully.",
              }),
              headers: {'Content-Type': 'application/json'},
            );
          } else {
            return Response.internalServerError(
              body: jsonEncode({
                "errorCode": -1,
                "errorMessage":
                    "Failed to update password. Please try again later.",
              }),
              headers: {'Content-Type': 'application/json'},
            );
          }
        }
      }
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          "errorCode": -1,
          "errorMessage":
              "An error occurred while resetting the password: ${e.toString()}",
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }
}
