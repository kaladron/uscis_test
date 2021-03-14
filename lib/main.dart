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
import 'package:provider/provider.dart';
import 'package:uscis_test/casescreen.dart';
import 'package:uscis_test/learnscreen.dart';
import 'package:uscis_test/mainscreen.dart';
import 'package:uscis_test/prefs.dart';
import 'package:uscis_test/question.dart';
import 'package:uscis_test/splashscreen.dart';
import 'package:uscis_test/viewscreen.dart';
import 'package:uscis_test/testscreen.dart';

void main() {
  final prefs = PrefsStorage();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: prefs),
      ChangeNotifierProvider(
          create: (_) => QuestionStorage(prefs), lazy: false),
    ],
    child: MaterialApp(
      title: 'USCIS Citizenship Test',
      initialRoute: SplashScreen.routeName,
      theme: ThemeData(),
      darkTheme: ThemeData.dark(),
      routes: {
        SplashScreen.routeName: (context) => SplashScreen(),
        LearnScreen.routeName: (context) => LearnScreen(),
        MainScreen.routeName: (context) => MainScreen(),
        ViewScreen.routeName: (context) => ViewScreen(),
        TestScreen.routeName: (context) => TestScreen(),
        CaseScreen.routeName: (context) => CaseScreen(),
      },
    ),
  ));
}
