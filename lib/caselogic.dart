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

// Look for an H1 and its sibling Paragraph.

import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart';

class CaseStatus {
  String? heading;
  String? details;
  DateTime lastUpdated;

  CaseStatus._(this.lastUpdated, [this.heading, this.details]);

  factory CaseStatus(
      [String? heading, String? details, DateTime? lastUpdated]) {
    return CaseStatus._(lastUpdated ?? DateTime.now(), heading, details);
  }
}

class CaseLogic extends ChangeNotifier {
  // ignore: unused_field
  final BuildContext _context;

  final Map<String, CaseStatus> cases = {};

  CaseLogic(this._context);

  Future initiate() async {
    var client = Client();

    for (var caseNum in cases.keys) {
      var response = await client.get(Uri.parse(
          'https://egov.uscis.gov/casestatus/mycasestatus.do?appReceiptNum=' +
              caseNum));

      var document = parse(response.body);
      var headingElement = document.querySelector('h1');
      var heading = headingElement?.text;
      var details = headingElement?.nextElementSibling?.text;
      cases[caseNum] = CaseStatus(heading, details);
    }
  }
}
