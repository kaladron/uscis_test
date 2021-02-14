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

const Widget _wrongMark = Text(
  '✗',
  style: TextStyle(fontSize: 112, color: Colors.red),
);

const _rightOnceMark = Text(
  '✓',
  style: TextStyle(fontSize: 112, color: Colors.green),
);

const _cancelledRightMark = Text(
  '✓',
  style: TextStyle(fontSize: 112, color: Colors.blueGrey),
);

const _rightTwiceMark = Text(
  '✓ ✓',
  style: TextStyle(fontSize: 112, color: Colors.green),
);

const _rightThriceMark = Text(
  '✓ ✓ ✓',
  style: TextStyle(fontSize: 112, color: Colors.green),
);

class _LearnScreenImplState extends State<_LearnScreenImpl> {
  final speech = SpeechToText();
  final flutterTts = FlutterTts();

  var _showAnswerMark = false;
  var _answerMark = _wrongMark;

  Color _micButtonBackground = Colors.red;
  Color _micButtonForeground = Colors.white;

  var _resultText = '';

  var _answerVisible = false;

  @override
  Widget build(final BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text("Learn"),
        ),
        body: Stack(children: [
          rightWrong(),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                child: Text(
                  '${context.watch<LearnLogic>().question.question}',
                  style: Theme.of(context).textTheme.headline6,
                ),
              ),
              Column(children: [
                MaterialButton(
                  onPressed: startListening,
                  child: Icon(Icons.mic_none_outlined,
                      size: 24, color: _micButtonForeground),
                  shape: CircleBorder(),
                  padding: EdgeInsets.all(16),
                  color: _micButtonBackground,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('Tap mic to answer'),
                ),
              ]),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Divider(
                  height: 2,
                  thickness: 1,
                  indent: 5,
                  endIndent: 5,
                ),
              ),
              if (!_answerVisible)
                ElevatedButton(
                    onPressed: _showAnswer, child: Text('Show Answer')),
              if (_answerVisible) ...[
                ElevatedButton(
                  onPressed: _nextQuestion,
                  child: Text('Next Question'),
                ),
                incorrectAnswer(),
              ],
              Spacer(),
              ProgressCard(),
            ],
          ),
        ]),
      );

  Widget incorrectAnswer() => Padding(
        padding: EdgeInsets.all(12),
        // TODO(jeffbailey): This doesn't work
        child: SingleChildScrollView(
          child: Row(children: [
            Flexible(
              fit: FlexFit.tight,
              child: Row(children: [
                Flexible(
                  fit: FlexFit.tight,
                  flex: 2,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_resultText != '') Text('You said: ${_resultText}'),
                        for (var i
                            in context.watch<LearnLogic>().question.answers)
                          Text("• " + i),
                      ]),
                ),
                Flexible(
                  flex: 1,
                  child: Padding(
                    padding: EdgeInsets.all(4),
                    child: ElevatedButton(
                        onPressed: _speakAnswers,
                        child:
                            Icon(Icons.play_circle_filled_rounded, size: 32)),
                  ),
                ),
              ]),
            ),
          ]),
        ),
      );

  Widget rightWrong() => AnimatedOpacity(
        opacity: _showAnswerMark ? 1.0 : 0.0,
        onEnd: _fadeOut,
        duration: Duration(milliseconds: 500),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Center(child: _answerMark)]),
      );

  void _speakAnswers() async {
    await flutterTts.setLanguage("en-US");

    var spokenAnswers = context.read<LearnLogic>().question.answers.join(".  ");
    await flutterTts.speak(spokenAnswers);
  }

  void _resetQuestionState() {
    _answerVisible = false;
    _resultText = '';
  }

  void _nextQuestion() {
    _resetQuestionState();
    context.read<LearnLogic>().nextQuestion();
  }

  void _showAnswer() {
    context.read<LearnLogic>().cancelQuestion();
    setState(() {
      _answerVisible = true;
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

  void resultListener(final SpeechRecognitionResult result) {
    setState(() {
      _micButtonBackground = Colors.red;
      _micButtonForeground = Colors.white;
    });

    _resultText = result.recognizedWords;
    setState(() {
      switch (context.read<LearnLogic>().checkAnswer(_resultText)) {
        case QuestionStatus.moreNeeded:
        case QuestionStatus.correctOnce:
        case QuestionStatus.duplicate:
          _showResult(_rightOnceMark);
          _nextQuestion();
          break;

        case QuestionStatus.correctTwice:
          _showResult(_rightTwiceMark);
          _nextQuestion();
          break;

        case QuestionStatus.correctThrice:
          _showResult(_rightThriceMark);
          _nextQuestion();
          break;

        case QuestionStatus.cancelled:
          _showResult(_cancelledRightMark);
          _nextQuestion();
          break;

        case QuestionStatus.incorrect:
          _answerVisible = true;
          _showResult(_wrongMark);
          break;
      }
    });
  }

  void _fadeOut() {
    setState(() {
      _showAnswerMark = false;
    });
  }

  void _showResult(final Widget newMark) {
    _showAnswerMark = true;
    _answerMark = newMark;
  }
}

class ProgressCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.all(8),
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Flexible(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: Text('Progress'),
                      ),
                      Row(children: [
                        Flexible(
                            child: LinearProgressIndicator(
                                value: context.watch<LearnLogic>().progress)),
                      ]),
                    ]),
              ),
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => QuestionInfoDialog(),
                  );
                },
                child: Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: Icon(Icons.info, size: 32),
                ),
              ),
            ]),
          ),
        ),
      );
}

// TODO(jeffbailey): Fill this in.  Maybe also put it in the drawer.
class QuestionInfoDialog extends StatelessWidget {
  @override
  Widget build(final BuildContext context) => AlertDialog(
        content: SingleChildScrollView(
          child: ListBody(children: [
            Text('Currently Testing',
                style: Theme.of(context).textTheme.headline6),
            //Text(context.watch<LearnLogic>().workingSet.toString()),
            Text('Got right once',
                style: Theme.of(context).textTheme.headline6),
            //Text(context.watch<LearnLogic>().rightOnce.toString()),
            Text('Got right twice',
                style: Theme.of(context).textTheme.headline6),
            //Text(context.watch<LearnLogic>().rightTwice.toString()),
            Text('Mastered', style: Theme.of(context).textTheme.headline6),
            //Text(context.watch<LearnLogic>().mastered.toString()),
          ]),
        ),
        actions: [
          TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              })
        ],
      );
}
