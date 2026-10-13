// Ashlar UI block: login-02. Copied into your app by `ashlar add login-02`; it is yours to
// change. Two columns: the form on one side, a picture on the other. On a narrow screen
// only the form shows.

import 'package:ashlar_icons/ashlar_icons.dart';
import 'package:flutter/widgets.dart';

import '../ui/button.dart';
import '../ui/form.dart';
import '../ui/separator.dart';
import '../ui/theme.dart';

/// A sign-in page beside a picture.
class Login02 extends StatefulWidget {
  const Login02({
    super.key,
    this.picture,
    this.onLogin,
    this.onForgot,
    this.onSignUp,
    this.onGoogle,
  });

  /// Shown beside the form on a wide screen: `Image.asset('assets/login.jpg', fit: BoxFit.cover)`.
  final Widget? picture;

  /// Told the email and password once both are right.
  final void Function(String email, String password)? onLogin;
  final VoidCallback? onForgot, onSignUp, onGoogle;

  @override
  State<Login02> createState() => _Login02State();
}

class _Login02State extends State<Login02> {
  final _form = GlobalKey<FormState>();
  var _email = '', _password = '';

  void _send() {
    if (_form.currentState!.submit()) widget.onLogin?.call(_email, _password);
  }

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    final c = t.colors;
    final form = Form(
      key: _form,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Login to your account',
            textAlign: TextAlign.center,
            style: t.text.xxl,
          ),
          const SizedBox(height: 8),
          Text(
            'Enter your email below to login to your account',
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
    );
    final side = Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Logo(),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 320),
                  child: form,
                ),
              ),
            ),
          ),
        ],
      ),
    );
    return LayoutBuilder(
      builder: (context, box) => box.maxWidth < 1024
          ? side
          : Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: side),
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
