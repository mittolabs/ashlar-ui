// Ashlar UI block: account-picker. Copied into your app by `ashlar add account-picker`; it
// is yours to change. Welcome back: the accounts used on this device to continue as with a
// tap, and other ways in under them.
//
// The accounts are sample data; signing in is yours.

import 'package:ashlar_icons/ashlar_icons.dart';
import 'package:flutter/widgets.dart';

import '../ui/avatar.dart';
import '../ui/button.dart';
import '../ui/card.dart';
import '../ui/pressable.dart';
import '../ui/separator.dart';
import '../ui/theme.dart';

/// An account used on this device before.
class KnownAccount {
  const KnownAccount(this.name, this.detail);

  final String name;

  /// What tells it apart: its email, its business, its role.
  final String detail;
}

/// The accounts to continue as, and other ways in.
class AccountPicker extends StatelessWidget {
  const AccountPicker({
    super.key,
    this.accounts = const [
      KnownAccount('Lucía Fernández', 'Personal'),
      KnownAccount('Lucía Fernández', 'Fernández Hardware, owner'),
      KnownAccount('Kenji Sato', 'Shared tablet'),
    ],
    this.onContinue,
    this.onRemove,
    this.onGoogle,
    this.onApple,
    this.onEmail,
  });

  final List<KnownAccount> accounts;
  final ValueChanged<KnownAccount>? onContinue, onRemove;
  final VoidCallback? onGoogle, onApple, onEmail;

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
            child: Card(
              children: [
                const CardHeader(
                  title: Text('Welcome back'),
                  description: Text('Choose an account to carry on with.'),
                ),
                CardContent(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final account in accounts)
                        Pressable(
                          onPressed: onContinue == null
                              ? null
                              : () => onContinue!(account),
                          semanticLabel:
                              'Continue as ${account.name}, ${account.detail}',
                          builder: (context, state) => Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: state.hovered ? c.accent : null,
                              borderRadius: BorderRadius.circular(t.radiusLg),
                              border: Border.all(
                                color: state.focused ? c.ring : c.border,
                              ),
                            ),
                            child: Row(
                              children: [
                                Avatar(
                                  fallback: account.name
                                      .split(' ')
                                      .map((w) => w[0])
                                      .join(),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        account.name,
                                        overflow: TextOverflow.ellipsis,
                                        style: t.text.sm.copyWith(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        account.detail,
                                        overflow: TextOverflow.ellipsis,
                                        style: t.text.xs.copyWith(
                                          color: c.mutedForeground,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Button(
                                  variant: ButtonVariant.ghost,
                                  size: ButtonSize.iconSm,
                                  semanticLabel:
                                      'Forget ${account.name}, ${account.detail}',
                                  onPressed: onRemove == null
                                      ? null
                                      : () => onRemove!(account),
                                  child: const AshlarIcon(
                                    AshlarIconsRoundedStroke.x,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Expanded(child: Separator()),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              'Or another account',
                              style: t.text.xs.copyWith(
                                color: c.mutedForeground,
                              ),
                            ),
                          ),
                          const Expanded(child: Separator()),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Button(
                              variant: ButtonVariant.outline,
                              expand: true,
                              leading: const AshlarIcon(
                                AshlarIconsRoundedStroke.brandGoogle,
                              ),
                              onPressed: () => onGoogle?.call(),
                              child: const Text('Google'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Button(
                              variant: ButtonVariant.outline,
                              expand: true,
                              leading: const AshlarIcon(
                                AshlarIconsRoundedStroke.brandApple,
                              ),
                              onPressed: () => onApple?.call(),
                              child: const Text('Apple'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Button(
                        variant: ButtonVariant.ghost,
                        expand: true,
                        leading: const AshlarIcon(
                          AshlarIconsRoundedStroke.mail,
                        ),
                        onPressed: () => onEmail?.call(),
                        child: const Text('Use an email address'),
                      ),
                    ],
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
