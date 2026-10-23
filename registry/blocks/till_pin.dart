// Ashlar UI block: till-pin. Copied into your app by `ashlar add till-pin`; it is yours to
// change. A shared till's lock screen: whoever is serving picks themselves and enters
// their four-digit PIN on a keypad, as on a counter's tablet.
//
// Checking the PIN is yours: onUnlock. The staff are sample data.

import 'package:ashlar_icons/ashlar_icons.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../ui/avatar.dart';
import '../ui/button.dart';
import '../ui/pressable.dart';
import '../ui/theme.dart';

/// The till's lock screen: who is serving, then their PIN.
class TillPin extends StatefulWidget {
  const TillPin({
    super.key,
    this.staff = const ['Rosa Delgado', 'Marcus Reed', 'Achieng Otieno'],
    this.onUnlock,
  });

  final List<String> staff;

  /// Told who and their PIN once four digits are in. Answer whether it was right: a
  /// wrong PIN is cleared and said so.
  final bool Function(String who, String pin)? onUnlock;

  @override
  State<TillPin> createState() => _TillPinState();
}

class _TillPinState extends State<TillPin> {
  var _who = 0;
  var _pin = '';
  var _wrong = false;

  void _press(String digit) {
    if (_pin.length == 4) return;
    setState(() {
      _wrong = false;
      _pin += digit;
    });
    if (_pin.length == 4) {
      final right = widget.onUnlock?.call(widget.staff[_who], _pin) ?? true;
      if (!right) {
        HapticFeedback.heavyImpact();
        setState(() {
          _pin = '';
          _wrong = true;
        });
      }
    }
  }

  void _back() {
    if (_pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    final c = t.colors;
    final initials = [
      for (final name in widget.staff) name.split(' ').map((w) => w[0]).join(),
    ];
    Widget key(Widget child, VoidCallback onPressed, String label) => Pressable(
      onPressed: onPressed,
      semanticLabel: label,
      builder: (context, state) => AnimatedContainer(
        duration: t.duration,
        width: 72,
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: state.pressed
              ? c.accent
              : state.hovered
              ? c.muted
              : c.background,
          borderRadius: BorderRadius.circular(t.radiusLg),
          border: Border.all(color: state.focused ? c.ring : c.border),
        ),
        child: child,
      ),
    );
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Column(
            children: [
              Text(
                'Who is serving?',
                style: t.text.lg.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  for (final (i, name) in widget.staff.indexed)
                    Pressable(
                      onPressed: () => setState(() {
                        _who = i;
                        _pin = '';
                        _wrong = false;
                      }),
                      selected: i == _who,
                      semanticLabel: name,
                      builder: (context, state) => Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                width: 2,
                                color: i == _who
                                    ? c.primary
                                    : c.primary.withValues(alpha: 0),
                              ),
                            ),
                            child: Avatar(fallback: initials[i], size: 48),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            name.split(' ').first,
                            style: t.text.xs.copyWith(
                              color: i == _who
                                  ? c.foreground
                                  : c.mutedForeground,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 28),
              Semantics(
                label: 'PIN',
                value: '${_pin.length} of 4 digits',
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 0; i < 4; i++)
                      AnimatedContainer(
                        duration: t.duration,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i < _pin.length ? c.foreground : null,
                          border: Border.all(
                            color: _wrong ? c.destructive : c.foreground,
                            width: 1.5,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 20,
                child: _wrong
                    ? Text(
                        'That PIN is not right. Try again.',
                        style: t.text.sm.copyWith(color: c.destructive),
                      )
                    : null,
              ),
              const SizedBox(height: 12),
              for (final row in const [
                ['1', '2', '3'],
                ['4', '5', '6'],
                ['7', '8', '9'],
              ])
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      for (final d in row)
                        key(Text(d, style: t.text.xl), () => _press(d), d),
                    ],
                  ),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const SizedBox(width: 72),
                  key(Text('0', style: t.text.xl), () => _press('0'), '0'),
                  key(
                    const AshlarIcon(AshlarIconsRoundedStroke.delete),
                    _back,
                    'Delete a digit',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Button(
                variant: ButtonVariant.link,
                onPressed: () {},
                child: const Text('Forgot your PIN? Ask the owner'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
