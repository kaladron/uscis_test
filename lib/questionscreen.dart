// Title bar with question number, sandwich, heart to save question
// If enabled, text of question
// Button to trigger listening response
// Bottom bar with Home, Prev, Next

import 'package:flutter/material.dart';
import 'package:uscis_test/questioncontext.dart';
import 'package:provider/provider.dart';

class QuestionScreen extends StatelessWidget {
  static const routeName = '/question';
  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      ChangeNotifierProvider(
          create: (context) => QuestionContext(context), lazy: false),
    ], child: _QuestionScreenImpl());
  }
}

class _QuestionScreenImpl extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return (Scaffold(
      appBar: AppBar(
        title: Text("Question"),
      ),
      body: Column(
        children: [
          Text(
            '${context.watch<QuestionContext>().question.question}',
          ),
          RaisedButton(
            onPressed: context.watch<QuestionContext>().prevQuestion,
            child: Text('Previous'),
          ),
          RaisedButton(
            onPressed: context.watch<QuestionContext>().nextQuestion,
            child: Text('Next'),
          )
        ],
      ),
    ));
  }
}
