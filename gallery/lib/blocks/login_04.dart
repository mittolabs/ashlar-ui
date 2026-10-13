// Ashlar UI block: login-04. Copied into your app by `ashlar add login-04`; it is yours to
// change. One card in two halves: the form, and a picture beside it on a wide screen.

import 'package:ashlar_icons/ashlar_icons.dart';
import 'package:flutter/widgets.dart';

import '../ui/button.dart';
import '../ui/form.dart';
import '../ui/separator.dart';
import '../ui/theme.dart';

/// A sign-in card with a picture in its second half.
class Login04 extends StatefulWidget {
  const Login04({
    super.key,
    this.picture,
    this.onLogin,
    this.onForgot,
    this.onSignUp,
    this.onApple,
    this.onGoogle,
    this.onMeta,
  });

  /// Shown in the card's second half on a wide screen.
  final Widget? picture;

  /// Told the email and password once both are right.
  final void Function(String email, String password)? onLogin;
  final VoidCallback? onForgot, onSignUp, onApple, onGoogle, onMeta;

  @override
  State<Login04> createState() => _Login04State();
}

class _Login04State extends State<Login04> {
  final _form = GlobalKey<FormState>();
  var _email = '', _password = '';

  void _send() {
    if (_form.currentState!.submit()) widget.onLogin?.call(_email, _password);
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
              'Welcome back',
              textAlign: TextAlign.center,
              style: t.text.xxl,
            ),
            const SizedBox(height: 4),
            Text(
              'Login to your Acme Inc account',
              textAlign: TextAlign.center,
              style: t.text.sm.copyWith(color: c.mutedForeground),
            ),
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
            Button(expand: true, onPressed: _send, child: const Text('Login')),
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
                      semanticLabel: 'Login with $label',
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
