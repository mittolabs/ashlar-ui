// Ashlar UI block: wallet-01. Copied into your app by `ashlar add wallet-01`; it is yours to
// change. A wallet: the balance, what to do with it, and where the money went.

import 'package:ashlar_icons/ashlar_icons.dart';
import 'package:flutter/widgets.dart';

import '../ui/avatar.dart';
import '../ui/button.dart';
import '../ui/pressable.dart';
import '../ui/sparkline.dart';
import '../ui/theme.dart';

/// One movement of money: in when [amount] is above nought, out when below.
class WalletEntry {
  const WalletEntry(this.who, this.what, this.when, this.amount);

  final String who, what, when;
  final double amount;
}

/// A wallet: the balance, hidden at a tap, how it went this month, the four things people
/// do with it, and what came in and went out. Side by side on a wide screen, one under the
/// other on a phone.
class Wallet01 extends StatefulWidget {
  const Wallet01({
    super.key,
    this.balance = 24350,
    this.currency = 'KES',
    this.history = const [18200, 21400, 19850, 22600, 20100, 23900, 24350],
    this.entries = _entries,
    this.onSend,
    this.onRequest,
    this.onPay,
    this.onTopUp,
    this.onEntry,
    this.onSeeAll,
  });

  final double balance;
  final String currency;

  /// The balance over the month, oldest first.
  final List<double> history;
  final List<WalletEntry> entries;
  final VoidCallback? onSend, onRequest, onPay, onTopUp;
  final ValueChanged<WalletEntry>? onEntry;
  final VoidCallback? onSeeAll;

  @override
  State<Wallet01> createState() => _Wallet01State();
}

const _entries = [
  WalletEntry('Wanjiru Kamau', 'Sent to you', 'Today, 10:42', 2500),
  WalletEntry('Kenya Power', 'Bill, account 4410 2201', 'Today, 08:15', -3200),
  WalletEntry('Naivas Westlands', 'Groceries', 'Yesterday, 18:30', -1840),
  WalletEntry('Otieno Mwangi', 'You sent', 'Yesterday, 12:05', -1000),
  WalletEntry('Salary', 'Mittolabs', '20 October', 85000),
];

/// 24350 as "24,350.00".
String _money(double v) {
  final whole = v.abs().truncate().toString();
  final cents = ((v.abs() - v.abs().truncate()) * 100)
      .round()
      .toString()
      .padLeft(2, '0');
  final grouped = whole.replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );
  return '$grouped.$cents';
}

class _Wallet01State extends State<Wallet01> {
  bool _hidden = false;

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    final c = t.colors;
    final first = widget.history.isEmpty
        ? widget.balance
        : widget.history.first;
    final change = first == 0 ? 0.0 : (widget.balance - first) / first * 100;

