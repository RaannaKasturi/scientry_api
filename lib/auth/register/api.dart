import 'dart:convert';

import 'package:scientry_api/auth/register/model.dart';
import 'package:scientry_api/commons/models/user.dart';
import 'package:scientry_api/service/gsheets_manager.dart';
import 'package:scientry_api/service/jwt_manager.dart';
import 'package:scientry_api/service/password_manager.dart';
import 'package:shelf/shelf.dart';
import 'package:uuid/uuid.dart';

class RegisterHandler {
  GsheetsManager gsheetsManager = GsheetsManager();
  PasswordManager passwordManager = PasswordManager();

  Future<Response> register(Request request) async {
    try {
      // Check if the request body is empty
      final body = await request.readAsString();
      if (body.isEmpty) {
        return Response.badRequest(
          body: json.encode(
            RegisterResponse(
              data: null,
              errorCode: -1,
              errorMessage: "Request body cannot be empty",
            ).toJson(),
          ),
          headers: {'Content-Type': 'application/json'},
        );
      }
      final data = UserModel.fromJson(json.decode(body));

      if (data.username == null ||
          data.password == null ||
          data.email == null ||
          data.name == null) {
        return Response.badRequest(
          body: json.encode(
            RegisterResponse(
              data: null,
              errorCode: -1,
              errorMessage: "Username, password, email, and name are required",
            ).toJson(),
          ),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Validate email format
      final emailRegex = RegExp(
        r'^[a-zA-Z0-9._]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
      );
      if (!emailRegex.hasMatch(data.email!)) {
        return Response.badRequest(
          body: json.encode(
            RegisterResponse(
              data: null,
              errorCode: -1,
              errorMessage: "Invalid email format",
            ).toJson(),
          ),
          headers: {'Content-Type': 'application/json'},
        );
      }

      UserModel? existingUser;

      // Check for duplicate email
      existingUser = await gsheetsManager.getUserByField(
        field: 'email',
        value: data.email!,
      );
      if (existingUser != null && existingUser.isDeleted != true) {
        return Response.forbidden(
          json.encode(
            RegisterResponse(
              data: null,
              errorCode: -1,
              errorMessage: "Email already registered",
            ).toJson(),
          ),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Check for duplicate username
      existingUser = await gsheetsManager.getUserByField(
        field: 'username',
        value: data.username!,
      );
      if (existingUser != null && existingUser.isDeleted != true) {
        return Response.forbidden(
          json.encode(
            RegisterResponse(
              data: null,
              errorCode: -1,
              errorMessage: "Username already taken",
            ).toJson(),
          ),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Check password strength
      String? passwordStatus = await passwordManager.isStrongPassword(
        data.password!,
      );
      if (passwordStatus != null) {
        return Response.badRequest(
          body: json.encode(
            RegisterResponse(
              data: null,
              errorCode: -1,
              errorMessage: passwordStatus,
            ).toJson(),
          ),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Hash password
      String hashedPassword = await PasswordManager().encodePassword(
        data.password!,
      );

      // Generate userId
      String userId = "SCIENTRY-${const Uuid().v4()}";

      // Create user model
      final newUser = UserModel(
        userId: userId,
        username: data.username!,
        password: hashedPassword,
        name: data.name!,
        email: data.email!,
        avatar: '',
        bio: '',
        accessToken: JWTManager.generateRefreshToken(userId: userId),
        isEmailVerified: false,
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
        fcmToken: '',
        subscribedTopics: "",
        bookmarkedPosts: "",
        isDeleted: false,
      );

      // Store in Google Sheets
      bool success = await GsheetsManager().addUpdateUser(newUser);
      if (!success) {
        return Response.internalServerError(
          body: json.encode(
            RegisterResponse(
              data: null,
              errorCode: -1,
              errorMessage: "Failed to register user",
            ).toJson(),
          ),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Return success
      return Response.ok(
        json.encode(
          RegisterResponse(
            data: newUser,
            errorCode: 0,
            errorMessage: "User registered successfully",
          ).toJson(),
        ),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: json.encode(
          RegisterResponse(
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
