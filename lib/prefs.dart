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

import 'dart:collection';

import 'package:flutter/foundation.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uscis_test/states.dart';

class PrefsStorage extends ChangeNotifier {
  late SharedPreferences _prefs;

  late bool _over65Only;
  String? _region;
  var _starredMap = SplayTreeMap<String, bool>();

  bool get over65Only => _over65Only;

  List<String> get starredList => _starredMap.keys.toList();

  set over65Only(final bool value) {
    _prefs.setBool('over65', value);
    _over65Only = value;
    notifyListeners();
  }

  String? get region => _region;

  set region(final String? value) {
    _prefs.setString('region', value ?? States.defaultState);
    _region = value;
    notifyListeners();
  }

  bool isStarred(final int qnum) {
    return _starredMap.containsKey(qnum.toString());
  }

  List<int>? get randomizedQuestions {
    return null;
  }

  List<int>? get workingSet {
    return null;
  }

  Set<int> get rightOnce {
    return {};
  }

  Set<int> get rightTwice {
    return {};
  }

  Set<int> get mastered {
    return {};
  }

  // clearAllLearning
  // setLearningWorkingSet
  // getLearningWorkingSet
  // setGotRightOnce
  // getGotRightOnce
  // setGotRightTwice
  // getGotRightTwice
  // setMastered
  // getMastered

  void toggle(final int qnum) {
    var state = !isStarred(qnum);

    if (state) {
      _starredMap[qnum.toString()] = true;
    } else {
      _starredMap.remove(qnum.toString());
    }
    _prefs.setStringList('starred', _starredMap.keys.toList());
    notifyListeners();
  }

  Future<void> initState() async {
    _prefs = await SharedPreferences.getInstance();
    _over65Only =
        _prefs.containsKey('over65') ? _prefs.getBool('over65') : false;
    _region = _prefs.containsKey('region')
        ? _prefs.getString('region')
        : States.defaultState;
    final starredList =
        _prefs.containsKey('starred') ? _prefs.getStringList('starred') : [];
    for (var i in starredList) {
      _starredMap[i] = true;
    }
  }
}
