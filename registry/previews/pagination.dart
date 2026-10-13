// The pagination picture ashlar update --preview draws, from the site's demo.
import 'package:flutter/widgets.dart';

import 'package:ashlar_ui_gallery/ui/pagination.dart';

class PaginationDemo extends StatefulWidget {
  const PaginationDemo({super.key});

  @override
  State<PaginationDemo> createState() => _PaginationDemoState();
}

class _PaginationDemoState extends State<PaginationDemo> {
  int page = 5;

  @override
  Widget build(BuildContext context) =>
      Pagination(page: page, pageCount: 12, onChanged: (p) => setState(() => page = p));
}
