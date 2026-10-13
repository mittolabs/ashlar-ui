// Ashlar UI block: signup-02. Copied into your app by `ashlar add signup-02`; it is yours to
// change. Two columns: the form on one side, a picture on the other. On a narrow screen
// only the form shows.

import 'package:ashlar_icons/ashlar_icons.dart';
import 'package:flutter/widgets.dart';

import '../ui/button.dart';
import '../ui/form.dart';
import '../ui/separator.dart';
import '../ui/theme.dart';

/// A sign-up page beside a picture.
class Signup02 extends StatefulWidget {
  const Signup02({
    super.key,
    this.picture,
    this.onSignUp,
    this.onLogin,
    this.onGoogle,
  });

  /// Shown beside the form on a wide screen: `Image.asset('assets/signup.jpg', fit: BoxFit.cover)`.
  final Widget? picture;

  /// Told the name, email and password once all are right.
  final void Function(String name, String email, String password)? onSignUp;
  final VoidCallback? onLogin, onGoogle;

  @override
  State<Signup02> createState() => _Signup02State();
}

class _Signup02State extends State<Signup02> {
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
    final form = Form(
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
          const SizedBox(height: 8),
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
