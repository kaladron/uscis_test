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
import 'package:shared_preferences/shared_preferences.dart';

class PrefsStorage extends ChangeNotifier {
  static const casesKey = 'cases';
  static const rightOnceKey = 'rightonce';
  static const rightTwiceKey = 'righttwice';
  static const masteredKey = 'mastered';
  static const workingSetKey = 'workingset';
  static const over65Key = 'over65';
  static const randomizedQuestionsKey = 'randomizedquestions';
  static const districtKey = 'district';
  static const regionKey = 'region';
  static const starredKey = 'starred';

  late SharedPreferences _prefs;

  late bool _over65Only;
  String? _region;
  String? _district;
  final _starredMap = SplayTreeMap<String, bool>();

  late Set<String>? _workingSet;
  late List<String>? _randomizedQuestions;
  late Set<String> _rightOnce;
  late Set<String> _rightTwice;
  late Set<String> _mastered;
  late List<String> _cases;

  bool get over65Only => _over65Only;
  set over65Only(final bool value) {
    _prefs.setBool(over65Key, value);
    _over65Only = value;
    notifyListeners();
  }

  String? get region => _region;
  set region(final String? value) {
    if (value == null) {
      _prefs.remove(regionKey);
    } else {
      _prefs.setString(regionKey, value);
    }
    _region = value;
    notifyListeners();
  }

  String? get district => _district;
  set district(final String? value) {
    if (value == null) {
      _prefs.remove(districtKey);
    } else {
      _prefs.setString(districtKey, value);
    }
    _district = value;
    notifyListeners();
  }

  Set<String>? get workingSet => _workingSet;
  set workingSet(final Set<String>? input) => _itToPrefs(input, workingSetKey);

  List<String>? get randomizedQuestions => _randomizedQuestions;
  set randomizedQuestions(final List<String>? input) =>
      _itToPrefs(input, randomizedQuestionsKey);

  Set<String> get rightOnce => _rightOnce;
  set rightOnce(final Set<String> input) => _itToPrefs(input, rightOnceKey);

  Set<String> get rightTwice => _rightTwice;
  set rightTwice(final Set<String> input) => _itToPrefs(input, rightTwiceKey);

  Set<String> get mastered => _mastered;
  set mastered(final Set<String> input) => _itToPrefs(input, masteredKey);

  List<String> get cases => _cases;
  set cases(final List<String> cases) {
    _cases = cases;
    _prefs.setStringList(casesKey, cases);
  }

  // Star Handling
  List<String> get starredList => _starredMap.keys.toList();

  bool isStarred(final String qnum) {
    return _starredMap.containsKey(qnum);
  }

  void toggleStar(final String qnum) {
    var state = !isStarred(qnum);

    if (state) {
      _starredMap[qnum] = true;
    } else {
      _starredMap.remove(qnum);
    }
    _prefs.setStringList(starredKey, _starredMap.keys.toList());
    notifyListeners();
  }

  Future<void> initState() async {
    _prefs = await SharedPreferences.getInstance();
    _over65Only = _prefs.getBool(over65Key) ?? false;

    _region = _prefs.getString(regionKey);
    _district = _prefs.getString(districtKey);

    final starredList = _prefs.getStringList(starredKey) ?? [];
    for (var i in starredList) {
      _starredMap[i] = true;
    }

    _workingSet = _prefs.getStringList(workingSetKey)?.toSet();
    _randomizedQuestions = _prefs.getStringList(randomizedQuestionsKey);
    _rightOnce = _prefs.getStringList(rightOnceKey)?.toSet() ?? {};
    _rightTwice = _prefs.getStringList(rightTwiceKey)?.toSet() ?? {};
    _mastered = _prefs.getStringList(masteredKey)?.toSet() ?? {};
    _cases = _prefs.getStringList(casesKey) ?? [];
  }

  void _itToPrefs(final Iterable<String>? input, final String key) {
    if (input == null) {
      _prefs.remove(key);
      return;
    }
    debugPrint('saving $key${input.map((el) => el).toList()}');
    _prefs.setStringList(key, input.map((el) => el).toList());
  }
}
