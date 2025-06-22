import 'dart:convert';

class ResetPasswordRequest {
  final String? emailUsername;
  final String? password;
  final String? code;
  final String? token;

  ResetPasswordRequest({
    this.emailUsername,
    this.password,
    this.code,
    this.token,
  });

  ResetPasswordRequest copyWith({
    String? emailUsername,
    String? password,
    String? code,
    String? token,
  }) => ResetPasswordRequest(
    emailUsername: emailUsername ?? this.emailUsername,
    password: password ?? this.password,
    code: code ?? this.code,
    token: token ?? this.token,
  );

  factory ResetPasswordRequest.fromRawJson(String str) =>
      ResetPasswordRequest.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ResetPasswordRequest.fromJson(Map<String, dynamic> json) =>
      ResetPasswordRequest(
        emailUsername: json["emailUsername"],
        password: json["password"],
        code: json["code"],
        token: json["token"],
      );

  Map<String, dynamic> toJson() => {
    "emailUsername": emailUsername,
    "password": password,
    "code": code,
    "token": token,
  };
}
