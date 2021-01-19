import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uscis_test/question.dart';

class ViewScreen extends StatelessWidget {
  static const routeName = "/questionlistscreen";

  // TODO(jeffbailey): Write a UI test that toggles the first and last star in
  // the list.
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text("View"),
        ),
        body: ListView(children: [
          if (context.watch<QuestionStorage>().starredQuestions.isNotEmpty)
            Text('Starred',
                style: Theme.of(context).textTheme.headline4,
                textAlign: TextAlign.left),
          ...context
              .watch<QuestionStorage>()
              .starredQuestions
              .map((e) => QuestionListItem(e.number - 1))
              .toList(),
          Text('Questions', style: Theme.of(context).textTheme.headline4),
          ...context
              .watch<QuestionStorage>()
              .questions
              .map((e) => QuestionListItem(e.number - 1))
              .toList(),
        ]),
      );
}

class QuestionListItem extends StatefulWidget {
  final int _index;

  const QuestionListItem(this._index);

  @override
  _QuestionListItemState createState() => _QuestionListItemState();
}

class _QuestionListItemState extends State<QuestionListItem> {
  bool _showAnswer = false;

  // Pulled this out because reading nested onTap was confusing.
  Widget _star() => GestureDetector(
        onTap: () {
          setState(() {
            context.read<QuestionStorage>().toggle(context
                .read<QuestionStorage>()
                .questions[widget._index]
                .number);
          });
        },
        child: context.watch<QuestionStorage>().isStarred(context
                .watch<QuestionStorage>()
                .questions[widget._index]
                .number)
            ? Icon(Icons.star)
            : Icon(Icons.star_outline),
      );

  @override
  Widget build(BuildContext context) => ListTile(
        leading: Icon(Icons.question_answer),
        trailing: _star(),
        title: Text(
            context.watch<QuestionStorage>().questions[widget._index].question),
        subtitle: _showAnswer
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...context
                      .watch<QuestionStorage>()
                      .questions[widget._index]
                      .answers
                      .map<Text>((String value) {
                    return Text("• " + value);
                  })
                ],
              )
            : null,
        onTap: () {
          setState(() {
            // TODO(jeffbailey): Animate this transition
            _showAnswer = !_showAnswer;
          });
        },
      );
}
