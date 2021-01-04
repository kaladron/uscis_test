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
import 'package:uscis_test/questionlistscreen.dart';

void main() {
  var prefs = PrefsStorage();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => prefs, lazy: false),
      Provider(create: (_) => QuestionStorage(prefs), lazy: false),
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var materialApp = MaterialApp(
        title: 'USCIS Citizenship Test',
        initialRoute: SplashScreen.routeName,
        theme: ThemeData(),
        darkTheme: ThemeData.dark(),
        routes: {
          SplashScreen.routeName: (context) => SplashScreen(),
          MainScreen.routeName: (context) => MainScreen(),
          QuestionListScreen.routeName: (context) => QuestionListScreen(),
        });
    return materialApp;
  }
}

/// Handle synchronous initialization here.  It's called SplashScreen
/// because if it suddenly starts to take a long time, we would add it here.
/// But that's pretty unlikely in this case, so we don't bother.
class SplashScreen extends StatefulWidget {
  static const routeName = "/splash";

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }

  @override
  initState() {
    super.initState();
    onStart();
  }

  void onStart() async {
    await context.read<PrefsStorage>().initState();
    await context.read<QuestionStorage>().initState();
    Navigator.pushNamedAndRemoveUntil(
        context, MainScreen.routeName, (Route<dynamic> route) => false);
  }
}
