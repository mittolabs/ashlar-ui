// The data-table picture ashlar update --preview draws, from the site's demo.
import 'package:flutter/widgets.dart';

import 'package:ashlar_ui_gallery/ui/badge.dart';
import 'package:ashlar_ui_gallery/ui/data_table.dart';
import 'package:ashlar_ui_gallery/ui/input.dart';
import 'package:ashlar_ui_gallery/ui/pagination.dart';
import 'package:ashlar_ui_gallery/ui/theme.dart';

class DataTableDemo extends StatefulWidget {
  const DataTableDemo({super.key});

  @override
  State<DataTableDemo> createState() => _DataTableDemoState();
}

class _DataTableDemoState extends State<DataTableDemo> {
  static final invoices = [
    for (var i = 1; i <= 23; i++)
      (
        number: 'INV${i.toString().padLeft(3, '0')}',
        status: i % 5 == 0 ? 'Overdue' : (i % 3 == 0 ? 'Pending' : 'Paid'),
        amount: 500 + (i * 737) % 4000,
      ),
  ];

  String filter = '';
  bool ascending = false;
  int page = 1;
  Set<String> picked = {};
  static const perPage = 5;

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    // The table shows what it is given: filtering, sorting and paging happen here.
    final rows = invoices.where((i) => i.number.toLowerCase().contains(filter.toLowerCase())).toList()
      ..sort((a, b) => ascending ? a.amount.compareTo(b.amount) : b.amount.compareTo(a.amount));
    final pages = (rows.length / perPage).ceil().clamp(1, 99);
    final shown = rows.skip((page.clamp(1, pages) - 1) * perPage).take(perPage).toList();
    return SizedBox(
      width: 560,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              SizedBox(
                width: 220,
                child: Input(
                  placeholder: 'Filter invoices…',
                  onChanged: (v) => setState(() {
                    filter = v;
                    page = 1;
                  }),
                ),
              ),
              const Spacer(),
              Text('${picked.length} of ${rows.length} picked', style: TextStyle(color: t.colors.mutedForeground)),
            ],
          ),
          const SizedBox(height: 12),
          DataTable(
            columns: const [
              DataColumn(Text('Invoice')),
              DataColumn(Text('Status')),
              DataColumn(Text('Amount'), numeric: true, sortable: true),
            ],
            sortColumn: 2,
            sortAscending: ascending,
            onSort: (_) => setState(() => ascending = !ascending),
            selected: {
              for (final (i, r) in shown.indexed)
                if (picked.contains(r.number)) i,
            },
            onSelectChanged: (s) => setState(() {
              for (final (i, r) in shown.indexed) {
                s.contains(i) ? picked.add(r.number) : picked.remove(r.number);
              }
            }),
            rows: [
              for (final r in shown)
                [
                  Text(r.number),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Badge(
                      variant: switch (r.status) {
                        'Overdue' => BadgeVariant.destructive,
                        'Pending' => BadgeVariant.secondary,
                        _ => BadgeVariant.outline,
                      },
                      child: Text(r.status),
                    ),
                  ),
                  Text('KES ${r.amount}'),
                ],
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Pagination(page: page.clamp(1, pages), pageCount: pages, onChanged: (p) => setState(() => page = p)),
          ),
        ],
      ),
    );
  }
}
