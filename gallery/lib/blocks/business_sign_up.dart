// Ashlar UI block: business-sign-up. Copied into your app by `ashlar add business-sign-up`;
// it is yours to change. Open an account for a business: its name, what kind it is, its tax
// number, and a way to reach it. On a wide screen what the account gives sits beside the form.
//
// The product and what it gives are sample content; opening the account is yours.

import 'package:ashlar_icons/ashlar_icons.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../ui/button.dart';
import '../ui/form.dart';
import '../ui/select.dart';
import '../ui/theme.dart';

/// What the business signs up as.
class BusinessDetails {
  const BusinessDetails({
    required this.name,
    required this.kind,
    required this.taxNumber,
    required this.phone,
    required this.email,
  });

  final String name, kind, taxNumber, phone, email;
}

/// A business sign-up beside what the account gives.
class BusinessSignUp extends StatefulWidget {
  const BusinessSignUp({super.key, this.onSignUp, this.onSignIn});

  /// Told the details once each is right.
  final ValueChanged<BusinessDetails>? onSignUp;
  final VoidCallback? onSignIn;

  @override
  State<BusinessSignUp> createState() => _BusinessSignUpState();
}

class _BusinessSignUpState extends State<BusinessSignUp> {
  final _form = GlobalKey<FormState>();
  var _name = '', _kind = '', _tax = '', _phone = '', _email = '';

  static const _kinds = [
    'Shop',
    'Restaurant',
    'Pharmacy',
    'Salon',
    'Something else',
  ];

  void _send() {
    if (!_form.currentState!.submit()) return;
    widget.onSignUp?.call(
      BusinessDetails(
        name: _name.trim(),
        kind: _kind,
        taxNumber: _tax.toUpperCase(),
        phone: _phone,
        email: _email,
      ),
    );
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
          Text('Open a business account', style: t.text.xxl),
          const SizedBox(height: 8),
          Text(
            'It takes about three minutes. Have your tax number to hand.',
            style: t.text.sm.copyWith(color: c.mutedForeground),
          ),
          const SizedBox(height: 24),
          FormText(
            label: const Text('Business name'),
            placeholder: 'As registered',
            validator: Validate.required('Enter the business name.'),
            onSaved: (v) => _name = v!,
          ),
          const SizedBox(height: 16),
          FormItem<String>(
            label: const Text('What kind of business'),
            validator: (v) => v == null || v.isEmpty ? 'Choose one.' : null,
            onSaved: (v) => _kind = v ?? '',
            builder: (field) => Select<String>(
              value: field.value,
              placeholder: 'Choose one',
              error: field.hasError,
              semanticLabel: 'What kind of business',
              options: [for (final k in _kinds) SelectOption(k, k)],
              onChanged: field.didChange,
            ),
          ),
          const SizedBox(height: 16),
          FormText(
            label: const Text('Tax number'),
            placeholder: '12-3456789',
            description: const Text(
              'The number your tax office gave the business: an EIN, VAT or GST number.',
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9 -]')),
              LengthLimitingTextInputFormatter(20),
            ],
            validator: Validate.all([
              Validate.required('Enter the tax number.'),
              Validate.pattern(
                RegExp(r'^[A-Za-z0-9][A-Za-z0-9 -]{4,18}[A-Za-z0-9]$'),
                'A tax number has 6 to 20 letters and digits.',
              ),
            ]),
            onSaved: (v) => _tax = v!,
          ),
          const SizedBox(height: 16),
          FormText(
            label: const Text('Business phone'),
            placeholder: '+1 415 555 0123',
            keyboardType: TextInputType.phone,
            validator: Validate.required('Enter a phone number.'),
            onSaved: (v) => _phone = v!,
          ),
          const SizedBox(height: 16),
          FormText(
            label: const Text('Email for statements'),
            placeholder: 'accounts@example.com',
            keyboardType: TextInputType.emailAddress,
            validator: Validate.all([
              Validate.required('Enter an email.'),
              Validate.email(),
            ]),
            onSaved: (v) => _email = v!,
          ),
          const SizedBox(height: 24),
          Button(
            expand: true,
            onPressed: _send,
            child: const Text('Open the account'),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text('Already with us?'),
              Button(
                variant: ButtonVariant.link,
                onPressed: () => widget.onSignIn?.call(),
                child: const Text('Sign in'),
              ),
            ],
          ),
        ],
      ),
    );
    final page = Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: form,
        ),
      ),
    );
    return LayoutBuilder(
      builder: (context, box) => box.maxWidth < 900
          ? page
          : Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: box.maxWidth * .42,
                  child: ColoredBox(
                    color: c.muted,
                    child: Padding(
                      padding: const EdgeInsets.all(48),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const AshlarIcon(
                                AshlarIconsRoundedStroke.store,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Tally Books',
                                style: t.text.base.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Text(
                            'Your books, kept as you sell.',
                            style: t.text.xxl,
                          ),
                          const SizedBox(height: 24),
                          for (final (icon, text) in [
                            (
                              AshlarIconsRoundedStroke.creditCard,
                              'Card and bank payments matched to sales on their own',
                            ),
                            (
                              AshlarIconsRoundedStroke.receipt,
                              'Tax invoices sent as you sell',
                            ),
                            (
                              AshlarIconsRoundedStroke.chartColumn,
                              'What you made this month, any day you ask',
                            ),
                          ])
                            Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: Row(
                                children: [
                                  AshlarIcon(icon, size: 18),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(text, style: t.text.base),
                                  ),
                                ],
                              ),
                            ),
                          const Spacer(),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(child: page),
              ],
            ),
    );
  }
}
