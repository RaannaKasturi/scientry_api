import 'dart:convert';

import 'package:scientry_api/auth/login/model.dart';
import 'package:scientry_api/commons/models/user.dart';
import 'package:scientry_api/service/gsheets_manager.dart';
import 'package:scientry_api/service/jwt_manager.dart';
import 'package:scientry_api/service/password_manager.dart';
import 'package:shelf/shelf.dart';

class LoginHandler {
  GsheetsManager gsheetsManager = GsheetsManager();
  PasswordManager passwordManager = PasswordManager();

  Future<Response> handler(Request request) async {
    try {
      // Check if the request body is empty
      String body = await request.readAsString();
      if (body.isEmpty) {
        return Response.badRequest(
          body: LoginResponse(
            data: null,
            errorCode: -1,
            errorMessage: "Request body cannot be empty",
          ).toJson(),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Parse the request body
      LoginRequest loginRequest = LoginRequest.fromJson(json.decode(body));

      // Validate the request body
      if (loginRequest.emailUsername.isEmpty || loginRequest.password.isEmpty) {
        return Response.badRequest(
          body: LoginResponse(
            data: null,
            errorCode: -1,
            errorMessage: "Email/Username and password are required",
          ).toJson(),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Get the user by email or username
      UserModel? user;

      if (loginRequest.emailUsername.contains('@')) {
        user = await gsheetsManager.getUserByField(
          field: 'email',
          value: loginRequest.emailUsername,
        );
      } else {
        user = await gsheetsManager.getUserByField(
          field: 'username',
          value: loginRequest.emailUsername,
        );
      }
      if (user == null || user.isDeleted == true) {
        return Response.notFound(
          LoginResponse(
            data: null,
            errorCode: -1,
            errorMessage: "User not found",
          ).toJson(),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Verify the password
      bool isPasswordValid = await passwordManager.verifyPassword(
        loginRequest.password,
        user.password!,
      );
      if (!isPasswordValid) {
        return Response.forbidden(
          LoginResponse(
            data: null,
            errorCode: -1,
            errorMessage: "Invalid password",
          ).toJson(),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Generate a new access token for the user
      String token = JWTManager.generateAccessToken(userId: user.userId!);

      user = user.copyWith(accessToken: token);

      return Response.ok(
        jsonEncode(
          LoginResponse(
            data: user,
            errorCode: 0,
            errorMessage: "Login successful",
          ).toJson(),
        ),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode(
          LoginResponse(
            data: null,
            errorCode: -1,
            errorMessage: "An error occurred: ${e.toString()}",
          ).toJson(),
        ),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }
}
