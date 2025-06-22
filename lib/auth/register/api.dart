import 'dart:convert';

import 'package:scientry_api/auth/register/model.dart';
import 'package:scientry_api/commons/models/user.dart';
import 'package:scientry_api/service/executor_manager.dart';
import 'package:scientry_api/service/gsheets_manager.dart';
import 'package:scientry_api/service/password_manager.dart';
import 'package:shelf/shelf.dart';
import 'package:uuid/uuid.dart';

class RegisterApi {
  Future<Response> handler(Request request) async {
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

    final result = await ExecutorManager().pool.compute(_registerHandler, body);

    return Response(
      result['statusCode'],
      body: jsonEncode(result['body']),
      headers: {'Content-Type': 'application/json'},
    );
  }
}

/// This function will be executed in a separate isolate.
/// It must return only sendable types (Map, List, String, int, bool).
Future<Map<String, dynamic>> _registerHandler(String body) async {
  try {
    final data = UserModel.fromJson(json.decode(body));

    if (data.username == null ||
        data.password == null ||
        data.email == null ||
        data.name == null) {
      return _buildResponse(
        400,
        RegisterResponse(
          data: null,
          errorCode: -1,
          errorMessage: "Username, password, email, and name are required",
        ),
      );
    }

    // Validate email format
    final emailRegex = RegExp(r'^[a-zA-Z0-9._]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(data.email!)) {
      return _buildResponse(
        400,
        RegisterResponse(
          data: null,
          errorCode: -1,
          errorMessage: "Invalid email format",
        ),
      );
    }

    // Check for duplicate email
    UserModel? existingUser = await GsheetsManager().getUserByField(
      field: 'email',
      value: data.email!,
    );
    print("Existing user by email: $existingUser");
    if (existingUser != null) {
      return _buildResponse(
        409,
        RegisterResponse(
          data: null,
          errorCode: -1,
          errorMessage: "Email already registered",
        ),
      );
    }

    // Check for duplicate username
    existingUser = await GsheetsManager().getUserByField(
      field: 'username',
      value: data.username!,
    );
    print("Existing user: $existingUser");
    if (existingUser != null) {
      return _buildResponse(
        409,
        RegisterResponse(
          data: null,
          errorCode: -1,
          errorMessage: "Username already taken",
        ),
      );
    }

    // Check password strength
    String? passwordStatus = await PasswordManager().isStrongPassword(
      data.password!,
    );
    if (passwordStatus != null) {
      return _buildResponse(
        400,
        RegisterResponse(
          data: null,
          errorCode: -1,
          errorMessage: passwordStatus,
        ),
      );
    }

    // Hash password
    String hashedPassword = await PasswordManager().encodePassword(
      data.password!,
    );

    // Create user model
    final newUser = UserModel(
      userId: "SCIENTRY-${const Uuid().v4()}",
      username: data.username!,
      password: hashedPassword,
      name: data.name!,
      email: data.email!,
      avatar: '',
      bio: '',
      refreshToken: '',
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
      return _buildResponse(
        500,
        RegisterResponse(
          data: null,
          errorCode: -1,
          errorMessage: "Failed to register user",
        ),
      );
    }

    // Return success
    return _buildResponse(
      201,
      RegisterResponse(
        data: newUser,
        errorCode: 0,
        errorMessage: "User registered successfully",
      ),
    );
  } catch (e) {
    return _buildResponse(
      500,
      RegisterResponse(
        data: null,
        errorCode: -1,
        errorMessage: "Unexpected error: $e",
      ),
    );
  }
}

Map<String, dynamic> _buildResponse(int statusCode, RegisterResponse response) {
  return {'statusCode': statusCode, 'body': response.toJson()};
}
