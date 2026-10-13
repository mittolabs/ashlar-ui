// Ashlar UI block: login-03. Copied into your app by `ashlar add login-03`; it is yours to
// change. A sign-in card on a muted page: other accounts first, then email.

import 'package:ashlar_icons/ashlar_icons.dart';
import 'package:flutter/widgets.dart';

import '../ui/button.dart';
import '../ui/card.dart';
import '../ui/form.dart';
import '../ui/separator.dart';
import '../ui/theme.dart';

/// A sign-in card with Apple and Google above the email form.
class Login03 extends StatefulWidget {
  const Login03({
    super.key,
    this.onLogin,
    this.onForgot,
    this.onSignUp,
    this.onApple,
    this.onGoogle,
  });

  /// Told the email and password once both are right.
  final void Function(String email, String password)? onLogin;
  final VoidCallback? onForgot, onSignUp, onApple, onGoogle;

  @override
  State<Login03> createState() => _Login03State();
}

class _Login03State extends State<Login03> {
  final _form = GlobalKey<FormState>();
  var _email = '', _password = '';

  void _send() {
    if (_form.currentState!.submit()) widget.onLogin?.call(_email, _password);
  }

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    final c = t.colors;
    return ColoredBox(
      color: c.muted,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 384),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Center(child: _Logo()),
                const SizedBox(height: 24),
                Card(
                  children: [
                    const CardHeader(
                      title: Center(child: Text('Welcome back')),
                      description: Center(
                        child: Text('Login with your Apple or Google account'),
                      ),
                    ),
                    CardContent(
                      child: Form(
                        key: _form,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Button(
                              expand: true,
                              variant: ButtonVariant.outline,
                              leading: const AshlarIcon(
                                AshlarIconsRoundedStroke.apple,
                              ),
                              onPressed: widget.onApple,
                              child: const Text('Login with Apple'),
                            ),
                            const SizedBox(height: 12),
                            Button(
                              expand: true,
                              variant: ButtonVariant.outline,
                              onPressed: widget.onGoogle,
                              child: const Text('Login with Google'),
                            ),
                            const SizedBox(height: 24),
                            const _Or(),
                            const SizedBox(height: 24),
                            FormText(
                              label: const Text('Email'),
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
                              label: const Text('Password'),
                              obscureText: true,
                              autofillHints: const [AutofillHints.password],
                              onSubmitted: (_) => _send(),
                              validator: Validate.required(
                                'Enter your password.',
                              ),
                              onSaved: (v) => _password = v!,
                            ),
                            Align(
                              alignment: AlignmentDirectional.centerEnd,
                              child: Button(
                                variant: ButtonVariant.link,
                                onPressed: widget.onForgot,
                                child: const Text('Forgot your password?'),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Button(
                              expand: true,
                              onPressed: _send,
                              child: const Text('Login'),
                            ),
                            const SizedBox(height: 16),
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
                          ],
                        ),
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

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    final c = t.colors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: c.primary,
            borderRadius: BorderRadius.circular(t.radiusMd),
          ),
          child: AshlarIcon(
            AshlarIconsRoundedStroke.galleryVerticalEnd,
            size: 16,
            color: c.primaryForeground,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'Acme Inc.',
          style: t.text.sm.copyWith(fontWeight: FontWeight.w500),
        ),
      ],
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
