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

import 'package:json_annotation/json_annotation.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import 'package:args/args.dart';

part 'generate_senators.g.dart';

@JsonSerializable()
class Senator {
  @JsonKey(name: 'first_name')
  String firstName;

  @JsonKey(name: 'last_name')
  String lastName;

  Senator({
    required this.firstName,
    required this.lastName,
  });

  factory Senator.fromJson(Map<String, dynamic> json) =>
      _$SenatorFromJson(json);

  Map<String, dynamic> toJson() => _$SenatorToJson(this);
}

var statesList = <String, String>{
  'AL': 'Alabama',
  'AK': 'Alaska',
  'AZ': 'Arizona',
  'AR': 'Arkansas',
  'CA': 'California',
  'CO': 'Colorado',
  'CT': 'Connecticut',
  'DE': 'Delaware',
  'FL': 'Florida',
  'GA': 'Georgia',
  'HI': 'Hawaii',
  'ID': 'Idaho',
  'IL': 'Illinois',
  'IN': 'Indiana',
  'IA': 'Iowa',
  'KS': 'Kansas',
  'KY': 'Kentucky',
  'LA': 'Louisiana',
  'ME': 'Maine',
  'MD': 'Maryland',
  'MA': 'Massachusetts',
  'MI': 'Michigan',
  'MN': 'Minnesota',
  'MS': 'Mississippi',
  'MO': 'Missouri',
  'MT': 'Montana',
  'NE': 'Nebraska',
  'NV': 'Nevada',
  'NH': 'New Hampshire',
  'NJ': 'New Jersey',
  'NM': 'New Mexico',
  'NY': 'New York',
  'NC': 'North Carolina',
  'ND': 'North Dakota',
  'OH': 'Ohio',
  'OK': 'Oklahoma',
  'OR': 'Oregon',
  'PA': 'Pennsylvania',
  'RI': 'Rhode Island',
  'SC': 'South Carolina',
  'SD': 'South Dakota',
  'TN': 'Tennessee',
  'TX': 'Texas',
  'UT': 'Utah',
  'VT': 'Vermont',
  'VA': 'Virginia',
  'WA': 'Washington',
  'WV': 'West Virginia',
  'WI': 'Wisconsin',
  'WY': 'Wyoming',
};

void main(List<String> args) async {
  var parser = ArgParser();
  parser.addOption('file');
  parser.addOption('url',
      defaultsTo:
          'http://www.senate.gov/general/contact_information/senators_cfm.xml');

  // var results = parser.parse(args);

  // print(results.arguments);

  String contents;

  final network = true;

  if (network) {
    contents = await http.read(Uri.parse(
        'http://www.senate.gov/general/contact_information/senators_cfm.xml'));
  } else {
    final file = File('senators_cfm.xml');
    contents = file.readAsStringSync();
  }

  final document = XmlDocument.parse(contents);

  var states = <String, List<Senator>>{};

  for (var member in document.findAllElements('member')) {
    var firstName = member.findElements('first_name').first.innerText;
    var lastName = member.findElements('last_name').first.innerText;
    var state =
        statesList[member.findAllElements('state').first.innerText] ?? 'ERROR';

    var members = states[state];

    if (members == null) {
      members = [];
      states[state] = members;
    }

    members.add(Senator(firstName: firstName, lastName: lastName));
  }

  var json = jsonEncode(states);
  final outFile = File('../lib/senators.json');
  outFile.writeAsStringSync(json, flush: true);
}
