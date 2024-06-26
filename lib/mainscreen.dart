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

import 'package:flutter/material.dart';
import 'package:uscis_test/casescreen.dart';
import 'package:uscis_test/drawer.dart';
import 'package:uscis_test/prefs.dart';
import 'package:uscis_test/viewscreen.dart';
import 'package:provider/provider.dart';
import 'package:uscis_test/learnscreen.dart';

String locationText(String? region, String? district) {
  if (region == null) {
    return "Location Not Selected";
  }

  if (district == null) {
    return region;
  }

  return '$region, $district';
}

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
      ]),
      bottomNavigationBar: BottomAppBar(
        child: ListTile(
          leading: const Icon(Icons.my_location),
          title: Text(locationText(context.watch<PrefsStorage>().region,
              context.read<PrefsStorage>().district)),
        ),
      ));
}
