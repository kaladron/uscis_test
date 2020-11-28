// Mastered Progress Bar
// 2008 or 2020 exam checkbox
// Checkbox/Slider for showing text when asking question
// Checkbox/Slider for reading question out loud when asking
// Checkbox/Slide to only show question for 65+
// Button to clear mastering progress
// About

import 'package:flutter/material.dart';

Widget drawerMenu() {
  return Drawer(
    child: ListView(padding: EdgeInsets.zero, children: <Widget>[
      DrawerHeader(
        child: Text('Drawer Header'),
        decoration: BoxDecoration(
          color: Colors.blue,
        ),
      ),
      ListTile(
        title: Text('Item 1'),
        onTap: () {
          // Update the state of the app.
          // ...
        },
      ),
      ListTile(
        title: Text('Item 2'),
        onTap: () {
          // Update the state of the app.
          // ...
        },
      ),
      const Divider(
        color: Colors.black,
        height: 2,
        thickness: 1,
        indent: 0,
        endIndent: 0,
      ),
      ListTile(
        title: Text('About'),
        onTap: () {
          // Update the state of the app.
          // ...
        },
      ),
    ]),
  );
}
