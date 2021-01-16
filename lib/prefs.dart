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
  SharedPreferences _prefs;

  bool _over65Only;
  String _region;
  var _starredMap = SplayTreeMap<String, bool>();

  get over65Only => _over65Only;
  // Dart can't detect the type for some reason
  List<String> get starredList => _starredMap.keys.toList();

  set over65Only(bool value) {
    _prefs.setBool('over65', value);
    _over65Only = value;
    notifyListeners();
  }

  get region => _region;

  set region(String value) {
    _prefs.setString('region', value);
    print(value);
    _region = value;
    notifyListeners();
  }

  bool isStarred(int qnum) {
    return _starredMap.containsKey(qnum.toString());
  }

  void toggle(int qnum) {
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
    _over65Only = _prefs.getBool('over65') ?? false;
    _region = _prefs.getString('region') ?? 'California';
    var starredList = _prefs.getStringList('starred') ?? [];
    for (var i in starredList) {
      _starredMap[i] = true;
    }
  }
}
