// Ashlar UI block: member-sign-up. Copied into your app by `ashlar add member-sign-up`; it is
// yours to change. Becoming a member in three steps, under the society's name: your
// details, your ID, then a PIN, with where you are along the top and a way back.
//
// The society is sample content; making the member is yours.

import 'package:ashlar_icons/ashlar_icons.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../ui/button.dart';
import '../ui/form.dart';
import '../ui/input_otp.dart';
import '../ui/theme.dart';

/// What a new member gives.
class NewMember {
  const NewMember({
    required this.name,
    required this.phone,
    required this.idNumber,
    required this.pin,
  });

  final String name, phone, idNumber, pin;
}

/// A three-step sign-up: details, ID, PIN.
class MemberSignUp extends StatefulWidget {
  const MemberSignUp({super.key, this.onDone, this.onSignIn});

  /// Told everything once the last step is right.
  final ValueChanged<NewMember>? onDone;
  final VoidCallback? onSignIn;

  @override
  State<MemberSignUp> createState() => _MemberSignUpState();
}

class _MemberSignUpState extends State<MemberSignUp> {
  final _forms = [GlobalKey<FormState>(), GlobalKey<FormState>()];
  var _step = 0;
  var _name = '', _phone = '', _id = '', _pin = '', _again = '';
  var _pinWrong = false;

  static const _steps = ['Your details', 'Your ID', 'Your PIN'];

  void _next() {
    if (_step < 2) {
      if (_forms[_step].currentState!.submit()) setState(() => _step++);
      return;
    }
    if (_pin.length != 4 || _pin != _again) {
      setState(() => _pinWrong = true);
      return;
    }
    widget.onDone?.call(
      NewMember(name: _name.trim(), phone: _phone, idNumber: _id, pin: _pin),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    final c = t.colors;
    final body = switch (_step) {
      0 => Form(
        key: _forms[0],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FormText(
              initialValue: _name,
              label: const Text('Full name'),
              placeholder: 'As on your ID',
              validator: Validate.required('Enter your name.'),
              onSaved: (v) => _name = v!,
            ),
            const SizedBox(height: 16),
            FormText(
              initialValue: _phone,
              label: const Text('Phone number'),
              description: const Text(
                'We text you when money comes in or goes out.',
              ),
              placeholder: '+1 415 555 0123',
              keyboardType: TextInputType.phone,
              validator: Validate.required('Enter your number.'),
              onSaved: (v) => _phone = v!,
            ),
          ],
        ),
      ),
      1 => Form(
        key: _forms[1],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FormText(
              initialValue: _id,
              label: const Text('ID or passport number'),
              placeholder: 'As it is on the card',
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                LengthLimitingTextInputFormatter(20),
              ],
              validator: Validate.all([
                Validate.required('Enter your ID or passport number.'),
                Validate.pattern(
                  RegExp(r'^[A-Za-z0-9]{5,20}$'),
                  'That is too short for an ID or passport number.',
                ),
              ]),
              onSaved: (v) => _id = v!,
            ),
            const SizedBox(height: 12),
            Text(
              'We check it once to open the account. Nothing is shared with anyone else.',
              style: t.text.sm.copyWith(color: c.mutedForeground),
            ),
          ],
        ),
      ),
      _ => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Choose a PIN',
            style: t.text.sm.copyWith(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          InputOtp(
            length: 4,
            semanticLabel: 'PIN',
            error: _pinWrong,
            onChanged: (v) => setState(() {
              _pin = v;
              _pinWrong = false;
            }),
          ),
          const SizedBox(height: 16),
          Text(
            'Once more',
            style: t.text.sm.copyWith(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          InputOtp(
            length: 4,
            semanticLabel: 'The PIN again',
            error: _pinWrong,
            onChanged: (v) => setState(() {
              _again = v;
              _pinWrong = false;
            }),
          ),
          if (_pinWrong) ...[
            const SizedBox(height: 8),
            Text(
              'The two PINs are not the same.',
              style: t.text.sm.copyWith(color: c.destructive),
            ),
          ],
        ],
      ),
    };
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const AshlarIcon(
                    AshlarIconsRoundedStroke.handCoins,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Unity Credit Union',
                      style: t.text.lg.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Semantics(
                label: 'Step ${_step + 1} of 3: ${_steps[_step]}',
                child: Row(
                  children: [
                    for (var i = 0; i < 3; i++) ...[
                      if (i > 0) const SizedBox(width: 6),
                      Expanded(
                        child: AnimatedContainer(
                          duration: t.duration,
                          height: 4,
                          decoration: BoxDecoration(
                            color: i <= _step ? c.primary : c.muted,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Step ${_step + 1} of 3',
                style: t.text.xs.copyWith(color: c.mutedForeground),
              ),
              Text(
                _steps[_step],
                style: t.text.xl.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),
              body,
              const SizedBox(height: 24),
              Row(
                children: [
                  if (_step > 0)
                    Button(
                      variant: ButtonVariant.outline,
                      onPressed: () => setState(() => _step--),
                      child: const Text('Back'),
                    ),
                  const Spacer(),
                  Button(
                    onPressed: _next,
                    child: Text(_step < 2 ? 'Next' : 'Become a member'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 6,
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Text('Already a member?'),
                  Button(
                    variant: ButtonVariant.link,
                    onPressed: () => widget.onSignIn?.call(),
                    child: const Text('Sign in'),
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
