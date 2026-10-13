/// The result of merging two changed copies of a file with the copy they both came from.
class Merged {
  const Merged(this.text, this.conflicts);

  /// The merged text, with conflict markers where both sides changed the same lines.
  final String text;

  /// How many places both sides changed differently.
  final int conflicts;
}

/// A run of lines in the base, [start] to [end], replaced by [lines] on one side.
class _Change {
  _Change(this.start, this.end, this.lines);

  final int start, end;
  final List<String> lines;
}

/// The changes that turn [base] into [other], as runs of base lines replaced.
List<_Change> _changes(List<String> base, List<String> other) {
  // The longest common run of lines, from the end: lcs[i][j] for base[i..] and other[j..].
  final lcs = List.generate(
    base.length + 1,
    (_) => List.filled(other.length + 1, 0),
  );
  for (var i = base.length - 1; i >= 0; i--) {
    for (var j = other.length - 1; j >= 0; j--) {
      lcs[i][j] = base[i] == other[j]
          ? lcs[i + 1][j + 1] + 1
          : (lcs[i + 1][j] >= lcs[i][j + 1] ? lcs[i + 1][j] : lcs[i][j + 1]);
    }
  }
  final changes = <_Change>[];
  var i = 0, j = 0;
  _Change? open;
  void close() {
    if (open != null) changes.add(open!);
    open = null;
  }

  while (i < base.length || j < other.length) {
    if (i < base.length && j < other.length && base[i] == other[j]) {
      close();
      i++;
      j++;
    } else if (j < other.length &&
        (i == base.length || lcs[i][j + 1] >= lcs[i + 1][j])) {
      open ??= _Change(i, i, []);
      open!.lines.add(other[j]);
      j++;
    } else {
      open = _Change(open?.start ?? i, i + 1, open?.lines ?? []);
      i++;
    }
  }
  close();
  return changes;
}

/// [base] with [changes] that fall in base lines [from] to [to] applied.
List<String> _apply(
  List<String> base,
  List<_Change> changes,
  int from,
  int to,
) {
  final out = <String>[];
  var at = from;
  for (final c in changes) {
    out.addAll(base.sublist(at, c.start));
    out.addAll(c.lines);
    at = c.end;
  }
  out.addAll(base.sublist(at, to));
  return out;
}

/// Merges [yours] and [theirs], both changed from [base], line by line: a change on one
/// side is taken; the same change on both is taken once; different changes to the same
/// lines are both kept between conflict markers, as git does.
Merged merge3(
  String base,
  String yours,
  String theirs, {
  String yoursLabel = 'yours',
  String theirsLabel = 'ashlar',
}) {
  final b = base.split('\n'), y = yours.split('\n'), t = theirs.split('\n');
  final mine = _changes(b, y), new_ = _changes(b, t);
  final out = <String>[];
  var conflicts = 0;
  var at = 0, m = 0, n = 0;
  while (m < mine.length || n < new_.length) {
    // The next region: changes from either side that overlap or touch, grown until no
    // more do.
    final first =
        m < mine.length && (n >= new_.length || mine[m].start <= new_[n].start)
        ? mine[m]
        : new_[n];
    var start = first.start, end = first.end;
    final ys = <_Change>[], ts = <_Change>[];
    // A change joins the region when its base lines overlap it, or when one of them is an
    // insertion at the other's edge: both sides adding at the same place.
    bool joins(_Change c) =>
        c.start < end || (c.start == end && (end == start || c.end == c.start));
    var grew = true;
    while (grew) {
      grew = false;
      while (m < mine.length && joins(mine[m])) {
        ys.add(mine[m]);
        if (mine[m].end > end) end = mine[m].end;
        m++;
        grew = true;
      }
      while (n < new_.length && joins(new_[n])) {
        ts.add(new_[n]);
        if (new_[n].end > end) end = new_[n].end;
        n++;
        grew = true;
      }
    }
    out.addAll(b.sublist(at, start));
    final ySide = _apply(b, ys, start, end), tSide = _apply(b, ts, start, end);
    if (ts.isEmpty) {
      out.addAll(ySide);
    } else if (ys.isEmpty) {
      out.addAll(tSide);
    } else if (ySide.join('\n') == tSide.join('\n')) {
      out.addAll(ySide);
    } else {
      conflicts++;
      out
        ..add('<<<<<<< $yoursLabel')
        ..addAll(ySide)
        ..add('=======')
        ..addAll(tSide)
        ..add('>>>>>>> $theirsLabel');
    }
    at = end;
  }
  out.addAll(b.sublist(at));
  return Merged(out.join('\n'), conflicts);
}
