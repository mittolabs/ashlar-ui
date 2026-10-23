// Ashlar UI block: phone-sign-in. Copied into your app by `ashlar add phone-sign-in`; it is
// yours to change. Sign in with a phone number: the number first, then the six-digit code
// sent to it by SMS.
//
// Sending and checking the code are yours: onSendCode and onVerify.

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../ui/button.dart';
import '../ui/card.dart';
import '../ui/form.dart';
import '../ui/input_otp.dart';
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

/// A sign-in card: a phone number, then the code sent to it.
class PhoneSignIn extends StatefulWidget {
  const PhoneSignIn({
    super.key,
    this.dialCode = '1',
    this.onSendCode,
    this.onVerify,
    this.onHelp,
  });

  /// The country code picked to begin with, without the +.
  final String dialCode;

  /// Told the number in full (+14155550123) once it looks like a phone number.
  final ValueChanged<String>? onSendCode;

  /// Told the number and the code once all six digits are in.
  final void Function(String phone, String code)? onVerify;
  final VoidCallback? onHelp;

  @override
  State<PhoneSignIn> createState() => _PhoneSignInState();
}

class _PhoneSignInState extends State<PhoneSignIn> {
  final _form = GlobalKey<FormState>();
  String? _phone;
  var _number = '';
  late var _dial = widget.dialCode;

  /// The number in full, its country code first: 415 555 0123 in the United States as
  /// +14155550123. A leading 0, as many countries write it at home, is left off.
  String _full(String typed) {
    final digits = typed.replaceAll(RegExp(r'\D'), '');
    return '+$_dial${digits.startsWith('0') ? digits.substring(1) : digits}';
  }

  void _send() {
    if (!_form.currentState!.submit()) return;
    final phone = _full(_number);
    setState(() => _phone = phone);
    widget.onSendCode?.call(phone);
  }

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    final c = t.colors;
    final phone = _phone;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 384),
          child: Card(
            children: [
              CardHeader(
                title: Text(phone == null ? 'Sign in' : 'Enter the code'),
                description: Text(
                  phone == null
                      ? 'We will text you a code. No password to remember.'
                      : 'Sent by SMS to $phone. It works for 10 minutes.',
                ),
              ),
              CardContent(
                child: phone == null
                    ? Form(
                        key: _form,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
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
                                style: t.text.sm.copyWith(
                                  color: c.mutedForeground,
                                ),
                              ),
                              keyboardType: TextInputType.phone,
                              autofillHints: const [
                                AutofillHints.telephoneNumber,
                              ],
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'[\d ]'),
                                ),
                              ],
                              onChanged: (v) => _number = v,
                              onSubmitted: (_) => _send(),
                              validator: Validate.all([
                                Validate.required('Enter your phone number.'),
                                (v) {
                                  final digits = v!.replaceAll(
                                    RegExp(r'\D'),
                                    '',
                                  );
                                  return digits.length >= 6 &&
                                          digits.length <= 14
                                      ? null
                                      : 'That does not look like a phone number.';
                                },
                              ]),
                            ),
                            const SizedBox(height: 16),
                            Button(
                              expand: true,
                              onPressed: _send,
                              child: const Text('Text me a code'),
                            ),
                          ],
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(
                            child: InputOtp(
                              autofocus: true,
                              groups: const [3, 3],
                              onCompleted: (code) =>
                                  widget.onVerify?.call(phone, code),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 6,
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                'No SMS?',
                                style: t.text.sm.copyWith(
                                  color: c.mutedForeground,
                                ),
                              ),
                              Button(
                                variant: ButtonVariant.link,
                                onPressed: () => widget.onSendCode?.call(phone),
                                child: const Text('Send it again'),
                              ),
                            ],
                          ),
                          Button(
                            variant: ButtonVariant.ghost,
                            onPressed: () => setState(() => _phone = null),
                            child: const Text('Use another number'),
                          ),
                        ],
                      ),
              ),
              CardFooter(
                alignment: MainAxisAlignment.center,
                children: [
                  Button(
                    variant: ButtonVariant.link,
                    onPressed: () => widget.onHelp?.call(),
                    child: const Text('Lost your phone?'),
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
