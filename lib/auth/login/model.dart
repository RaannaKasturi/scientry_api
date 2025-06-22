import 'dart:convert';

import 'package:scientry_api/commons/models/user.dart';

class LoginRequest {
  final String emailUsername;
  final String password;

  LoginRequest({required this.emailUsername, required this.password});

  LoginRequest copyWith({String? emailUsername, String? password}) =>
      LoginRequest(
        emailUsername: emailUsername ?? this.emailUsername,
        password: password ?? this.password,
      );

  factory LoginRequest.fromRawJson(String str) =>
      LoginRequest.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory LoginRequest.fromJson(Map<String, dynamic> json) => LoginRequest(
    emailUsername: json["emailUsername"],
    password: json["password"],
  );

  Map<String, dynamic> toJson() => {
    "emailUsername": emailUsername,
    "password": password,
  };
}

class LoginResponse {
  final UserModel? data;
  final int? errorCode;
  final String? errorMessage;

  LoginResponse({this.data, this.errorCode, this.errorMessage});

  LoginResponse copyWith({
    UserModel? data,
    int? errorCode,
    String? errorMessage,
  }) => LoginResponse(
    data: data ?? this.data,
    errorCode: errorCode ?? this.errorCode,
    errorMessage: errorMessage ?? this.errorMessage,
  );

  factory LoginResponse.fromRawJson(String str) =>
      LoginResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
    data: json["data"] == null ? null : UserModel.fromJson(json["data"]),
    errorCode: json["errorCode"],
    errorMessage: json["errorMessage"],
  );

  Map<String, dynamic> toJson() => {
    "data": data?.toJson(),
    "errorCode": errorCode,
    "errorMessage": errorMessage,
  };
}
