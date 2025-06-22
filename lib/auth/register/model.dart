import 'dart:convert';

import 'package:scientry_api/commons/models/user.dart';

class RegisterResponse {
  final UserModel? data;
  final int? errorCode;
  final String? errorMessage;

  RegisterResponse({this.data, this.errorCode, this.errorMessage});

  RegisterResponse copyWith({
    UserModel? data,
    int? errorCode,
    String? errorMessage,
  }) => RegisterResponse(
    data: data ?? this.data,
    errorCode: errorCode ?? this.errorCode,
    errorMessage: errorMessage ?? this.errorMessage,
  );

  factory RegisterResponse.fromRawJson(String str) =>
      RegisterResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory RegisterResponse.fromJson(Map<String, dynamic> json) =>
      RegisterResponse(
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
