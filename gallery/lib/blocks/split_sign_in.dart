// Ashlar UI block: split-sign-in. Copied into your app by `ashlar add split-sign-in`; it is
// yours to change. Two columns: the sign-in form on one side, and on the other your picture,
// or a word from a customer. On a narrow screen only the form shows.
//
// The company and the customer's words are sample content; signing in is yours.

import 'package:ashlar_icons/ashlar_icons.dart';
import 'package:flutter/widgets.dart';

import '../ui/button.dart';
import '../ui/form.dart';
import '../ui/separator.dart';
import '../ui/theme.dart';

/// A sign-in page beside a picture or a customer's word.
class SplitSignIn extends StatefulWidget {
  const SplitSignIn({
    super.key,
    this.picture,
    this.onSignIn,
    this.onForgot,
    this.onCreate,
    this.onGoogle,
  });

  /// Shown beside the form on a wide screen in place of the customer's word:
  /// `Image.asset('assets/sign_in.jpg', fit: BoxFit.cover)`.
  final Widget? picture;

  /// Told the email and password once both are given.
  final void Function(String email, String password)? onSignIn;
  final VoidCallback? onForgot, onCreate, onGoogle;

  @override
  State<SplitSignIn> createState() => _SplitSignInState();
}

class _SplitSignInState extends State<SplitSignIn> {
  final _form = GlobalKey<FormState>();
  var _email = '', _password = '';

  void _send() {
    if (_form.currentState!.submit()) widget.onSignIn?.call(_email, _password);
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
          Text('Welcome back', style: t.text.xxl),
          const SizedBox(height: 8),
          Text(
            'Sign in to see your trips and bookings.',
            style: t.text.sm.copyWith(color: c.mutedForeground),
          ),
          const SizedBox(height: 24),
          FormText(
            label: const Text('Email'),
            placeholder: 'you@example.com',
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            validator: Validate.all([
              Validate.required('Enter your email.'),
              Validate.email(),
            ]),
            onSaved: (v) => _email = v!,
          ),
          const SizedBox(height: 16),
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
              onPressed: () => widget.onForgot?.call(),
              child: const Text('Forgot it?'),
            ),
          ),
          const SizedBox(height: 4),
          Button(expand: true, onPressed: _send, child: const Text('Sign in')),
          const SizedBox(height: 16),
          Row(
            children: [
              const Expanded(child: Separator()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  'or',
                  style: t.text.sm.copyWith(color: c.mutedForeground),
                ),
              ),
              const Expanded(child: Separator()),
            ],
          ),
          const SizedBox(height: 16),
          Button(
            expand: true,
            variant: ButtonVariant.outline,
            leading: const AshlarIcon(AshlarIconsRoundedStroke.brandGoogle),
            onPressed: () => widget.onGoogle?.call(),
            child: const Text('Continue with Google'),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 6,
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text('First time here?'),
              Button(
                variant: ButtonVariant.link,
                onPressed: () => widget.onCreate?.call(),
                child: const Text('Create an account'),
              ),
            ],
          ),
        ],
      ),
    );
    final side = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              const AshlarIcon(AshlarIconsRoundedStroke.tentTree, size: 20),
              const SizedBox(width: 8),
              Text(
                'Safari Lane',
                style: t.text.base.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: form,
              ),
            ),
          ),
        ),
      ],
    );
    return LayoutBuilder(
      builder: (context, box) => box.maxWidth < 900
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
                        Padding(
                          padding: const EdgeInsets.all(48),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const AshlarIcon(
                                AshlarIconsRoundedStroke.quote,
                                size: 28,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'We booked the Mara for the whole family before lunch, '
                                'and the driver was waiting at Narok at seven the next morning.',
                                style: t.text.xl.copyWith(height: 1.4),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Sofia Lindqvist, Stockholm',
                                style: t.text.sm.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                'Three trips with Safari Lane',
                                style: t.text.sm.copyWith(
                                  color: c.mutedForeground,
                                ),
                              ),
                            ],
                          ),
                        ),
                  ),
                ),
              ],
            ),
    );
  }
}
