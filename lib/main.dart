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
import 'package:uscis_test/mainscreen.dart';
import 'package:uscis_test/prefs.dart';
import 'package:uscis_test/question.dart';
import 'package:uscis_test/questionscreen.dart';

void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => PrefsStorage(), lazy: false),
      Provider(create: (_) => QuestionStorage(), lazy: false),
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var materialApp = MaterialApp(
        title: 'USCIS Citizenship Test',
        initialRoute: MainScreen.routeName,
        theme: ThemeData(),
        darkTheme: ThemeData.dark(),
        routes: {
          MainScreen.routeName: (context) => MainScreen(),
          QuestionScreen.routeName: (context) => QuestionScreen(),
        });
    return materialApp;
  }
}
