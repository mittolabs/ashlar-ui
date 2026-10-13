// The full data table: sorting, row selection and long data, as an app gets it from lib/ui.
import 'package:ashlar_ui_gallery/ui/app.dart';
import 'package:ashlar_ui_gallery/ui/checkbox.dart';
import 'package:ashlar_ui_gallery/ui/data_table.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

Widget app(Widget child) => AshlarApp(
  home: Center(child: SizedBox(width: 500, child: child)),
);

final invoices = [('INV001', 2500), ('INV002', 1500), ('INV003', 3500)];

void main() {
  testWidgets(
    'a sortable heading asks for the sort, and shows which way it is sorted',
    (tester) async {
      final semantics = tester.ensureSemantics();
      var ascending = true;
      await tester.pumpWidget(
        app(
          StatefulBuilder(
            builder: (context, set) {
              final rows = [...invoices]
                ..sort(
                  (a, b) =>
                      ascending ? a.$2.compareTo(b.$2) : b.$2.compareTo(a.$2),
                );
              return DataTable(
                columns: const [
                  DataColumn(Text('Invoice')),
                  DataColumn(Text('Amount'), numeric: true, sortable: true),
                ],
                sortColumn: 1,
                sortAscending: ascending,
                onSort: (_) => set(() => ascending = !ascending),
                rows: [
                  for (final r in rows) [Text(r.$1), Text('${r.$2}')],
                ],
              );
            },
          ),
        ),
      );
      double top(String s) => tester.getTopLeft(find.text(s)).dy;
      expect(top('1500'), lessThan(top('3500')));
      expect(
        tester.getSemantics(find.text('Amount')).getSemanticsData().label,
        contains('sorted ascending'),
      );
      await tester.tap(find.text('Amount'));
      await tester.pump();
      expect(top('3500'), lessThan(top('1500')));
      expect(
        tester.getSemantics(find.text('Amount')).getSemanticsData().label,
        contains('sorted descending'),
      );
      // From the keyboard too.
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(top('1500'), lessThan(top('3500')));
      semantics.dispose();
    },
  );

  testWidgets('rows are picked one by one, or all from the heading', (
    tester,
  ) async {
    var picked = <int>{};
    await tester.pumpWidget(
      app(
        StatefulBuilder(
          builder: (context, set) => DataTable(
            columns: const [
              DataColumn(Text('Invoice')),
              DataColumn(Text('Amount'), numeric: true),
            ],
            selected: picked,
            onSelectChanged: (s) => set(() => picked = s),
            rows: [
              for (final r in invoices) [Text(r.$1), Text('${r.$2}')],
            ],
          ),
        ),
      ),
    );
    final boxes = find.byType(Checkbox);
    expect(boxes, findsNWidgets(4));
    await tester.tap(boxes.at(2));
    await tester.pump();
    expect(picked, {1});
    await tester.tap(boxes.first);
    await tester.pump();
    expect(picked, {0, 1, 2});
    await tester.tap(boxes.first);
    await tester.pump();
    expect(picked, isEmpty);
  });

  testWidgets(
    'with 10,000 rows the builder builds a screenful under a fixed heading',
    (tester) async {
      await tester.pumpWidget(
        app(
          DataTable.builder(
            columns: const [
              DataColumn(Text('Order')),
              DataColumn(Text('Amount'), numeric: true),
            ],
            rowCount: 10000,
            height: 400,
            rowBuilder: (i) => [Text('Order $i'), Text('${i * 10}')],
          ),
        ),
      );
      expect(find.textContaining('Order ').evaluate().length, lessThan(20));
      await tester.drag(find.text('Order 3'), const Offset(0, -20000));
      await tester.pumpAndSettle();
      expect(find.textContaining('Order ').evaluate().length, lessThan(20));
      expect(find.text('Order').hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
