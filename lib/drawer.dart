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
import 'package:provider/provider.dart';
import 'package:uscis_test/prefs.dart';
import 'package:flutter_html/flutter_html.dart';

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({super.key});

  @override
  Widget build(final BuildContext context) => Drawer(
        child: ListView(padding: EdgeInsets.zero, children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Flag.fromString('us'),
          ),
          SwitchListTile(
            title: const Text('Show only 65+ Questions'),
            value: context.watch<PrefsStorage>().over65Only,
            onChanged: (newValue) {
              context.read<PrefsStorage>().over65Only = newValue;
            },
          ),
          const Divider(
            height: 2,
            thickness: 1,
            indent: 0,
            endIndent: 0,
          ),
          AboutListTile(
            applicationName: 'US Citizenship Test',
            aboutBoxChildren: [
              Html(
                data:
                    'Icons made by <a href="https://www.flaticon.com/authors/freepik" title="Freepik">Freepik</a> from <a href="https://www.flaticon.com/" title="Flaticon">www.flaticon.com</a>',
              )
            ],
          ),
        ]),
      );
}
