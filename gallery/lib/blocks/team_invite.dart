// Ashlar UI block: team-invite. Copied into your app by `ashlar add team-invite`; it is
// yours to change. Joining from an invitation: who invited you and to what, the team
// already there, then your name and a password, on a muted page.
//
// The team and the invitation are sample data; joining is yours.

import 'package:flutter/widgets.dart';

import '../ui/avatar.dart';
import '../ui/button.dart';
import '../ui/card.dart';
import '../ui/form.dart';
import '../ui/theme.dart';

/// An invitation to a team, and the form to accept it.
class TeamInvite extends StatefulWidget {
  const TeamInvite({
    super.key,
    this.team = 'Swift Parcel support',
    this.invitedBy = 'Mei Tanaka',
    this.email = 'sam@example.com',
    this.members = const [
      'Mei Tanaka',
      'Brian Kiprop',
      'Amina Yusuf',
      'Lucas Moreau',
      'Priya Nair',
    ],
    this.onJoin,
    this.onDecline,
  });

  final String team, invitedBy;

  /// The address the invitation went to: the account is made for it.
  final String email;

  /// Who is in the team already.
  final List<String> members;

  /// Told the name and password once both are right.
  final void Function(String name, String password)? onJoin;
  final VoidCallback? onDecline;

  @override
  State<TeamInvite> createState() => _TeamInviteState();
}

class _TeamInviteState extends State<TeamInvite> {
  final _form = GlobalKey<FormState>();
  var _name = '', _password = '';

  void _send() {
    if (_form.currentState!.submit()) {
      widget.onJoin?.call(_name.trim(), _password);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    final c = t.colors;
    String initials(String name) => name.split(' ').map((w) => w[0]).join();
    return ColoredBox(
      color: c.muted,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: AvatarGroup(
                    size: 40,
                    max: 4,
                    semanticLabel: '${widget.members.length} in the team',
                    children: [
                      for (final name in widget.members)
                        Avatar(fallback: initials(name), semanticLabel: name),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: widget.invitedBy,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const TextSpan(text: ' invited you to join '),
                      TextSpan(
                        text: widget.team,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                  style: t.text.lg,
                ),
                const SizedBox(height: 24),
                Card(
                  children: [
                    CardHeader(
                      title: const Text('Set up your account'),
                      description: Text('For ${widget.email}'),
                    ),
                    CardContent(
                      child: Form(
                        key: _form,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            FormText(
                              label: const Text('Your name'),
                              placeholder: 'How the team will see you',
                              autofillHints: const [AutofillHints.name],
                              validator: Validate.required('Enter your name.'),
                              onSaved: (v) => _name = v!,
                            ),
                            const SizedBox(height: 16),
                            FormText(
                              label: const Text('Password'),
                              description: const Text(
                                'At least 10 characters.',
                              ),
                              obscureText: true,
                              autofillHints: const [AutofillHints.newPassword],
                              onSubmitted: (_) => _send(),
                              validator: Validate.all([
                                Validate.required('Choose a password.'),
                                Validate.minLength(
                                  10,
                                  'Use at least 10 characters.',
                                ),
                              ]),
                              onSaved: (v) => _password = v!,
                            ),
                            const SizedBox(height: 20),
                            Button(
                              expand: true,
                              onPressed: _send,
                              child: const Text('Join the team'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Center(
                  child: Button(
                    variant: ButtonVariant.link,
                    onPressed: () => widget.onDecline?.call(),
                    child: const Text('Not you? Decline the invitation'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
