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
import 'package:provider/provider.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart';
import 'package:uscis_test/prefs.dart';

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
  final PrefsStorage _prefs;

  final Map<String, CaseStatus> cases = {};

  void addCase(String caseNum) {
    cases[caseNum] = CaseStatus();
    _prefs.cases = cases.keys.toList();
  }

  CaseLogic(final BuildContext context)
      : _prefs = context.read<PrefsStorage>() {
    for (var caseNum in _prefs.cases) {
      cases[caseNum] = CaseStatus();
    }
    notifyListeners();
  }

  Future initiate() async {
    var client = Client();

    for (var caseNum in cases.keys) {
      var response = await client.get(Uri.parse(
          'https://egov.uscis.gov/casestatus/mycasestatus.do?appReceiptNum=$caseNum'));

      var document = parse(response.body);
      var headingElement = document.querySelector('h1');
      if (headingElement == null) {
        // TODO(jeffbailey): Signal error
        return;
      }
      var heading = headingElement.text;
      var sibling = headingElement.nextElementSibling;
      if (sibling == null) {
        // TODO(jeffbailey): Signal error
        return;
      }
      var details = sibling.text;
      cases[caseNum] = CaseStatus(heading, details);
      notifyListeners();
    }
  }
}
