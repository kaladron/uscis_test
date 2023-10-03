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

/// Handle synchronous initialization here.  It's called SplashScreen
/// because if it suddenly starts to take a long time, we would add it here.
/// But that's pretty unlikely in this case, so we don't bother.
class SplashScreen extends StatefulWidget {
  static const routeName = '/splash';

  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(final BuildContext context) => Container();

  @override
  void initState() {
    super.initState();
    onStart();
  }

  void onStart() async {
    await context.read<PrefsStorage>().initState();
    context.read<QuestionStorage>().initState();
    await Navigator.pushNamedAndRemoveUntil(
        context, MainScreen.routeName, (Route<dynamic> route) => false);
  }
}
