// Copyright 2020 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

// Title bar with question number, sandwich, heart to save question
// If enabled, text of question
// Button to trigger listening response
// Bottom bar with Home, Prev, Next

import 'package:flutter/material.dart';
import 'package:uscis_test/learnlogic.dart';
import 'package:provider/provider.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:speech_to_text/speech_to_text.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:speech_to_text/speech_recognition_result.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_tts/flutter_tts.dart';
import 'package:uscis_test/questionchecker.dart';

class LearnScreen extends StatelessWidget {
  static const routeName = '/question';

  @override
  Widget build(BuildContext context) => MultiProvider(providers: [
        ChangeNotifierProvider(
            create: (context) => LearnLogic(context), lazy: false),
      ], child: _LearnScreenImpl());
}

class _LearnScreenImpl extends StatefulWidget {
  @override
  _LearnScreenImplState createState() => _LearnScreenImplState();
}

class _LearnScreenImplState extends State<_LearnScreenImpl> {
  final speech = SpeechToText();
  final flutterTts = FlutterTts();

  bool _show = false;
  bool _answerWasRight = false;

  Color _micButtonBackground = Colors.red;
  Color _micButtonForeground = Colors.white;

  String _resultText = '';

  bool _showAnswer = false;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text("Learn"),
        ),
        body: Stack(children: [
          rightWrong(),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${context.watch<LearnLogic>().question.question}',
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
                child: Icon(Icons.mic_none_outlined,
                    size: 24, color: _micButtonForeground),
                shape: CircleBorder(),
                padding: EdgeInsets.all(16),
                color: _micButtonBackground,
              ),
              RaisedButton(onPressed: _toggle, child: Text('Show Answer')),
              if (_showAnswer) ...[
                for (var i in context.watch<LearnLogic>().question.answers)
                  Text(i),
              ],
              RaisedButton(
                  onPressed: _speakQuestion, child: Text('Speak Answers')),
              Text('Progress'),
              LinearProgressIndicator(
                  value: context.watch<LearnLogic>().progress),
            ],
          ),
        ]),
      );

  // TODO(jeffbailey): This is aligned poorly, too far down
  Widget rightWrong() => AnimatedOpacity(
        opacity: _show ? 1.0 : 0.0,
        onEnd: _fadeOut,
        duration: Duration(milliseconds: 500),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Center(
              child: Text(
            _answerWasRight ? '✓' : '✗',
            style: TextStyle(
                fontSize: 112,
                color: _answerWasRight ? Colors.green : Colors.red),
          ))
        ]),
      );

  void _speakQuestion() async {
    await flutterTts.setLanguage("en-US");

    for (var i in context.read<LearnLogic>().question.answers) {
      // TODO(jeffbailey): Need to wait here for previous answers to get read before starting the next one.
      await flutterTts.speak(i);
    }
  }

  void _resetQuestionState() {
    _showAnswer = false;
    _resultText = '';
  }

  void _nextQuestion() {
    _resetQuestionState();
    context.read<LearnLogic>().nextQuestion();
  }

  void _toggle() {
    setState(() {
      _showAnswer = true;
    });
  }

  Future<void> startListening() async {
    // TODO(jeffbailey): All the error handling!
    await speech.initialize(debugLogging: false);

    setState(() {
      _micButtonBackground = Colors.white;
      _micButtonForeground = Colors.red;
    });

    await speech.listen(
        onResult: resultListener,
        listenFor: Duration(seconds: 5),
        pauseFor: Duration(seconds: 5),
        partialResults: false,
        cancelOnError: true,
        listenMode: ListenMode.confirmation);
  }

  void resultListener(SpeechRecognitionResult result) {
    setState(() {
      _micButtonBackground = Colors.red;
      _micButtonForeground = Colors.white;
    });

    _resultText = result.recognizedWords;
    setState(() {
      if (context.read<LearnLogic>().checkAnswer(_resultText) ==
          QuestionStatus.correct) {
        _showRight();
        _resetQuestionState();
      } else {
        _showWrong();
      }
    });
  }

  void _fadeOut() {
    setState(() {
      _show = false;
    });
  }

  void _showRight() {
    setState(() {
      _show = true;
      _answerWasRight = true;
    });
  }

  void _showWrong() {
    setState(() {
      _show = true;
      _answerWasRight = false;
    });
  }
}
