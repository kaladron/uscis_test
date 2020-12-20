// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uscis_test/mainscreen.dart';
import 'package:uscis_test/questionscreen.dart';

void main() => runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => QuestionPicker()),
      ],
      child: MyApp(),
    ));

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
