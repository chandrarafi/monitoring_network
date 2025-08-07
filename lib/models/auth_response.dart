import 'package:json_annotation/json_annotation.dart';
import 'user.dart';

part 'auth_response.g.dart';

@JsonSerializable()
class AuthResponse {
  final bool success;
  final String message;
  final AuthData? data;

  const AuthResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);
}

@JsonSerializable()
class AuthData {
  final User user;
  @JsonKey(name: 'access_token')
  final String accessToken;
  @JsonKey(name: 'token_type')
  final String tokenType;
  final List<String> abilities;

  const AuthData({
    required this.user,
    required this.accessToken,
    required this.tokenType,
    required this.abilities,
  });

  factory AuthData.fromJson(Map<String, dynamic> json) =>
      _$AuthDataFromJson(json);
  Map<String, dynamic> toJson() => _$AuthDataToJson(this);
}

@JsonSerializable()
class UserInfoResponse {
  final bool success;
  final UserInfoData data;

  const UserInfoResponse({
    required this.success,
    required this.data,
  });

  factory UserInfoResponse.fromJson(Map<String, dynamic> json) =>
      _$UserInfoResponseFromJson(json);
  Map<String, dynamic> toJson() => _$UserInfoResponseToJson(this);
}

@JsonSerializable()
class UserInfoData {
  final User user;
  @JsonKey(name: 'token_abilities')
  final List<String> tokenAbilities;
  @JsonKey(name: 'token_name')
  final String tokenName;
  @JsonKey(name: 'token_created')
  final String tokenCreated;

  const UserInfoData({
    required this.user,
    required this.tokenAbilities,
    required this.tokenName,
    required this.tokenCreated,
  });

  factory UserInfoData.fromJson(Map<String, dynamic> json) =>
      _$UserInfoDataFromJson(json);
  Map<String, dynamic> toJson() => _$UserInfoDataToJson(this);
}