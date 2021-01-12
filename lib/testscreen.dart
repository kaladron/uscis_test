import 'package:flutter/material.dart';

// TODO(jeffbailey): Going to want a new questioncontext here that is
// unidirectional and just gives me the next item.
// Start with a set of 10 questions, Put them up randomly.  Have to master the
// answer 3 times in a row (pressing "show answer" counts as a failure) before
// it's considered mastered and is popped off the list and a new question is
// brought in.

// Three new preferences to introduce:
// List<String> of mastered
// List<String> of two-right
// List<String> of one-right

// The display screen will just have three icons on the screen:
// A button to repeat the question
// A button to listen to the answer
// A next button that will appear

// When you pass (at 6 questions for 2008) or fail (10 questions for 2008)
// (20 questions for both in 2020) there needs to be a test results screen.

class TestScreen extends StatelessWidget {
  static const routeName = '/test';

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
