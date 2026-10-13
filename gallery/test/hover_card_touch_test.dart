// A hover card on a touch screen: a long press opens it, a tap stays with the link.
import 'package:ashlar_ui_gallery/ui/app.dart';
import 'package:ashlar_ui_gallery/ui/button.dart';
import 'package:ashlar_ui_gallery/ui/hover_card.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('a long press opens it; a tap is the link\'s', (tester) async {
    var went = 0;
    await tester.pumpWidget(
      AshlarApp(
        home: Center(
          child: HoverCard(
            content: (context) => const Text('Joined in March 2024.'),
            child: Button(
              variant: ButtonVariant.link,
              onPressed: () => went++,
              child: const Text('@achieng'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('@achieng'));
    await tester.pumpAndSettle();
    expect(went, 1);
    expect(find.text('Joined in March 2024.'), findsNothing);
    await tester.longPress(find.text('@achieng'));
    await tester.pumpAndSettle();
    expect(find.text('Joined in March 2024.'), findsOneWidget);
    expect(went, 1);
    // A tap elsewhere closes it.
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(find.text('Joined in March 2024.'), findsNothing);
  });
}
