// Tests for Carousel. Copied into your app by `ashlar add carousel` with the component: they
// check what it promises, so change them as you change it.
import 'package:ashlar_ui_gallery/ui/app.dart';
import 'package:ashlar_ui_gallery/ui/carousel.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

Widget app(Widget child) => AshlarApp(home: Center(child: child));

void main() {
  testWidgets(
    'a carousel moves by its buttons and arrow keys, and says which slide shows',
    (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        app(
          SizedBox(
            width: 500,
            height: 200,
            child: Carousel(
              children: [for (var i = 1; i <= 4; i++) Text('Card $i')],
            ),
          ),
        ),
      );
      await tester.tap(
        find.bySemanticsLabel('Previous slide'),
        warnIfMissed: false,
      );
      await tester.pumpAndSettle();
      expect(find.text('Card 1').hitTestable(), findsOneWidget);
      await tester.tap(find.bySemanticsLabel('Next slide'));
      await tester.pumpAndSettle();
      expect(find.text('Card 2').hitTestable(), findsOneWidget);
      expect(find.bySemanticsLabel('Carousel'), findsOneWidget);
      expect(
        tester
            .getSemantics(find.bySemanticsLabel('Carousel'))
            .getSemanticsData()
            .value,
        'Slide 2 of 4',
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      expect(find.text('Card 3').hitTestable(), findsOneWidget);
      semantics.dispose();
    },
  );

  testWidgets('a carousel moved by its controller, and by itself', (
    tester,
  ) async {
    final controller = CarouselController();
    await tester.pumpWidget(
      app(
        SizedBox(
          width: 300,
          height: 300,
          child: Carousel(
            axis: Axis.vertical,
            controller: controller,
            autoplay: const Duration(seconds: 2),
            children: [for (var i = 1; i <= 3; i++) Text('Slide $i')],
          ),
        ),
      ),
    );
    controller.next();
    await tester.pumpAndSettle();
    expect(controller.index, 1);
    expect(find.text('Slide 2').hitTestable(), findsOneWidget);
    // Upright: the next slide comes from below.
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(controller.index, 2);
    // And from the last, back to the first.
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(controller.index, 0);
    await tester.pumpWidget(const SizedBox());
  });
}
