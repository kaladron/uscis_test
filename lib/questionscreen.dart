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
      body: QuestionWidget(
        '${context.watch<QuestionContext>().question.question}',
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.skip_previous),
            label: 'Previous',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.skip_next),
            label: 'Next',
          ),
        ],
        onTap: context.watch<QuestionContext>().setQuestion,
      ),
    ));
  }
}

class QuestionWidget extends StatefulWidget {
  final String questionText;
  const QuestionWidget(this.questionText);

  @override
  _QuestionWidgetState createState() => _QuestionWidgetState();
}

class _QuestionWidgetState extends State<QuestionWidget> {
  @override
  Widget build(BuildContext context) {
    return Text(widget.questionText);
  }
}
