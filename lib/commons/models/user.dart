import 'dart:convert';

class UserModel {
  final String? userId;
  final String? username;
  final String? password;
  final String? name;
  final String? email;
  final String? avatar;
  final String? bio;
  final String? accessToken;
  final bool? isEmailVerified;
  final int? createdAt;
  final int? updatedAt;
  final String? fcmToken;
  final String? subscribedTopics;
  final String? bookmarkedPosts;
  final bool? isDeleted;

  UserModel({
    this.userId,
    this.username,
    this.password,
    this.name,
    this.email,
    this.avatar,
    this.bio,
    this.accessToken,
    this.isEmailVerified,
    this.createdAt,
    this.updatedAt,
    this.fcmToken,
    this.subscribedTopics,
    this.bookmarkedPosts,
    this.isDeleted,
  });

  UserModel copyWith({
    String? userId,
    String? username,
    String? password,
    String? name,
    String? email,
    String? avatar,
    String? bio,
    String? accessToken,
    bool? isEmailVerified,
    int? createdAt,
    int? updatedAt,
    String? fcmToken,
    String? subscribedTopics,
    String? bookmarkedPosts,
    bool? isDeleted,
  }) => UserModel(
    userId: userId ?? this.userId,
    username: username ?? this.username,
    password: password ?? this.password,
    name: name ?? this.name,
    email: email ?? this.email,
    avatar: avatar ?? this.avatar,
    bio: bio ?? this.bio,
    accessToken: accessToken ?? this.accessToken,
    isEmailVerified: isEmailVerified ?? this.isEmailVerified,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    fcmToken: fcmToken ?? this.fcmToken,
    subscribedTopics: subscribedTopics ?? this.subscribedTopics,
    bookmarkedPosts: bookmarkedPosts ?? this.bookmarkedPosts,
    isDeleted: isDeleted ?? this.isDeleted,
  );

  factory UserModel.fromRawJson(String str) =>
      UserModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    userId: json["userId"],
    username: json["username"],
    password: json["password"],
    name: json["name"],
    email: json["email"],
    avatar: json["avatar"],
    bio: json["bio"],
    accessToken: json["accessToken"],
    isEmailVerified: json["isEmailVerified"].toString().toLowerCase() == 'true',
    createdAt: json["createdAt"],
    updatedAt: json["updatedAt"],
    fcmToken: json["fcmToken"],
    subscribedTopics: json["subscribedTopics"],
    bookmarkedPosts: json["bookmarkedPosts"],
    isDeleted: json["isDeleted"].toString().toLowerCase() == 'true',
  );

  Map<String, dynamic> toJson() => {
    "userId": userId,
    "username": username,
    "password": password,
    "name": name,
    "email": email,
    "avatar": avatar,
    "bio": bio,
    "accessToken": accessToken,
    "isEmailVerified": isEmailVerified,
    "createdAt": createdAt,
    "updatedAt": updatedAt,
    "fcmToken": fcmToken,
    "subscribedTopics": subscribedTopics,
    "bookmarkedPosts": bookmarkedPosts,
    "isDeleted": isDeleted,
  };
}
