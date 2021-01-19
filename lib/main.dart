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

// @dart=2.9

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uscis_test/mainscreen.dart';
import 'package:uscis_test/prefs.dart';
import 'package:uscis_test/question.dart';
import 'package:uscis_test/splashscreen.dart';
import 'package:uscis_test/viewscreen.dart';
import 'package:uscis_test/testscreen.dart';

void main() {
  var prefs = PrefsStorage();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => prefs, lazy: false),
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
        MainScreen.routeName: (context) => MainScreen(),
        ViewScreen.routeName: (context) => ViewScreen(),
        TestScreen.routeName: (context) => TestScreen(),
      },
    ),
  ));
}
