// The form picture ashlar update --preview draws, from the site's demo.
import 'package:flutter/widgets.dart';

import 'package:ashlar_ui_gallery/ui/button.dart';
import 'package:ashlar_ui_gallery/ui/checkbox.dart';
import 'package:ashlar_ui_gallery/ui/form.dart';
import 'package:ashlar_ui_gallery/ui/select.dart';

class FormDemo extends StatefulWidget {
  const FormDemo({super.key});

  @override
  State<FormDemo> createState() => _FormDemoState();
}

class _FormDemoState extends State<FormDemo> {
  final form = GlobalKey<FormState>();
  String? sent;

  void send() {
    if (form.currentState!.submit()) setState(() => sent = 'Account created.');
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 340,
    child: Form(
      key: form,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FormText(
            label: const Text('Name'),
            placeholder: 'Maya Thompson',
            validator: Validate.required('Enter your name.'),
          ),
          const SizedBox(height: 20),
          FormText(
            label: const Text('Email'),
            placeholder: 'you@example.com',
            keyboardType: TextInputType.emailAddress,
            validator: Validate.all([
              Validate.required('Enter your email.'),
              Validate.email(),
            ]),
          ),
          const SizedBox(height: 20),
          FormItem<String>(
            label: const Text('Team'),
            description: const Text('Who sees your work first.'),
            validator: Validate.required('Pick a team.'),
            builder: (field) => Select<String>(
              value: field.value,
              placeholder: 'Choose a team',
              error: field.hasError,
              options: const [
                SelectOption('design', 'Design'),
                SelectOption('engineering', 'Engineering'),
                SelectOption('sales', 'Sales'),
              ],
              onChanged: field.didChange,
            ),
          ),
          const SizedBox(height: 20),
          FormItem<bool>(
            initialValue: false,
            axis: Axis.horizontal,
            label: const Text('Accept the terms'),
            validator: Validate.required('Accept the terms to go on.'),
            builder: (field) => Checkbox(
              value: field.value!,
              error: field.hasError,
              onChanged: field.didChange,
            ),
          ),
          const SizedBox(height: 24),
          Button(onPressed: send, child: const Text('Create account')),
          if (sent != null) ...[const SizedBox(height: 12), Text(sent!)],
        ],
      ),
    ),
  );
}
