// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'generate_members.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Member _$MemberFromJson(Map<String, dynamic> json) => Member(
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      district: json['district'] as String,
    );

Map<String, dynamic> _$MemberToJson(Member instance) => <String, dynamic>{
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'district': instance.district,
    };
