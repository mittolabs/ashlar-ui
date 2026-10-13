// Ashlar UI block: signup-04. Copied into your app by `ashlar add signup-04`; it is yours to
// change. One card in two halves: the form, and a picture beside it on a wide screen.

import 'package:ashlar_icons/ashlar_icons.dart';
import 'package:flutter/widgets.dart';

import '../ui/button.dart';
import '../ui/form.dart';
import '../ui/separator.dart';
import '../ui/theme.dart';

/// A sign-up card with a picture in its second half.
class Signup04 extends StatefulWidget {
  const Signup04({
    super.key,
    this.picture,
    this.onSignUp,
    this.onLogin,
    this.onApple,
    this.onGoogle,
    this.onMeta,
  });

  /// Shown in the card's second half on a wide screen.
  final Widget? picture;

  /// Told the name, email and password once all are right.
  final void Function(String name, String email, String password)? onSignUp;
  final VoidCallback? onLogin, onApple, onGoogle, onMeta;

  @override
  State<Signup04> createState() => _Signup04State();
}

class _Signup04State extends State<Signup04> {
  final _form = GlobalKey<FormState>();
  final _password = TextEditingController();
  var _name = '', _email = '';

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  void _send() {
    if (_form.currentState!.submit()) {
      widget.onSignUp?.call(_name, _email, _password.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    final c = t.colors;
    final form = Padding(
      padding: const EdgeInsets.all(32),
      child: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Create your account',
              textAlign: TextAlign.center,
              style: t.text.xxl,
            ),
            const SizedBox(height: 4),
            Text(
              'Enter your details below to create your account',
              textAlign: TextAlign.center,
              style: t.text.sm.copyWith(color: c.mutedForeground),
            ),
            const SizedBox(height: 24),
            FormText(
              label: const Text('Full Name'),
              placeholder: 'Wanjiru Kamau',
              autofillHints: const [AutofillHints.name],
              validator: Validate.required('Enter your name.'),
              onSaved: (v) => _name = v!,
            ),
            const SizedBox(height: 24),
            FormText(
              label: const Text('Email'),
              description: const Text(
                "We'll use this to contact you. We will not share your email with anyone else.",
              ),
              placeholder: 'you@solutech.co.ke',
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              validator: Validate.all([
                Validate.required('Enter your email.'),
                Validate.email(),
              ]),
              onSaved: (v) => _email = v!,
            ),
            const SizedBox(height: 24),
            FormText(
              controller: _password,
              label: const Text('Password'),
              description: const Text('Must be at least 8 characters long.'),
              obscureText: true,
              autofillHints: const [AutofillHints.newPassword],
              validator: Validate.all([
                Validate.required('Choose a password.'),
                Validate.minLength(8),
              ]),
            ),
            const SizedBox(height: 24),
            FormText(
              label: const Text('Confirm Password'),
              obscureText: true,
              autofillHints: const [AutofillHints.newPassword],
              onSubmitted: (_) => _send(),
              validator: (v) =>
                  v == _password.text ? null : 'The passwords do not match.',
            ),
            const SizedBox(height: 24),
            Button(
              expand: true,
              onPressed: _send,
              child: const Text('Create Account'),
            ),
            const SizedBox(height: 24),
            const _Or(),
            const SizedBox(height: 24),
            Row(
              children: [
                for (final (i, (label, onPressed)) in [
                  ('Apple', widget.onApple),
                  ('Google', widget.onGoogle),
                  ('Meta', widget.onMeta),
                ].indexed) ...[
                  if (i > 0) const SizedBox(width: 12),
                  Expanded(
                    child: Button(
                      expand: true,
                      variant: ButtonVariant.outline,
                      semanticLabel: 'Sign up with $label',
                      onPressed: onPressed,
                      child: Text(label),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Text('Already have an account?'),
                Button(
                  variant: ButtonVariant.link,
                  onPressed: widget.onLogin,
                  child: const Text('Sign in'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 768),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: c.card,
                  borderRadius: BorderRadius.circular(t.radiusXl),
                  border: Border.all(color: c.border),
                  boxShadow: t.shadowSm,
                ),
                child: LayoutBuilder(
                  builder: (context, box) => box.maxWidth < 640
                      ? form
                      : IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(child: form),
                              Expanded(
                                child: ColoredBox(
                                  color: c.muted,
                                  child:
                                      widget.picture ??
                                      Center(
                                        child: AshlarIcon(
                                          AshlarIconsRoundedStroke.image,
                                          size: 48,
                                          color: c.mutedForeground,
                                        ),
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'By clicking continue, you agree to our Terms of Service and '
                'Privacy Policy.',
                textAlign: TextAlign.center,
                style: t.text.xs.copyWith(color: c.mutedForeground),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A line with "Or continue with" across its middle.
class _Or extends StatelessWidget {
  const _Or();

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    return Row(
      children: [
        const Expanded(child: Separator()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            'Or continue with',
            style: t.text.sm.copyWith(color: t.colors.mutedForeground),
          ),
        ),
        const Expanded(child: Separator()),
      ],
    );
  }
}
