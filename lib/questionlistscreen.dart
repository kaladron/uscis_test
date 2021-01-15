import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uscis_test/question.dart';

class QuestionListScreen extends StatelessWidget {
  static const routeName = "/questionlistscreen";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("View"),
      ),
      body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text('Starred',
            style: Theme.of(context).textTheme.headline4,
            textAlign: TextAlign.left),
        Text('Not implemented yet'),
        Text('Questions', style: Theme.of(context).textTheme.headline4),
        Expanded(
          child: ListView.builder(
            itemCount: context.watch<QuestionStorage>().questions.length,
            itemBuilder: (context, index) {
              return QuestionListItem(index);
            },
          ),
        ),
      ]),
    );
  }
}

class QuestionListItem extends StatefulWidget {
  final int _index;

  const QuestionListItem(this._index);

  @override
  _QuestionListItemState createState() => _QuestionListItemState();
}

class _QuestionListItemState extends State<QuestionListItem> {
  bool _showAnswer = false;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.question_answer),
      trailing: GestureDetector(
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
      ),
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
}
