// Ashlar UI block: shop-settings. Copied into your app by `ashlar add shop-settings`; it is
// yours to change. A shop's settings in a dialog: their sections down its side (a list to
// pick from on a phone), the open one's settings beside them.
//
// The shop and its settings are sample data, there to be replaced.

import 'package:ashlar_icons/ashlar_icons.dart';
import 'package:flutter/widgets.dart';

import '../ui/button.dart';
import '../ui/dialog.dart';
import '../ui/field.dart';
import '../ui/input.dart';
import '../ui/select.dart';
import '../ui/separator.dart';
import '../ui/switch.dart';
import '../ui/theme.dart';

/// One setting: words to type, one of a few choices, or on and off.
sealed class _Setting {
  const _Setting(this.label, [this.hint]);

  final String label;
  final String? hint;
}

class _Words extends _Setting {
  const _Words(super.label, this.value, [super.hint]);

  final String value;
}

class _Choice extends _Setting {
  const _Choice(super.label, this.value, this.options, [super.hint]);

  final String value;
  final List<String> options;
}

class _Toggle extends _Setting {
  const _Toggle(super.label, this.on, [super.hint]);

  final bool on;
}

/// The settings' sections: a name, an icon, what the section is for, and its settings.
const _sections = [
  (
    'Shop',
    AshlarIconsRoundedStroke.store,
    'What customers see, and when you are open.',
    <_Setting>[
      _Words('Shop name', 'Corner Pantry'),
      _Words('Address', '14 Elm Street'),
      _Words('Opening hours', '7:00 to 20:00', 'Shown on receipts and online.'),
      _Toggle('Open on Sundays', true),
    ],
  ),
  (
    'Payments',
    AshlarIconsRoundedStroke.creditCard,
    'How customers pay you, and what happens after.',
    <_Setting>[
      _Words(
        'Payout account',
        '•••• 4410',
        'The bank account card payments go to each day.',
      ),
      _Words('Name on card statements', 'CORNER PANTRY'),
      _Toggle(
        'Ask for the owner\'s PIN to refund',
        true,
        'Staff cannot send money back on their own.',
      ),
    ],
  ),
  (
    'Receipts',
    AshlarIconsRoundedStroke.receipt,
    'What goes on a receipt, and how it reaches the customer.',
    <_Setting>[
      _Words('A line at the foot', 'Thank you for shopping with us.'),
      _Toggle('Print one for every sale', false),
      _Toggle(
        'Send one by SMS',
        true,
        'The customer gets the items and total on their phone.',
      ),
      _Toggle('Show the tax on each line', true),
    ],
  ),
  (
    'Staff',
    AshlarIconsRoundedStroke.users,
    'What the people at the till can do.',
    <_Setting>[
      _Toggle('Sign in at the till with a PIN', true),
      _Toggle('Give discounts', true),
      _Choice('Largest discount', '10%', [
        '5%',
        '10%',
        '20%',
      ], 'On any one sale.'),
    ],
  ),
  (
    'Stock alerts',
    AshlarIconsRoundedStroke.bell,
    'When to warn you that something is running low.',
    <_Setting>[
      _Words('Warn when an item falls to', '5', 'Counted in units.'),
      _Toggle('Email a list each morning', true),
      _Toggle('Warn a week before a use-by date', false),
    ],
  ),
  (
    'Delivery',
    AshlarIconsRoundedStroke.bike,
    'Orders taken to the door.',
    <_Setting>[
      _Words('Delivery fee', '\$3.50'),
      _Words('Free over', '\$40.00'),
      _Toggle('Pay on delivery', false, 'Drivers can take a card at the door.'),
    ],
  ),
  (
    'Language',
    AshlarIconsRoundedStroke.globe,
    'How the till and the receipts read.',
    <_Setting>[
      _Choice('Language', 'English', [
        'English',
        'Español',
        'Français',
        'Kiswahili',
        'Português',
      ]),
      _Choice('Currency', 'USD', ['USD', 'EUR', 'GBP', 'KES', 'INR']),
      _Choice('Dates', 'July 2, 2026', [
        'July 2, 2026',
        '2 July 2026',
        '2026-07-02',
      ]),
    ],
  ),
];

