// GENERATED CODE - DO NOT MODIFY BY HAND
// @dart=2.9

part of 'generate_members.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Member _$MemberFromJson(Map<String, dynamic> json) {
  return Member(
    firstName: json['firstName'] as String,
    lastName: json['lastName'] as String,
    district: json['district'] as String,
  );
}

Map<String, dynamic> _$MemberToJson(Member instance) => <String, dynamic>{
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'district': instance.district,
    };
