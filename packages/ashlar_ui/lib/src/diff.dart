/// The lines that differ between [a] and [b], as `diff -u` shows them: a minus for a
/// line only in [a], a plus for one only in [b], three lines of context around each change.
String unifiedDiff(String a, String b, {String from = 'a', String to = 'b'}) {
  final x = a.split('\n'), y = b.split('\n');
  // The longest common run of lines, from the end: lcs[i][j] for x[i..] and y[j..].
  final lcs = List.generate(x.length + 1, (_) => List.filled(y.length + 1, 0));
  for (var i = x.length - 1; i >= 0; i--) {
    for (var j = y.length - 1; j >= 0; j--) {
      lcs[i][j] = x[i] == y[j]
          ? lcs[i + 1][j + 1] + 1
          : (lcs[i + 1][j] >= lcs[i][j + 1] ? lcs[i + 1][j] : lcs[i][j + 1]);
    }
  }
  // Each line as kept (' '), taken away ('-') or added ('+'), with its line numbers.
  final ops = <(String, String, int, int)>[];
  var i = 0, j = 0;
  while (i < x.length || j < y.length) {
    if (i < x.length && j < y.length && x[i] == y[j]) {
      ops.add((' ', x[i], i, j));
      i++;
      j++;
    } else if (j < y.length &&
        (i == x.length || lcs[i][j + 1] >= lcs[i + 1][j])) {
      ops.add(('+', y[j], i, j));
      j++;
    } else {
      ops.add(('-', x[i], i, j));
      i++;
    }
  }
  final out = StringBuffer('--- $from\n+++ $to\n');
  const context = 3;
  var k = 0;
  while (k < ops.length) {
    if (ops[k].$1 == ' ') {
      k++;
      continue;
    }
    // A hunk: from a few lines before this change to a few after the last one near it.
    final start = k - context < 0 ? 0 : k - context;
    var end = k;
    while (end < ops.length) {
      if (ops[end].$1 != ' ') {
        end++;
        continue;
      }
      var run = end;
      while (run < ops.length && ops[run].$1 == ' ') {
        run++;
      }
      if (run == ops.length || run - end > context * 2) {
        end = (end + context).clamp(0, ops.length);
        break;
      }
      end = run;
    }
    final hunk = ops.sublist(start, end);
    final aCount = hunk.where((o) => o.$1 != '+').length;
    final bCount = hunk.where((o) => o.$1 != '-').length;
    out.writeln(
      '@@ -${hunk.first.$3 + 1},$aCount +${hunk.first.$4 + 1},$bCount @@',
    );
    for (final (kind, line, _, _) in hunk) {
      out.writeln('$kind$line');
    }
    k = end;
  }
  return out.toString();
}
