// Copyright 2020 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:convert';
import 'dart:io';

// ignore: import_of_legacy_library_into_null_safe
import 'package:json_annotation/json_annotation.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import 'package:args/args.dart';

part 'generate_members.g.dart';

@JsonSerializable()
class Member {
  String firstName;
  String lastName;
  String district;

  Member(
      {required this.firstName,
      required this.lastName,
      required this.district});

  factory Member.fromJson(Map<String, dynamic> json) => _$MemberFromJson(json);

  Map<String, dynamic> toJson() => _$MemberToJson(this);
}

void main(List<String> args) async {
  var parser = ArgParser();
  parser.addOption('file');
  parser.addOption('url',
      defaultsTo: 'http://clerk.house.gov/xml/lists/MemberData.xml');

  // var results = parser.parse(args);

  // print(results.arguments);

  String contents;

  final network = true;

  if (network) {
    contents = await http
        .read(Uri.parse('http://clerk.house.gov/xml/lists/MemberData.xml'));
  } else {
    final file = File('MemberData.xml');
    contents = file.readAsStringSync();
  }

  final document = XmlDocument.parse(contents);

  var states = <String, List<Member>>{};

  for (var member in document.findAllElements('member')) {
    var memberInfoNode = member.findElements('member-info').first;
    var firstName = memberInfoNode.findElements('firstname').first.innerText;
    var lastName = memberInfoNode.findElements('lastname').first.innerText;
    var state =
        memberInfoNode.findAllElements('state-fullname').first.innerText;
    var district = memberInfoNode.findElements('district').first.innerText;

    var members = states[state];

    if (members == null) {
      members = [];
      states[state] = members;
    }

    members.add(
        Member(firstName: firstName, lastName: lastName, district: district));
  }

  var json = jsonEncode(states);
  final outFile = File('../lib/representatives.json');
  outFile.writeAsStringSync(json, flush: true);
}
