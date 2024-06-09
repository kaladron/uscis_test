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

// Title bar with app name, sandwich
// Buttons on the page
// First button Learning Mode
//   This one will go through and grind people through the app
// Second one is Testing Mode
//   This one will simulate a test.  Verbal questions, verbal answers.
//   10 Questions, have to get 6 rights.  Stops at 6 correct. (for 2008)
// Third one is link to saved questions
// Drop down with link to location (greys out other buttons until set)

import 'package:flutter/material.dart';
import 'package:uscis_test/casescreen.dart';
import 'package:uscis_test/drawer.dart';
import 'package:uscis_test/prefs.dart';
import 'package:uscis_test/question.dart';
import 'package:uscis_test/viewscreen.dart';
import 'package:provider/provider.dart';
import 'package:uscis_test/learnscreen.dart';

class MainScreen extends StatelessWidget {
  static const routeName = '/';

  const MainScreen({super.key});

  @override
  Widget build(final BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('US Citizenship Exam Prep'),
      ),
      drawer: const DrawerMenu(),
      body: Column(children: [
        Expanded(
          child: GridView.count(crossAxisCount: 2, children: [
            Card(
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(context, ViewScreen.routeName);
                },
                child: const ListTile(
                  leading: Icon(Icons.pageview),
                  title: Text('Review Questions'),
                  subtitle: Text('Review the exam questions.'),
                ),
              ),
            ),
            Card(
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(context, LearnScreen.routeName);
                },
                child: const ListTile(
                  leading: Icon(Icons.assignment),
                  title: Text('Practice Drills'),
                  subtitle:
                      Text('Improve your knowledge with practice drills.'),
                ),
              ),
            ),
            const Card(
              child: InkWell(
                child: ListTile(
                  leading: Icon(Icons.psychology),
                  title: Text('Full Test Simulation'),
                  subtitle: Text('Take a full practice test. (coming soon!)'),
                ),
              ),
            ),
            Card(
              child: InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, CaseScreen.routeName);
                  },
                  child: const ListTile(
                    leading: Icon(Icons.assignment_ind),
                    title: Text('USCIS Case Status'),
                    subtitle: Text('Check the status of your USCIS case.'),
                  )),
            ),
          ]),
        ),
        const Padding(
          padding: EdgeInsets.only(top: 16),
          child: Text('Choose your state or territory'),
        ),
        DropdownButton(
          value: context.watch<PrefsStorage>().region,
          onChanged: (String? newValue) {
            context.read<PrefsStorage>().region = newValue;
            context.read<PrefsStorage>().district =
                context.read<QuestionStorage>().districts[0];
          },
          items: context
              .read<QuestionStorage>()
              .states
              .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(e),
                  ))
              .toList(),
        ),
        const Padding(
          padding: EdgeInsets.only(top: 16),
          child: Text('Choose your congressional district'),
        ),
        DropdownButton(
          value: context.watch<PrefsStorage>().district,
          onChanged: (String? newValue) {
            context.read<PrefsStorage>().district = newValue;
          },
          items: context
              .read<QuestionStorage>()
              .districts
              .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(e),
                  ))
              .toList(),
        ),
      ]));
}
