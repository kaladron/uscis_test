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
import 'package:uscis_test/drawer.dart';
import 'package:uscis_test/prefs.dart';
import 'package:uscis_test/questionlistscreen.dart';
import 'package:provider/provider.dart';
import 'package:uscis_test/questionscreen.dart';
import 'package:uscis_test/states.dart';
import 'package:uscis_test/testscreen.dart';

class MainScreen extends StatelessWidget {
  static const routeName = '/';

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('US Citizenship Test'),
        ),
        drawer: DrawerMenu(),
        body: Column(
          children: [
            Card(
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(context, QuestionListScreen.routeName);
                },
                child: ListTile(
                  leading: Icon(Icons.pageview),
                  title: Text('View'),
                  subtitle: Text('View Questions'),
                ),
              ),
            ),
            Card(
              child: InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => QuestionScreen(0)));
                },
                child: ListTile(
                  leading: Icon(Icons.assignment),
                  title: Text('Learn'),
                  subtitle: Text('Practice Citizenship Questions'),
                ),
              ),
            ),
            Card(
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(context, TestScreen.routeName);
                },
                child: ListTile(
                  leading: Icon(Icons.psychology),
                  title: Text('Test'),
                  subtitle: Text('Simulate a test'),
                ),
              ),
            ),
            Padding(
              child: Text('Choose your region'),
              padding: EdgeInsets.only(top: 16),
            ),
            DropdownButton(
              value: context.watch<PrefsStorage>().region,
              onChanged: (newValue) {
                context.read<PrefsStorage>().region = newValue;
              },
              items: States.states
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(e),
                      ))
                  .toList(),
            ),
          ],
        ),
      );
}
