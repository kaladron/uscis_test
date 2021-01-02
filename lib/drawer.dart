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

// Mastered Progress Bar
// Checkbox/Slider for reading question out loud when asking
// Button to clear mastering progress
// About

import 'package:flutter/material.dart';
import 'package:flag/flag.dart';

Widget drawerMenu() {
  return Drawer(
    child: ListView(padding: EdgeInsets.zero, children: <Widget>[
      DrawerHeader(
        child: Flag('us'),
        decoration: BoxDecoration(
          color: Colors.blue,
        ),
      ),
      ListTile(title: Text('USCIS Exam')),
      RadioListTile(
        value: "2008",
        title: Text('2008'),
        onChanged: (String value) {},
        groupValue: "2008",
      ),
      RadioListTile(
        value: "2020",
        title: Text('2020'),
        onChanged: null,
        groupValue: "2008",
      ),
      SwitchListTile(
        title: const Text('Show only 65+ Questions'),
        value: false,
        onChanged: null,
      ),
      const Divider(
        color: Colors.black,
        height: 2,
        thickness: 1,
        indent: 0,
        endIndent: 0,
      ),
      ListTile(
        title: Text('About'),
        onTap: () {
          // Update the state of the app.
          // ...
        },
      ),
    ]),
  );
}
