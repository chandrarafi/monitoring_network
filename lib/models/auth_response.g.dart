// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthResponse _$AuthResponseFromJson(Map<String, dynamic> json) => AuthResponse(
  success: json['success'] as bool,
  message: json['message'] as String,
  data: json['data'] == null
      ? null
      : AuthData.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$AuthResponseToJson(AuthResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };

AuthData _$AuthDataFromJson(Map<String, dynamic> json) => AuthData(
  user: User.fromJson(json['user'] as Map<String, dynamic>),
  accessToken: json['access_token'] as String,
  tokenType: json['token_type'] as String,
  abilities: (json['abilities'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$AuthDataToJson(AuthData instance) => <String, dynamic>{
  'user': instance.user,
  'access_token': instance.accessToken,
  'token_type': instance.tokenType,
  'abilities': instance.abilities,
};

UserInfoResponse _$UserInfoResponseFromJson(Map<String, dynamic> json) =>
    UserInfoResponse(
      success: json['success'] as bool,
      data: UserInfoData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UserInfoResponseToJson(UserInfoResponse instance) =>
    <String, dynamic>{'success': instance.success, 'data': instance.data};

UserInfoData _$UserInfoDataFromJson(Map<String, dynamic> json) => UserInfoData(
  user: User.fromJson(json['user'] as Map<String, dynamic>),
  tokenAbilities: (json['token_abilities'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  tokenName: json['token_name'] as String,
  tokenCreated: json['token_created'] as String,
);

Map<String, dynamic> _$UserInfoDataToJson(UserInfoData instance) =>
    <String, dynamic>{
      'user': instance.user,
      'token_abilities': instance.tokenAbilities,
      'token_name': instance.tokenName,
      'token_created': instance.tokenCreated,
    };
