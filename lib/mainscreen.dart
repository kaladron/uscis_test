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
import 'package:uscis_test/questionscreen.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  static const routeName = '/';
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final _states = [
    "Alabama",
    "Alaska",
    "Arizona",
    "Arkansas",
    "California",
    "Colorado",
    "Connecticut",
    "Delaware",
    "Florida",
    "Georgia",
    "Hawaii",
    "Idaho",
    "Illinois",
    "Indiana",
    "Iowa",
    "Kansas",
    "Kentucky",
    "Louisiana",
    "Maine",
    "Maryland",
    "Massachusetts",
    "Michigan",
    "Minnesota",
    "Mississippi",
    "Missouri",
    "Montana",
    "Nebraska",
    "Nevada",
    "New Hampshire",
    "New Jersey",
    "New Mexico",
    "New York",
    "North Carolina",
    "North Dakota",
    "Ohio",
    "Oklahoma",
    "Oregon",
    "Pennsylvania",
    "Rhode Island",
    "South Carolina",
    "South Dakota",
    "Tennessee",
    "Texas",
    "Utah",
    "Vermont",
    "Virginia",
    "Washington",
    "West Virginia",
    "Wisconsin",
    "Wyoming",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('US Citizenship Test'),
      ),
      drawer: DrawerMenu(),
      body: _body(),
    );
  }

  Widget _body() {
    return Column(
      children: [
        Card(
          child: InkWell(
            onTap: () {
              Navigator.pushNamed(context, QuestionScreen.routeName);
            },
            child: Column(
              children: <Widget>[
                const ListTile(
                  leading: Icon(Icons.pageview),
                  title: Text('View'),
                  subtitle: Text('View Questions'),
                ),
              ],
            ),
          ),
        ),
        Card(
          child: InkWell(
            onTap: () {},
            child: Column(
              children: <Widget>[
                const ListTile(
                  leading: Icon(Icons.assignment),
                  title: Text('Learn'),
                  subtitle: Text('Practice Citizenship Questions'),
                ),
              ],
            ),
          ),
        ),
        Card(
          child: InkWell(
            onTap: () {},
            child: Column(
              children: <Widget>[
                const ListTile(
                  leading: Icon(Icons.psychology),
                  title: Text('Test'),
                  subtitle: Text('Simulate a test'),
                ),
              ],
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
          items: _states.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ],
    );
  }
}
