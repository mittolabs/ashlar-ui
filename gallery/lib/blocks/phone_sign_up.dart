// Ashlar UI block: phone-sign-up. Copied into your app by `ashlar add phone-sign-up`; it is
// yours to change. Create an account with a name and a phone number, the terms agreed to,
// in a card in the middle of the page.
//
// Creating the account (and texting a code to check the number) is yours: onSignUp.

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../ui/button.dart';
import '../ui/card.dart';
import '../ui/checkbox.dart';
import '../ui/form.dart';
import '../ui/select.dart';
import '../ui/theme.dart';

/// Where a number can be from, and its country code. Add the ones you serve.
const _countries = [
  ('United States', '1'),
  ('United Kingdom', '44'),
  ('India', '91'),
  ('Nigeria', '234'),
  ('Kenya', '254'),
  ('Germany', '49'),
  ('Brazil', '55'),
  ('Philippines', '63'),
  ('Mexico', '52'),
  ('Japan', '81'),
];

/// A sign-up card: a name, a phone number, and the terms.
class PhoneSignUp extends StatefulWidget {
  const PhoneSignUp({
    super.key,
    this.dialCode = '1',
    this.onSignUp,
    this.onSignIn,
    this.onTerms,
  });

  /// The country code picked to begin with, without the +.
  final String dialCode;

  /// Told the name and the number in full (+14155550123) once both are right and the
  /// terms are agreed to.
  final void Function(String name, String phone)? onSignUp;
  final VoidCallback? onSignIn, onTerms;

  @override
  State<PhoneSignUp> createState() => _PhoneSignUpState();
}

class _PhoneSignUpState extends State<PhoneSignUp> {
  final _form = GlobalKey<FormState>();
  var _name = '', _phone = '';
  late var _dial = widget.dialCode;
  late final _terms = TapGestureRecognizer()
    ..onTap = () => widget.onTerms?.call();

  @override
  void dispose() {
    _terms.dispose();
    super.dispose();
  }

  void _send() {
    if (!_form.currentState!.submit()) return;
    final digits = _phone.replaceAll(RegExp(r'\D'), '');
    // In full, its country code first; a leading 0, as many countries write it at home,
    // is left off.
    widget.onSignUp?.call(
      _name.trim(),
      '+$_dial${digits.startsWith('0') ? digits.substring(1) : digits}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    final c = t.colors;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 384),
          child: Card(
            children: [
              const CardHeader(
                title: Text('Create your account'),
                description: Text(
                  'Your number is how you sign in. We text you a code to check it.',
                ),
              ),
              CardContent(
                child: Form(
                  key: _form,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      FormText(
                        label: const Text('Your name'),
                        placeholder: 'As on your ID',
                        autofillHints: const [AutofillHints.name],
                        validator: Validate.required('Enter your name.'),
                        onSaved: (v) => _name = v!,
                      ),
                      const SizedBox(height: 16),
                      FormItem<String>(
                        label: const Text('Country'),
                        initialValue: _dial,
                        builder: (field) => Select<String>(
                          value: field.value,
                          semanticLabel: 'Country',
                          options: [
                            for (final (name, code) in _countries)
                              SelectOption(code, '$name +$code'),
                          ],
                          onChanged: (v) {
                            field.didChange(v);
                            setState(() => _dial = v);
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      FormText(
                        label: const Text('Phone number'),
                        placeholder: 'Without the country code',
                        leading: Text(
                          '+$_dial',
                          style: t.text.sm.copyWith(color: c.mutedForeground),
                        ),
                        keyboardType: TextInputType.phone,
                        autofillHints: const [AutofillHints.telephoneNumber],
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[\d ]')),
                        ],
                        validator: Validate.all([
                          Validate.required('Enter your phone number.'),
                          (v) {
                            final digits = v!.replaceAll(RegExp(r'\D'), '');
                            return digits.length >= 6 && digits.length <= 14
                                ? null
                                : 'That does not look like a phone number.';
                          },
                        ]),
                        onSaved: (v) => _phone = v!,
                      ),
                      const SizedBox(height: 16),
                      FormItem<bool>(
                        axis: Axis.horizontal,
                        initialValue: false,
                        label: Text.rich(
                          TextSpan(
                            children: [
                              const TextSpan(text: 'I agree to the '),
                              TextSpan(
                                text: 'terms',
                                recognizer: _terms,
                                style: const TextStyle(
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                        validator: (v) => v == true
                            ? null
                            : 'Agree to the terms to carry on.',
                        builder: (field) => Checkbox(
                          value: field.value ?? false,
                          semanticLabel: 'I agree to the terms',
                          onChanged: field.didChange,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Button(
                        expand: true,
                        onPressed: _send,
                        child: const Text('Create account'),
                      ),
                    ],
                  ),
                ),
              ),
              CardFooter(
                alignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Wrap(
                      spacing: 6,
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        const Text('Already have one?'),
                        Button(
                          variant: ButtonVariant.link,
                          onPressed: () => widget.onSignIn?.call(),
                          child: const Text('Sign in'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
