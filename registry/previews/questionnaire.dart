// The questionnaire picture ashlar update --preview draws, from the site's demo.
import 'package:flutter/widgets.dart';

import 'package:ashlar_ui_gallery/ui/card.dart';
import 'package:ashlar_ui_gallery/ui/questionnaire.dart';

class QuestionnaireDemo extends StatefulWidget {
  const QuestionnaireDemo({super.key});

  @override
  State<QuestionnaireDemo> createState() => _QuestionnaireDemoState();
}

class _QuestionnaireDemoState extends State<QuestionnaireDemo> {
  String? _done;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 440,
    child: Card(
      children: [
        CardContent(
          child: _done != null
              ? Text(_done!)
              : Questionnaire(
                  shortcuts: QuestionShortcuts.letters,
                  onSubmit: (a) => setState(
                    () => _done = 'Thanks. You chose ${a['direction']}.',
                  ),
                  questions: const [
                    Question(
                      name: 'direction',
                      prompt: 'What should we build next?',
                      description: 'Choose a direction or write your own.',
                      required: true,
                      choices: [
                        QuestionChoice(
                          'chat',
                          'Chat',
                          description: 'Messages, bubbles and a scroller.',
                        ),
                        QuestionChoice(
                          'forms',
                          'Forms',
                          description: 'Fields checked when sent.',
                        ),
                        QuestionChoice('both', 'Both together'),
                      ],
                      other: 'Another answer',
                      otherPlaceholder: 'Type another answer…',
                    ),
                    Question(
                      name: 'detail',
                      prompt: 'How much detail should it have?',
                      description: 'Skip this if you are not sure yet.',
                      choices: [
                        QuestionChoice('focused', 'Focused'),
                        QuestionChoice('complete', 'The complete flow'),
                      ],
                    ),
                  ],
                ),
        ),
      ],
    ),
  );
}
