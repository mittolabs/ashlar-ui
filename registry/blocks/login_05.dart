// Ashlar UI block: login-05. Copied into your app by `ashlar add login-05`; it is yours to
// change. Email only, for a sign-in link sent by mail, with other accounts below.

import 'package:ashlar_icons/ashlar_icons.dart';
import 'package:flutter/widgets.dart';

import '../ui/button.dart';
import '../ui/form.dart';
import '../ui/separator.dart';
import '../ui/theme.dart';

/// A sign-in page that asks only for an email address.
class Login05 extends StatefulWidget {
  const Login05({
    super.key,
    this.onLogin,
    this.onSignUp,
    this.onApple,
    this.onGoogle,
  });

  /// Told the email once it is right: send the sign-in link to it.
  final ValueChanged<String>? onLogin;
  final VoidCallback? onSignUp, onApple, onGoogle;

  @override
  State<Login05> createState() => _Login05State();
}

class _Login05State extends State<Login05> {
  final _form = GlobalKey<FormState>();
  var _email = '';

  void _send() {
    if (_form.currentState!.submit()) widget.onLogin?.call(_email);
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
                  'Welcome to Acme Inc.',
                  textAlign: TextAlign.center,
                  style: t.text.xl.copyWith(fontWeight: FontWeight.w700),
                ),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text("Don't have an account?"),
                    Button(
                      variant: ButtonVariant.link,
                      onPressed: widget.onSignUp,
                      child: const Text('Sign up'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                FormText(
                  label: const Text('Email'),
                  placeholder: 'you@solutech.co.ke',
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  onSubmitted: (_) => _send(),
                  validator: Validate.all([
                    Validate.required('Enter your email.'),
                    Validate.email(),
                  ]),
                  onSaved: (v) => _email = v!,
                ),
                const SizedBox(height: 24),
                Button(
                  expand: true,
                  onPressed: _send,
                  child: const Text('Login'),
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
                        child: const Text('Continue with Apple'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Button(
                        expand: true,
                        variant: ButtonVariant.outline,
                        onPressed: widget.onGoogle,
                        child: const Text('Continue with Google'),
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
