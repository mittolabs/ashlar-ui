import 'package:ashlar_icons/ashlar_icons.dart';
import 'package:flutter/widgets.dart';

import 'ui/alert.dart';
import 'ui/app.dart';
import 'ui/avatar.dart';
import 'ui/badge.dart';
import 'ui/button.dart';
import 'ui/card.dart';
import 'ui/checkbox.dart';
import 'ui/dialog.dart';
import 'ui/dropdown_menu.dart';
import 'ui/field.dart';
import 'ui/input.dart';
import 'ui/kbd.dart';
import 'ui/popover.dart';
import 'ui/radio.dart';
import 'ui/select.dart';
import 'ui/separator.dart';
import 'ui/skeleton.dart';
import 'ui/spinner.dart';
import 'ui/switch.dart';
import 'ui/tabs.dart';
import 'ui/textarea.dart';
import 'ui/theme.dart';
import 'ui/toast.dart';
import 'ui/tooltip.dart';

void main() => runApp(const Gallery());

/// Every Ashlar UI component in every state, from the files `ashlar add --all` copied
/// into lib/ui, exactly as an app gets them.
class Gallery extends StatefulWidget {
  const Gallery({super.key});

  @override
  State<Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> {
  AshlarThemeMode mode = AshlarThemeMode.light;

  @override
  Widget build(BuildContext context) => AshlarApp(
    title: 'Ashlar UI',
    themeMode: mode,
    home: GalleryPage(
      dark: mode == AshlarThemeMode.dark,
      onDark: (v) => setState(
        () => mode = v ? AshlarThemeMode.dark : AshlarThemeMode.light,
      ),
    ),
  );
}

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key, required this.dark, required this.onDark});

  final bool dark;
  final ValueChanged<bool> onDark;

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  bool terms = true, news = false, notify = true, wifi = false;
  String? result, county, plan = 'monthly';

  Widget section(String title, Widget body) {
    final t = AshlarTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: t.text.lg.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          body,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 48),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text('Ashlar UI', style: t.text.xxl)),
                  Text(
                    'Dark',
                    style: TextStyle(color: t.colors.mutedForeground),
                  ),
                  const SizedBox(width: 8),
                  Switch(
                    value: widget.dark,
                    onChanged: widget.onDark,
                    semanticLabel: 'Dark theme',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Components on the widgets layer, copied into your app.',
                style: t.text.base.copyWith(color: t.colors.mutedForeground),
              ),
              const SizedBox(height: 40),
              section(
                'Button',
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Button(onPressed: () {}, child: const Text('Primary')),
                    Button(
                      variant: ButtonVariant.secondary,
                      onPressed: () {},
                      child: const Text('Secondary'),
                    ),
                    Button(
                      variant: ButtonVariant.outline,
                      onPressed: () {},
                      child: const Text('Outline'),
                    ),
                    Button(
                      variant: ButtonVariant.ghost,
                      onPressed: () {},
                      child: const Text('Ghost'),
                    ),
                    Button(
                      variant: ButtonVariant.destructive,
                      onPressed: () {},
                      child: const Text('Delete'),
                    ),
                    Button(
                      variant: ButtonVariant.link,
                      onPressed: () {},
                      child: const Text('Link'),
                    ),
                    Button(
                      size: ButtonSize.sm,
                      leading: const AshlarIcon(AshlarIconsRoundedStroke.plus),
                      onPressed: () {},
                      child: const Text('Small'),
                    ),
                    Button(
                      size: ButtonSize.lg,
                      trailing: const AshlarIcon(
                        AshlarIconsRoundedStroke.arrowRight,
                      ),
                      onPressed: () {},
                      child: const Text('Large'),
                    ),
                    Button(
                      size: ButtonSize.icon,
                      variant: ButtonVariant.outline,
                      semanticLabel: 'Settings',
                      onPressed: () {},
                      child: const AshlarIcon(
                        AshlarIconsRoundedStroke.settings,
                      ),
                    ),
                    const Button(onPressed: null, child: Text('Disabled')),
                  ],
                ),
              ),
              section(
                'Badge',
                const Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Badge(child: Text('New')),
                    Badge(
                      variant: BadgeVariant.secondary,
                      child: Text('Draft'),
                    ),
                    Badge(
                      variant: BadgeVariant.destructive,
                      child: Text('Overdue'),
                    ),
                    Badge(
                      variant: BadgeVariant.outline,
                      leading: AshlarIcon(AshlarIconsRoundedStroke.check),
                      child: Text('Paid'),
                    ),
                  ],
                ),
              ),
              section(
                'Input',
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Input(
                      placeholder: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      leading: AshlarIcon(AshlarIconsRoundedStroke.mail),
                    ),
                    const SizedBox(height: 12),
                    const Input(
                      placeholder: 'Password',
                      obscureText: true,
                      error: true,
                    ),
                    const SizedBox(height: 12),
                    const Input(placeholder: 'Disabled', enabled: false),
                    const SizedBox(height: 12),
                    const Input(
                      placeholder: 'A longer message, over several lines',
                      maxLines: 4,
                    ),
                  ],
                ),
              ),
              section(
                'Checkbox and switch',
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: terms,
                          onChanged: (v) => setState(() => terms = v),
                          semanticLabel: 'Accept the terms',
                        ),
                        const SizedBox(width: 8),
                        const Text('Accept the terms'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Checkbox(
                          value: news,
                          onChanged: (v) => setState(() => news = v),
                          semanticLabel: 'Send me news',
                        ),
                        const SizedBox(width: 8),
                        const Text('Send me news'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Row(
                      children: [
                        Checkbox(value: true, onChanged: null),
                        SizedBox(width: 8),
                        Text('Disabled'),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Switch(
                          value: notify,
                          onChanged: (v) => setState(() => notify = v),
                          semanticLabel: 'Notifications',
                        ),
                        const SizedBox(width: 8),
                        const Text('Notifications'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Switch(
                          value: wifi,
                          onChanged: (v) => setState(() => wifi = v),
                          semanticLabel: 'Wi-Fi',
                        ),
                        const SizedBox(width: 8),
                        const Text('Wi-Fi'),
                      ],
                    ),
                  ],
                ),
              ),
              section(
                'Card',
                Card(
                  children: [
                    CardHeader(
                      title: const Text('Send money'),
                      description: const Text(
                        'To a phone number or a bank account.',
                      ),
                      action: const Badge(
                        variant: BadgeVariant.secondary,
                        child: Text('KES'),
                      ),
                    ),
                    const CardContent(
                      child: Input(
                        placeholder: 'Phone number',
                        leading: AshlarIcon(AshlarIconsRoundedStroke.phone),
                      ),
                    ),
                    CardFooter(
                      alignment: MainAxisAlignment.end,
                      children: [
                        Button(
                          variant: ButtonVariant.outline,
                          onPressed: () {},
                          child: const Text('Cancel'),
                        ),
                        Button(onPressed: () {}, child: const Text('Continue')),
                      ],
                    ),
                  ],
                ),
              ),
              section(
                'Separator',
                SizedBox(
                  height: 20,
                  child: Row(
                    children: [
                      const Text('Profile'),
                      const SizedBox(width: 12),
                      const Separator(axis: Axis.vertical),
                      const SizedBox(width: 12),
                      Text(
                        'Settings',
                        style: TextStyle(color: t.colors.mutedForeground),
                      ),
                    ],
                  ),
                ),
              ),
              section(
                'Field, Textarea and Select',
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Field(
                      label: Text('Email'),
                      description: Text('We send receipts here.'),
                      child: Input(placeholder: 'you@solutech.co.ke'),
                    ),
                    const SizedBox(height: 20),
                    Field(
                      label: const Text('County'),
                      error: county == null
                          ? const Text('Choose a county')
                          : null,
                      child: Select<String>(
                        value: county,
                        placeholder: 'Choose a county',
                        error: county == null,
                        options: const [
                          SelectOption('nbo', 'Nairobi'),
                          SelectOption('msa', 'Mombasa'),
                          SelectOption('ksm', 'Kisumu'),
                          SelectOption('nku', 'Nakuru'),
                        ],
                        onChanged: (v) => setState(() => county = v),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Field(
                      label: Text('Note'),
                      child: Textarea(placeholder: 'Tell us what happened'),
                    ),
                  ],
                ),
              ),
              section(
                'Radio',
                RadioGroup<String>(
                  groupValue: plan,
                  onChanged: (v) => setState(() => plan = v),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Radio(
                        value: 'monthly',
                        label: Text('Monthly'),
                        description: Text('KES 500 a month.'),
                      ),
                      SizedBox(height: 12),
                      Radio(
                        value: 'yearly',
                        label: Text('Yearly'),
                        description: Text('Two months free.'),
                      ),
                      SizedBox(height: 12),
                      Radio(value: 'team', label: Text('Team'), enabled: false),
                    ],
                  ),
                ),
              ),
              section(
                'Tabs',
                const Tabs(
                  tabs: [
                    TabItem(
                      label: Text('Account'),
                      content: Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text('Change your name and email.'),
                      ),
                    ),
                    TabItem(
                      label: Text('Password'),
                      content: Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text('Change your password.'),
                      ),
                    ),
                    TabItem(
                      label: Text('Billing'),
                      content: SizedBox(),
                      enabled: false,
                    ),
                  ],
                ),
              ),
              section(
                'Dropdown menu, popover and tooltip',
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    DropdownMenu(
                      builder: (context, menu) => Button(
                        variant: ButtonVariant.outline,
                        trailing: const AshlarIcon(
                          AshlarIconsRoundedStroke.chevronDown,
                        ),
                        onPressed: () =>
                            menu.isOpen ? menu.close() : menu.open(),
                        child: const Text('My account'),
                      ),
                      items: [
                        const MenuLabel(child: Text('My account')),
                        MenuItem(
                          leading: const AshlarIcon(
                            AshlarIconsRoundedStroke.user,
                          ),
                          shortcut: const Text('⇧⌘P'),
                          onPressed: () {},
                          child: const Text('Profile'),
                        ),
                        MenuItem(
                          leading: const AshlarIcon(
                            AshlarIconsRoundedStroke.creditCard,
                          ),
                          onPressed: () {},
                          child: const Text('Billing'),
                        ),
                        MenuItem(
                          leading: const AshlarIcon(
                            AshlarIconsRoundedStroke.settings,
                          ),
                          shortcut: const Text('⌘,'),
                          onPressed: () {},
                          child: const Text('Settings'),
                        ),
                        const MenuSeparator(),
                        MenuItem(
                          leading: const AshlarIcon(
                            AshlarIconsRoundedStroke.logOut,
                          ),
                          destructive: true,
                          onPressed: () {},
                          child: const Text('Sign out'),
                        ),
                      ],
                    ),
                    Popover(
                      builder: (context, menu) => Button(
                        variant: ButtonVariant.outline,
                        onPressed: () =>
                            menu.isOpen ? menu.close() : menu.open(),
                        child: const Text('Dimensions'),
                      ),
                      content: (context) => const Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('Set the size of the layer.'),
                          SizedBox(height: 12),
                          Field(
                            label: Text('Width'),
                            child: Input(placeholder: '100%'),
                          ),
                        ],
                      ),
                    ),
                    Tooltip(
                      message: 'Add to library',
                      child: Button(
                        size: ButtonSize.icon,
                        variant: ButtonVariant.outline,
                        semanticLabel: 'Add',
                        onPressed: () {},
                        child: const AshlarIcon(AshlarIconsRoundedStroke.plus),
                      ),
                    ),
                  ],
                ),
              ),
              section(
                'Toast',
                Button(
                  variant: ButtonVariant.outline,
                  onPressed: () => showToast(
                    context,
                    title: 'Payment sent',
                    description: 'KES 2,400 to Wanjiru Mwangi.',
                    action: Button(
                      size: ButtonSize.sm,
                      onPressed: () {},
                      child: const Text('Undo'),
                    ),
                  ),
                  child: const Text('Show a toast'),
                ),
              ),
              section(
                'Alert',
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Alert(
                      icon: AshlarIcon(AshlarIconsRoundedStroke.circleCheck),
                      title: Text('Payment received'),
                      description: Text('KES 2,400 from 0712 345 678.'),
                    ),
                    SizedBox(height: 12),
                    Alert(
                      variant: AlertVariant.destructive,
                      icon: AshlarIcon(AshlarIconsRoundedStroke.circleAlert),
                      title: Text('The card was declined'),
                      description: Text(
                        'Try another card or pay by mobile money.',
                      ),
                    ),
                  ],
                ),
              ),
              section(
                'Avatar, skeleton, spinner and kbd',
                Wrap(
                  spacing: 24,
                  runSpacing: 16,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Avatar(fallback: 'WM', semanticLabel: 'Wanjiru Mwangi'),
                        SizedBox(width: 8),
                        Avatar(fallback: 'OK', size: 40),
                      ],
                    ),
                    const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Skeleton(width: 40, height: 40, circle: true),
                        SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Skeleton(width: 160),
                            SizedBox(height: 8),
                            Skeleton(width: 120),
                          ],
                        ),
                      ],
                    ),
                    const Button(
                      onPressed: null,
                      leading: Spinner(),
                      child: Text('Saving'),
                    ),
                    Kbd.group(const [
                      Kbd(child: Text('⌘')),
                      Kbd(child: Text('K')),
                    ]),
                  ],
                ),
              ),
              section(
                'Dialog',
                Row(
                  children: [
                    Button(
                      variant: ButtonVariant.outline,
                      onPressed: () async {
                        final ok = await showAshlarDialog<bool>(
                          context: context,
                          builder: (context) => Dialog(
                            title: const Text('Delete the file?'),
                            description: const Text(
                              'This cannot be undone. The file and its history will be removed.',
                            ),
                            actions: [
                              Button(
                                variant: ButtonVariant.outline,
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              Button(
                                variant: ButtonVariant.destructive,
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                        setState(
                          () => result = ok == null
                              ? 'Closed'
                              : (ok ? 'Deleted' : 'Cancelled'),
                        );
                      },
                      child: const Text('Open dialog'),
                    ),
                    const SizedBox(width: 12),
                    if (result != null)
                      Text(
                        result!,
                        style: TextStyle(color: t.colors.mutedForeground),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
