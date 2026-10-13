// Ashlar UI block: login-01. Copied into your app by `ashlar add login-01`; it is yours to
// change. A sign-in card in the middle of the page.

import 'package:flutter/widgets.dart';

import '../ui/button.dart';
import '../ui/card.dart';
import '../ui/form.dart';

/// A sign-in card: email and password, checked when sent.
class Login01 extends StatefulWidget {
  const Login01({
    super.key,
    this.onLogin,
    this.onForgot,
    this.onSignUp,
    this.onGoogle,
  });

  /// Told the email and password once both are right.
  final void Function(String email, String password)? onLogin;
  final VoidCallback? onForgot, onSignUp, onGoogle;

  @override
  State<Login01> createState() => _Login01State();
}

class _Login01State extends State<Login01> {
  final _form = GlobalKey<FormState>();
  var _email = '', _password = '';

  void _send() {
    if (_form.currentState!.submit()) widget.onLogin?.call(_email, _password);
  }

  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 384),
        child: Card(
          children: [
            const CardHeader(
              title: Text('Login to your account'),
              description: Text(
                'Enter your email below to login to your account',
              ),
            ),
            CardContent(
              child: Form(
                key: _form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
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
                      validator: Validate.required('Enter your password.'),
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
                    const SizedBox(height: 12),
                    Button(
                      expand: true,
                      variant: ButtonVariant.outline,
                      onPressed: widget.onGoogle,
                      child: const Text('Login with Google'),
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
      ),
    ),
  );
}
