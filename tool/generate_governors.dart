// Copyright 2021 Google LLC
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

import 'package:args/args.dart';
import 'package:http/http.dart' as http;
import 'package:json_annotation/json_annotation.dart';

part 'generate_governors.g.dart';

@JsonSerializable()
class Governor {
  @JsonKey(name: 'first_name')
  String firstName;

  @JsonKey(name: 'last_name')
  String lastName;

  Governor({
    required this.firstName,
    required this.lastName,
  });

  factory Governor.fromJson(Map<String, dynamic> json) =>
      _$GovernorFromJson(json);

  Map<String, dynamic> toJson() => _$GovernorToJson(this);
}

// state_name
// first_name
// last_name

const sourceUrl =
    'https://raw.githubusercontent.com/OpenGovDataMirror/F_CivilServiceUSA_us-governors/master/us-governors/data/us-governors.json';

void main(List<String> args) async {
  var parser = ArgParser();
  parser.addOption('file');
  parser.addOption('url', defaultsTo: sourceUrl);

  // var results = parser.parse(args);

  // print(results.arguments);

  String contents;

  final network = true;

  if (network) {
    contents = await http.read(Uri.parse(sourceUrl));
  } else {
    final file = File('us-governors.json');
    contents = file.readAsStringSync();
  }

  final document = jsonDecode(contents);

  var states = <String, Governor>{};
  for (var stGov in document) {
    states[stGov['state_name']] =
        Governor(firstName: stGov['first_name'], lastName: stGov['last_name']);
  }

  // print(states);

  var json = jsonEncode(states);
  final outFile = File('../lib/governors.json');
  outFile.writeAsStringSync(json, flush: true);
}
