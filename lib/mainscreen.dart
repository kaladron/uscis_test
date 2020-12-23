// Title bar with app name, sandwich
// Buttons on the page
// First button Learning Mode
//   This one will go through and grind people through the app
// Second one is Testing Mode
//   This one will simulate a test.  Verbal questions, verbal answers.
//   10 Questions, have to get 6 rights.  Stops at 6 correct. (for 2008)
// Third one is link to saved questions
// Drop down with link to location (greys out other buttons until set)

import 'package:flutter/material.dart';
import 'package:uscis_test/drawer.dart';
import 'package:uscis_test/questionscreen.dart';

class MainScreen extends StatefulWidget {
  static const routeName = '/';
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('US Citizenship Test'),
      ),
      drawer: drawerMenu(),
      body: _body(),
    );
  }

  Widget _body() {
    return Column(
      children: [
        Card(
          child: InkWell(
            onTap: () {},
            child: Column(
              children: <Widget>[
                const ListTile(
                  leading: Icon(Icons.pageview),
                  title: Text('View'),
                  subtitle: Text('View Questions'),
                ),
              ],
            ),
          ),
        ),
        Card(
          child: InkWell(
            onTap: () {
              Navigator.pushNamed(context, QuestionScreen.routeName);
            },
            child: Column(
              children: <Widget>[
                const ListTile(
                  leading: Icon(Icons.assignment),
                  title: Text('Learn'),
                  subtitle: Text('Practice Citizenship Questions'),
                ),
              ],
            ),
          ),
        ),
        Card(
          child: InkWell(
            onTap: () {},
            child: Column(
              children: <Widget>[
                const ListTile(
                  leading: Icon(Icons.psychology),
                  title: Text('Test'),
                  subtitle: Text('Simulate a test'),
                ),
              ],
            ),
          ),
        ),
        DropdownButton(value: 'foo', onChanged: (value) {}, items: [
          DropdownMenuItem(
            child: Text('foo'),
            value: 'foo',
          ),
          DropdownMenuItem(
            child: Text('bar'),
            value: 'bar',
          ),
          DropdownMenuItem(
            child: Text('baz'),
            value: 'baz',
          ),
        ]),
        Expanded(child: Text('Choose your region')),
      ],
    );
  }
}