    final balance = Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: c.primary,
        borderRadius: BorderRadius.circular(t.radiusXl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Balance',
                  style: t.text.sm.copyWith(
                    color: c.primaryForeground.withValues(alpha: .7),
                  ),
                ),
              ),
              Pressable(
                onPressed: () => setState(() => _hidden = !_hidden),
                semanticLabel: _hidden
                    ? 'Show the balance'
                    : 'Hide the balance',
                builder: (context, state) => Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: c.primaryForeground.withValues(
                      alpha: state.hovered ? .12 : 0,
                    ),
                    borderRadius: BorderRadius.circular(t.radiusSm),
                    border: Border.all(
                      color: state.focused
                          ? c.primaryForeground
                          : c.primaryForeground.withValues(alpha: 0),
                    ),
                  ),
                  child: AshlarIcon(
                    _hidden
                        ? AshlarIconsRoundedStroke.eyeOff
                        : AshlarIconsRoundedStroke.eye,
                    size: 16,
                    color: c.primaryForeground.withValues(alpha: .8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Semantics(
            label: _hidden
                ? 'Balance hidden'
                : '${widget.currency} ${_money(widget.balance)}',
            excludeSemantics: true,
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '${widget.currency} ',
                    style: t.text.lg.copyWith(
                      color: c.primaryForeground.withValues(alpha: .7),
                    ),
                  ),
                  TextSpan(
                    text: _hidden ? '••••••' : _money(widget.balance),
                    style: t.text.xxl.copyWith(
                      color: c.primaryForeground,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -.8,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${change >= 0 ? '+' : ''}${change.toStringAsFixed(1)}% this month',
            style: t.text.xs.copyWith(
              color: c.primaryForeground.withValues(alpha: .7),
            ),
          ),
          const SizedBox(height: 14),
          if (widget.history.length > 1)
            Sparkline(
              values: widget.history,
              kind: SparkKind.area,
              height: 44,
              color: c.primaryForeground,
              trackball: false,
              semanticLabel: 'The balance over the month',
            ),
        ],
      ),
    );

    Widget action(IconData icon, String label, VoidCallback? onPressed) =>
        Expanded(
          child: Pressable(
            onPressed: onPressed,
            semanticLabel: label,
            builder: (context, state) => AnimatedContainer(
              duration: t.duration,
              // Its share of the row, even inside a finger-sized press area.
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: state.hovered ? c.accent : c.background,
                borderRadius: BorderRadius.circular(t.radiusLg),
                border: Border.all(color: state.focused ? c.ring : c.border),
              ),
              child: Column(
                children: [
                  AshlarIcon(icon, size: 20, color: c.foreground),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    style: t.text.xs.copyWith(
                      color: c.foreground,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

    final actions = Row(
      children: [
        action(AshlarIconsRoundedStroke.arrowUpRight, 'Send', widget.onSend),
        const SizedBox(width: 8),
        action(
          AshlarIconsRoundedStroke.arrowDownLeft,
          'Request',
          widget.onRequest,
        ),
        const SizedBox(width: 8),
        action(AshlarIconsRoundedStroke.receipt, 'Pay', widget.onPay),
        const SizedBox(width: 8),
        action(AshlarIconsRoundedStroke.plus, 'Top up', widget.onTopUp),
      ],
    );

    final activity = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Activity',
                style: t.text.base.copyWith(
                  color: c.foreground,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Button(
              variant: ButtonVariant.ghost,
              size: ButtonSize.sm,
              onPressed: widget.onSeeAll,
              child: const Text('See all'),
            ),
          ],
        ),
        const SizedBox(height: 4),
        for (final e in widget.entries)
          Pressable(
            onPressed: widget.onEntry == null ? null : () => widget.onEntry!(e),
            semanticLabel:
                '${e.who}, ${e.what}, ${e.when}, ${e.amount >= 0 ? 'in' : 'out'} ${widget.currency} ${_money(e.amount)}',
            builder: (context, state) => AnimatedContainer(
              duration: t.duration,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              decoration: BoxDecoration(
                color: state.hovered && widget.onEntry != null
                    ? c.accent
                    : c.accent.withValues(alpha: 0),
                borderRadius: BorderRadius.circular(t.radiusMd),
                border: Border.all(
                  color: state.focused ? c.ring : c.ring.withValues(alpha: 0),
                ),
              ),
              child: Row(
                children: [
                  Avatar(
                    fallback: e.who.split(' ').take(2).map((w) => w[0]).join(),
                    size: 36,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          e.who,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: t.text.sm.copyWith(
                            color: c.foreground,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${e.what} · ${e.when}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: t.text.xs.copyWith(color: c.mutedForeground),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${e.amount >= 0 ? '+' : '−'}${_money(e.amount)}',
                    style: t.text.sm.copyWith(
                      color: e.amount >= 0 ? c.foreground : c.mutedForeground,
                      fontWeight: FontWeight.w600,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );

    return ColoredBox(
      color: c.background,
      child: LayoutBuilder(
        builder: (context, box) {
          final wide = box.maxWidth >= 860;
          final pad = wide ? 32.0 : 16.0;
          return SingleChildScrollView(
            padding: EdgeInsets.all(pad),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: wide ? 1040 : 520),
                child: wide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 380,
                            child: Column(
                              children: [
                                balance,
                                const SizedBox(height: 16),
                                actions,
                              ],
                            ),
                          ),
                          const SizedBox(width: 40),
                          Expanded(child: activity),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          balance,
                          const SizedBox(height: 16),
                          actions,
                          const SizedBox(height: 24),
                          activity,
                        ],
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}
