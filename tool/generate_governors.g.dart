// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'generate_governors.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Governor _$GovernorFromJson(Map<String, dynamic> json) {
  return Governor(
    firstName: json['first_name'] as String,
    lastName: json['last_name'] as String,
  );
}

Map<String, dynamic> _$GovernorToJson(Governor instance) => <String, dynamic>{
      'first_name': instance.firstName,
      'last_name': instance.lastName,
    };
