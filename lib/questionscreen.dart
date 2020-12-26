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

  String resultText = '';

  bool _showAnswer = false;

  @override
  Widget build(BuildContext context) {
    return (Scaffold(
      appBar: AppBar(
        title: Text("Question"),
      ),
      body: Column(
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
          Text('$resultText'),
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
    ));
  }

  void _prevQuestion() {
    _showAnswer = false;
    context.read<QuestionContext>().prevQuestion();
  }

  void _nextQuestion() {
    _showAnswer = false;
    context.read<QuestionContext>().nextQuestion();
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
    resultText = result.recognizedWords;
    setState(() {});
  }
}