/// A page with a button that opens the shop's settings.
class ShopSettings extends StatelessWidget {
  const ShopSettings({super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: Button(
      variant: ButtonVariant.outline,
      leading: const AshlarIcon(AshlarIconsRoundedStroke.settings),
      onPressed: () => showAshlarDialog<void>(
        context: context,
        builder: (context) => const Dialog(maxWidth: 800, content: _Settings()),
      ),
      child: const Text('Shop settings'),
    ),
  );
}

/// The settings: sections down the side where there is room, the open one beside them.
class _Settings extends StatefulWidget {
  const _Settings();

  @override
  State<_Settings> createState() => _SettingsState();
}

class _SettingsState extends State<_Settings> {
  var _section = 'Payments';

  // What each setting holds now, by its section and label.
  final _words = <String, TextEditingController>{
    for (final (name, _, _, settings) in _sections)
      for (final s in settings.whereType<_Words>())
        '$name/${s.label}': TextEditingController(text: s.value),
  };
  final _choices = <String, String>{
    for (final (name, _, _, settings) in _sections)
      for (final s in settings.whereType<_Choice>())
        '$name/${s.label}': s.value,
  };
  final _toggles = <String, bool>{
    for (final (name, _, _, settings) in _sections)
      for (final s in settings.whereType<_Toggle>()) '$name/${s.label}': s.on,
  };

  @override
  void dispose() {
    for (final c in _words.values) {
      c.dispose();
    }
    super.dispose();
  }

  Widget _setting(BuildContext context, _Setting s) {
    final t = AshlarTheme.of(context);
    final c = t.colors;
    final key = '$_section/${s.label}';
    final hint = s.hint == null ? null : Text(s.hint!);
    return switch (s) {
      _Words() => Field(
        label: Text(s.label),
        description: hint,
        child: Input(controller: _words[key], semanticLabel: s.label),
      ),
      _Choice(:final options) => Field(
        label: Text(s.label),
        description: hint,
        child: Select<String>(
          value: _choices[key],
          semanticLabel: s.label,
          options: [for (final o in options) SelectOption(o, o)],
          onChanged: (v) => setState(() => _choices[key] = v),
        ),
      ),
      _Toggle() => Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.label,
                  style: t.text.sm.copyWith(fontWeight: FontWeight.w500),
                ),
                if (s.hint != null)
                  Text(
                    s.hint!,
                    style: t.text.sm.copyWith(color: c.mutedForeground),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Switch(
            value: _toggles[key]!,
            semanticLabel: s.label,
            onChanged: (v) => setState(() => _toggles[key] = v),
          ),
        ],
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    final c = t.colors;
    final wide = MediaQuery.sizeOf(context).width >= 768;
    final (_, _, about, settings) = _sections.firstWhere(
      (s) => s.$1 == _section,
    );
    final heading = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!wide) ...[
          Select<String>(
            value: _section,
            semanticLabel: 'Section',
            options: [
              for (final (name, _, _, _) in _sections) SelectOption(name, name),
            ],
            onChanged: (v) => setState(() => _section = v),
          ),
          const SizedBox(height: 16),
        ],
        Text(_section, style: t.text.lg.copyWith(fontWeight: FontWeight.w600)),
        Text(about, style: t.text.sm.copyWith(color: c.mutedForeground)),
        const SizedBox(height: 16),
        const Separator(),
      ],
    );
    final fields = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        for (final (i, s) in settings.indexed) ...[
          if (i > 0) const SizedBox(height: 20),
          _setting(context, s),
        ],
        const SizedBox(height: 16),
      ],
    );
    final actions = Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Button(
          variant: ButtonVariant.outline,
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        const SizedBox(width: 8),
        Button(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Save'),
        ),
      ],
    );
    if (!wide) {
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [heading, fields, actions],
        ),
      );
    }
    // A fixed height, so the dialog keeps its size from section to section: the
    // fields scroll between the heading and the actions.
    return SizedBox(
      height: 520,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 200,
            child: ListView(
              children: [
                for (final (name, icon, _, _) in _sections)
                  Button(
                    variant: name == _section
                        ? ButtonVariant.secondary
                        : ButtonVariant.ghost,
                    size: ButtonSize.sm,
                    expand: true,
                    leading: AshlarIcon(icon),
                    onPressed: () => setState(() => _section = name),
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(name, overflow: TextOverflow.ellipsis),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                heading,
                Expanded(child: SingleChildScrollView(child: fields)),
                actions,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
