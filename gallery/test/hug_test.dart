// Components that should be as tall as what they hold, even where there is room to grow.
import 'package:ashlar_icons/ashlar_icons.dart';
import 'package:ashlar_ui_gallery/ui/accordion.dart';
import 'package:ashlar_ui_gallery/ui/alert.dart';
import 'package:ashlar_ui_gallery/ui/app.dart';
import 'package:ashlar_ui_gallery/ui/attachment.dart';
import 'package:ashlar_ui_gallery/ui/bubble.dart';
import 'package:ashlar_ui_gallery/ui/button.dart';
import 'package:ashlar_ui_gallery/ui/card.dart';
import 'package:ashlar_ui_gallery/ui/checkbox.dart';
import 'package:ashlar_ui_gallery/ui/empty.dart';
import 'package:ashlar_ui_gallery/ui/field.dart';
import 'package:ashlar_ui_gallery/ui/input.dart';
import 'package:ashlar_ui_gallery/ui/item.dart';
import 'package:ashlar_ui_gallery/ui/kbd.dart';
import 'package:ashlar_ui_gallery/ui/badge.dart';
import 'package:ashlar_ui_gallery/ui/toggle.dart';
import 'package:ashlar_ui_gallery/ui/marker.dart';
import 'package:ashlar_ui_gallery/ui/radio.dart';
import 'package:ashlar_ui_gallery/ui/switch.dart';
import 'package:ashlar_ui_gallery/ui/message.dart';
import 'package:ashlar_ui_gallery/ui/tabs.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final cases = <String, Widget>{
    'Alert': Alert(
      icon: const AshlarIcon(AshlarIconsRoundedStroke.circleAlert),
      title: const Text('Payment failed'),
      description: const Text('Try another card.'),
      action: Button(onPressed: () {}, child: const Text('Retry')),
    ),
    'Card': const Card(
      children: [
        CardHeader(title: Text('Title'), description: Text('About it')),
        CardContent(child: Text('Body')),
      ],
    ),
    'Item': const Item(title: Text('Title'), description: Text('About it')),
    'Empty': const Empty(title: Text('Nothing here')),
    'Field': const Field(label: Text('Email'), child: Input()),
    'Field across': Field(
      axis: Axis.horizontal,
      label: const Text('Remember me'),
      child: Checkbox(value: true, onChanged: (_) {}),
    ),
    'Message': const Message(child: Bubble(child: Text('Hello'))),
    'Marker': const Marker(child: Text('Today')),
    'Attachment': const Attachment(title: 'file.pdf'),
    'Accordion': const Accordion(
      items: [AccordionItem(title: Text('Question'), content: Text('Answer'))],
    ),
    'Tabs': const Tabs(
      tabs: [TabItem(label: Text('One'), content: Text('First'))],
    ),
  };
  for (final MapEntry(key: name, value: widget) in cases.entries) {
    testWidgets('$name is as tall as what it holds', (tester) async {
      await tester.pumpWidget(
        AshlarApp(
          home: Center(
            child: SizedBox(
              width: 400,
              height: 1000,
              child: Center(child: widget),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 1));
      expect(tester.getSize(find.byWidget(widget)).height, lessThan(300));
    });
  }

  // Small inline things are as wide as their label, wherever they are put.
  final inline = <String, Widget>{
    'Kbd': const Kbd(child: Text('⌘')),
    'Badge': const Badge(child: Text('New')),
    'Button': Button(onPressed: () {}, child: const Text('Save')),
    'Toggle': Toggle(pressed: false, onChanged: (_) {}, child: const Text('B')),
  };
  for (final MapEntry(key: name, value: widget) in inline.entries) {
    testWidgets('$name is as wide as its label', (tester) async {
      await tester.pumpWidget(
        AshlarApp(
          home: Center(
            child: SizedBox(width: 400, child: Wrap(children: [widget])),
          ),
        ),
      );
      expect(tester.getSize(find.byWidget(widget)).width, lessThan(120));
    });
  }

  testWidgets(
    'a switch, a checkbox and a radio keep their size where a column stretches them',
    (tester) async {
      final controls = <Widget>[
        Switch(value: true, onChanged: (_) {}),
        Checkbox(value: true, onChanged: (_) {}),
        const Radio(value: 1),
      ];
      await tester.pumpWidget(
        AshlarApp(
          home: Center(
            child: SizedBox(
              width: 300,
              child: RadioGroup<int>(
                groupValue: 1,
                onChanged: (_) {},
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: controls,
                ),
              ),
            ),
          ),
        ),
      );
      for (final c in controls) {
        // The drawn control, inside the space it was given.
        final drawn = find
            .descendant(of: find.byWidget(c), matching: find.byType(Semantics))
            .first;
        expect(tester.getSize(drawn).width, lessThan(40));
      }
    },
  );
}
