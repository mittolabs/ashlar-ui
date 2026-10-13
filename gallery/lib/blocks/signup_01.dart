// Ashlar UI block: signup-01. Copied into your app by `ashlar add signup-01`; it is yours to
// change. A sign-up card in the middle of the page.

import 'package:flutter/widgets.dart';

import '../ui/button.dart';
import '../ui/card.dart';
import '../ui/form.dart';

/// A sign-up card: email and password, checked when sent.
class Signup01 extends StatefulWidget {
  const Signup01({super.key, this.onSignUp, this.onLogin, this.onGoogle});

  /// Told the name, email and password once all are right.
  final void Function(String name, String email, String password)? onSignUp;
  final VoidCallback? onLogin, onGoogle;

  @override
  State<Signup01> createState() => _Signup01State();
}

class _Signup01State extends State<Signup01> {
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
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 384),
        child: Card(
          children: [
            const CardHeader(
              title: Text('Create your account'),
              description: Text(
                'Enter your details below to create your account',
              ),
            ),
            CardContent(
              child: Form(
                key: _form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
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
                    const SizedBox(height: 12),
                    Button(
                      expand: true,
                      variant: ButtonVariant.outline,
                      onPressed: widget.onGoogle,
                      child: const Text('Sign up with Google'),
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
            ),
          ],
        ),
      ),
    ),
  );
}
