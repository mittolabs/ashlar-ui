// The breadcrumb picture ashlar update --preview draws, from the site's demo.
import 'package:flutter/widgets.dart';

import 'package:ashlar_ui_gallery/ui/breadcrumb.dart';

class BreadcrumbDemo extends StatelessWidget {
  const BreadcrumbDemo({super.key});

  @override
  Widget build(BuildContext context) => Breadcrumb(
    items: [
      BreadcrumbItem('Home', onPressed: () {}),
      BreadcrumbItem('Components', onPressed: () {}),
      const BreadcrumbItem('Breadcrumb'),
    ],
  );
}
