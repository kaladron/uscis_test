// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'generate_senators.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Senator _$SenatorFromJson(Map<String, dynamic> json) {
  return Senator(
    firstName: json['firstName'] as String,
    lastName: json['lastName'] as String,
  );
}

Map<String, dynamic> _$SenatorToJson(Senator instance) => <String, dynamic>{
      'firstName': instance.firstName,
      'lastName': instance.lastName,
    };
