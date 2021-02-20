import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uscis_test/question.dart';

class ViewScreen extends StatelessWidget {
  static const routeName = '/questionlistscreen';

  // TODO(jeffbailey): Write a UI test that toggles the first and last star in
  // the list.
  @override
  Widget build(final BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('View'),
        ),
        body: ListView(children: [
          if (context.watch<QuestionStorage>().starredQuestions.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(left: 8, top: 8),
              child: Text('Starred',
                  style: Theme.of(context).textTheme.headline5,
                  textAlign: TextAlign.left),
            ),
          ...context
              .watch<QuestionStorage>()
              .starredQuestions
              .map((e) =>
                  QuestionListItem(e.number, ValueKey('starred ${e.number}')))
              .toList(),
          Padding(
            padding: EdgeInsets.only(left: 8, top: 8),
            child:
                Text('Questions', style: Theme.of(context).textTheme.headline5),
          ),
          ...context
              .watch<QuestionStorage>()
              .questions
              .keys
              .toList()
              .map((e) => QuestionListItem(e, ValueKey('questions ${e}')))
              .toList(),
        ]),
      );
}

class QuestionListItem extends StatelessWidget {
  final String _qnum;

  const QuestionListItem(this._qnum, Key key) : super(key: key);

  Widget _star(final BuildContext context) => GestureDetector(
        onTap: () {
          context
              .read<QuestionStorage>()
              .toggle(context.read<QuestionStorage>().questions[_qnum]!.number);
        },
        child: context.watch<QuestionStorage>().isStarred(
                context.watch<QuestionStorage>().questions[_qnum]!.number)
            ? Icon(Icons.star)
            : Icon(Icons.star_outline),
      );

  @override
  Widget build(final BuildContext context) => ExpansionTile(
        leading: _star(context),
        title:
            Text(context.watch<QuestionStorage>().questions[_qnum]!.question),
        expandedAlignment: Alignment.centerLeft,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...context.watch<QuestionStorage>().questions[_qnum]!.answers.map(
                  (String value) => Padding(
                      padding: EdgeInsets.only(left: 32, bottom: 12, right: 8),
                      child: Text('• ${value}')))
            ],
          ),
        ],
      );
}
