// Ashlar UI block: signup-05. Copied into your app by `ashlar add signup-05`; it is yours to
// change. The full sign-up form, with other accounts below.

import 'package:ashlar_icons/ashlar_icons.dart';
import 'package:flutter/widgets.dart';

import '../ui/button.dart';
import '../ui/form.dart';
import '../ui/separator.dart';
import '../ui/theme.dart';

/// A sign-up page under a logo, with other accounts below.
class Signup05 extends StatefulWidget {
  const Signup05({
    super.key,
    this.onSignUp,
    this.onLogin,
    this.onApple,
    this.onGoogle,
  });

  /// Told the name, email and password once all are right.
  final void Function(String name, String email, String password)? onSignUp;
  final VoidCallback? onLogin, onApple, onGoogle;

  @override
  State<Signup05> createState() => _Signup05State();
}

class _Signup05State extends State<Signup05> {
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
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 384),
          child: Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: c.primary,
                      borderRadius: BorderRadius.circular(t.radiusMd),
                    ),
                    child: AshlarIcon(
                      AshlarIconsRoundedStroke.galleryVerticalEnd,
                      size: 20,
                      color: c.primaryForeground,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Create your account',
                  textAlign: TextAlign.center,
                  style: t.text.xl.copyWith(fontWeight: FontWeight.w700),
                ),
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
                const SizedBox(height: 16),
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
                  description: const Text(
                    'Must be at least 8 characters long.',
                  ),
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
                  validator: (v) => v == _password.text
                      ? null
                      : 'The passwords do not match.',
                ),
                const SizedBox(height: 24),
                Button(
                  expand: true,
                  onPressed: _send,
                  child: const Text('Create Account'),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Expanded(child: Separator()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        'Or',
                        style: t.text.sm.copyWith(color: c.mutedForeground),
                      ),
                    ),
                    const Expanded(child: Separator()),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Button(
                        expand: true,
                        variant: ButtonVariant.outline,
                        leading: const AshlarIcon(
                          AshlarIconsRoundedStroke.apple,
                        ),
                        onPressed: widget.onApple,
                        semanticLabel: 'Continue with Apple',
                        child: const Text('Apple'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Button(
                        expand: true,
                        variant: ButtonVariant.outline,
                        onPressed: widget.onGoogle,
                        semanticLabel: 'Continue with Google',
                        child: const Text('Google'),
                      ),
                    ),
                  ],
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
      ),
    );
  }
}
