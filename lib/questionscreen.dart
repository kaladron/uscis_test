// Title bar with question number, sandwich, heart to save question
// If enabled, text of question
// Button to trigger listening response
// Bottom bar with Home, Prev, Next

import 'package:flutter/material.dart';
import 'package:uscis_test/questioncontext.dart';
import 'package:provider/provider.dart';

import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';

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

class _QuestionScreenImpl extends StatefulWidget {
  @override
  _QuestionScreenImplState createState() => _QuestionScreenImplState();
}

class _QuestionScreenImplState extends State<_QuestionScreenImpl> {
  final SpeechToText speech = SpeechToText();

  final Widget _answerMark = AnswerMark();

  String _resultText = '';

  bool _showAnswer = false;

  @override
  Widget build(BuildContext context) {
    return (Scaffold(
      appBar: AppBar(
        title: Text("Question"),
      ),
      body: Stack(children: [
        // TODO(jeffbailey): This is aligned poorly, too far down
        _answerMark,
        Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  MaterialButton(
                    onPressed: _prevQuestion,
                    child: Text('<'),
                    shape: CircleBorder(),
                    color: Colors.blue,
                  ),
                  Expanded(
                    child: Text(
                      '${context.watch<QuestionContext>().question.question}',
                    ),
                  ),
                  MaterialButton(
                    onPressed: _nextQuestion,
                    child: Text('>'),
                    shape: CircleBorder(),
                    color: Colors.blue,
                  ),
                ],
              ),
            ),
            Text('$_resultText'),
            MaterialButton(
              onPressed: startListening,
              child: Icon(Icons.mic_none_outlined, size: 24),
              shape: CircleBorder(),
              padding: EdgeInsets.all(16),
              color: Colors.red,
            ),
            RaisedButton(onPressed: _toggle, child: Text('Show Answer')),
            if (_showAnswer) ...[
              Text('${context.watch<QuestionContext>().question.answers[0]}'),
            ],
          ],
        ),
      ]),
    ));
  }

  void _resetQuestionState() {
    _showAnswer = false;
    _resultText = '';
  }

  void _prevQuestion() {
    _resetQuestionState();
    context.read<QuestionContext>().prevQuestion();
    setState(() {});
  }

  void _nextQuestion() {
    _resetQuestionState();
    context.read<QuestionContext>().nextQuestion();
    setState(() {});
  }

  void _toggle() {
    setState(() {
      _showAnswer = true;
    });
  }

  Future<void> startListening() async {
    // TODO(jeffbailey): All the error handling!
    var hasSpeech = await speech.initialize(debugLogging: false);

    speech.listen(
        onResult: resultListener,
        listenFor: Duration(seconds: 5),
        pauseFor: Duration(seconds: 5),
        partialResults: false,
        cancelOnError: true,
        listenMode: ListenMode.confirmation);
  }

  void resultListener(SpeechRecognitionResult result) {
    _resultText = result.recognizedWords;
    setState(() {});
  }
}

class AnswerMark extends StatefulWidget {
  const AnswerMark({
    Key key,
  }) : super(key: key);

  @override
  _AnswerMarkState createState() => _AnswerMarkState();
}

class _AnswerMarkState extends State<AnswerMark> {
  bool show = false;

  void showRight() {
    show = true;
    setState(() {});
  }

  void fadeOut() {
    show = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: show ? 1.0 : 0.0,
      onEnd: fadeOut,
      duration: Duration(milliseconds: 250),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Center(
            child: Text(
          '✓', //  ✓ ✗
          style: TextStyle(fontSize: 112, color: Colors.green),
        ))
      ]),
    );
  }
}
