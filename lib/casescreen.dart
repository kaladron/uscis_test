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

// This Screen:

// Card at the top, displayed only if case number entered
// Card prompting for case number and friendly name with check box.  Hide if 5
// numbers entered

// Card at the top contains:
// Case Number
// Status not updated yet message if no status
// "Bad case number" if error
// Heading
// Last updated
// Drop box for detail
// X to delete case
// pencil to provide friendly name

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uscis_test/caselogic.dart';

class CaseScreen extends StatelessWidget {
  static const routeName = '/casescreen';

  @override
  Widget build(BuildContext context) => MultiProvider(providers: [
        ChangeNotifierProvider(
            create: (context) => CaseLogic(context), lazy: false),
      ], child: _CaseScreenImpl());
}

class _CaseScreenImpl extends StatelessWidget {
  @override
  Widget build(final BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('Case Status'),
        ),
        body: Column(
          children: [
            ...context
                .watch<CaseLogic>()
                .cases
                .keys
                .map((e) => Text(e))
                .toList(),
            Card(
              child: InkWell(
                onTap: () {
                  context.read<CaseLogic>().initiate();
                },
                child: ListTile(
                  leading: Icon(Icons.add),
                  title: Text('Add'),
                  subtitle: Text('Add USCIS Case Number'),
                ),
              ),
            ),
          ],
        ),
      );
}
