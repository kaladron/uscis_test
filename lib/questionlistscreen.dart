import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uscis_test/question.dart';
import 'package:uscis_test/questionscreen.dart';

class QuestionListScreen extends StatelessWidget {
  static const routeName = "/questionlistscreen";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Questions"),
      ),
      body: ListView.builder(
        itemCount: context.watch<QuestionStorage>().questions.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Icon(Icons.question_answer),
            title: Text(
                context.watch<QuestionStorage>().questions[index].question),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => QuestionScreen(index)));
            },
          );
        },
      ),
    );
  }
}
