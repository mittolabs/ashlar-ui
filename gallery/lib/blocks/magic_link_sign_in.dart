// Ashlar UI block: magic-link-sign-in. Copied into your app by
// `ashlar add magic-link-sign-in`; it is yours to change. Sign in with an email address
// alone: a link is sent to it, and the page says where to look.
//
// Sending the link is yours: onSend.

import 'package:ashlar_icons/ashlar_icons.dart';
import 'package:flutter/widgets.dart';

import '../ui/button.dart';
import '../ui/form.dart';
import '../ui/theme.dart';

/// An email address, then a page saying the link is on its way.
class MagicLinkSignIn extends StatefulWidget {
  const MagicLinkSignIn({super.key, this.onSend});

  /// Told the address once it is one.
  final ValueChanged<String>? onSend;

  @override
  State<MagicLinkSignIn> createState() => _MagicLinkSignInState();
}

class _MagicLinkSignInState extends State<MagicLinkSignIn> {
  final _form = GlobalKey<FormState>();
  var _email = '';
  var _sent = false;

  void _send() {
    if (!_form.currentState!.submit()) return;
    setState(() => _sent = true);
    widget.onSend?.call(_email);
  }

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    final c = t.colors;
    Widget mark(IconData icon) => Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: c.muted,
        borderRadius: BorderRadius.circular(t.radiusXl),
      ),
      child: AshlarIcon(icon, size: 22),
    );
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: _sent
              ? Column(
                  children: [
                    mark(AshlarIconsRoundedStroke.mailCheck),
                    const SizedBox(height: 16),
                    Text(
                      'Check your email',
                      style: t.text.xl.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'We sent a sign-in link to $_email. It works once, for 15 minutes. '
                      'Open it on this device.',
                      textAlign: TextAlign.center,
                      style: t.text.sm.copyWith(color: c.mutedForeground),
                    ),
                    const SizedBox(height: 24),
                    Button(
                      expand: true,
                      variant: ButtonVariant.outline,
                      onPressed: () => widget.onSend?.call(_email),
                      child: const Text('Send it again'),
                    ),
                    const SizedBox(height: 8),
                    Button(
                      variant: ButtonVariant.link,
                      onPressed: () => setState(() => _sent = false),
                      child: const Text('Use a different email'),
                    ),
                  ],
                )
              : Form(
                  key: _form,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(child: mark(AshlarIconsRoundedStroke.mail)),
                      const SizedBox(height: 16),
                      Text(
                        'Sign in without a password',
                        textAlign: TextAlign.center,
                        style: t.text.xl.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Enter your email and we will send you a link that signs you in.',
                        textAlign: TextAlign.center,
                        style: t.text.sm.copyWith(color: c.mutedForeground),
                      ),
                      const SizedBox(height: 24),
                      FormText(
                        label: const Text('Email'),
                        placeholder: 'you@example.com',
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.email],
                        onChanged: (v) => _email = v,
                        onSubmitted: (_) => _send(),
                        validator: Validate.all([
                          Validate.required('Enter your email.'),
                          Validate.email(),
                        ]),
                      ),
                      const SizedBox(height: 16),
                      Button(
                        expand: true,
                        onPressed: _send,
                        child: const Text('Send me a link'),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
