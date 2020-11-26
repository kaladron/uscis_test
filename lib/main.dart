// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:uscis_test/mainscreen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var materialApp = MaterialApp(
      title: 'USCIS Citizenship Test',
      home: MainScreen(),
      theme: ThemeData(),
      darkTheme: ThemeData.dark(),
    );
    return materialApp;
  }
}
