// The markdown picture ashlar update --preview draws, from the site's demo.
import 'package:flutter/widgets.dart';

import 'package:ashlar_ui_gallery/ui/markdown.dart';

const _answer = """
## Moving a table to its own schema

You can do it **without downtime**, in three steps. The one to watch is the *second*:
writes go to both tables until the copy catches up.

1. Make the new table and copy the rows across.
2. Write to both, then backfill what changed.
3. Read from the new one, and drop the old.

```sql
alter table orders set schema billing;
```

| Step | Locks | Time on 2M rows |
|---|---|---:|
| Copy | none | 4 min |
| Switch | brief | 1 s |

> Take a backup first: `pg_dump -t orders`.

- [x] Backup taken
- [ ] Copy started""";

class MarkdownDemo extends StatelessWidget {
  const MarkdownDemo({super.key});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 560,
    child: Markdown(_answer, streaming: true, onLink: (_) {}),
  );
}
