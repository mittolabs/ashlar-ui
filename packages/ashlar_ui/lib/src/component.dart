/// A component the ashlar command can add: its files, the components it needs, and
/// the packages it needs from pub.dev.
class Component {
  /// A component as the registry describes it: what it is, its files, and what it needs.
  const Component({
    required this.description,
    required this.files,
    this.requires = const [],
    this.packages = const [],
    this.block = false,
    this.tests = const {},
    this.testNeeds = const [],
    this.preview,
    this.previewWidget,
    this.replaces = const [],
  });

  /// Names it went by before, which still find it: a renamed block keeps working.
  final List<String> replaces;

  /// What it is, in a line: shown by ashlar view, search and list.
  final String description;

  /// File name to source.
  final Map<String, String> files;

  /// Other components it needs, added with it.
  final List<String> requires;

  /// Packages from pub.dev it needs, added to pubspec.yaml.
  final List<String> packages;

  /// A whole screen made of components, written beside them in a blocks folder rather
  /// than with them.
  final bool block;

  /// Its tests, file name to source: written to the project's test/ashlar with it, so
  /// they check what it still promises after you change it.
  final Map<String, String> tests;

  /// The other items its tests use: the tests are written once the project has these.
  final List<String> testNeeds;

  /// A small screen of it, for ashlar update --preview to draw before and after an
  /// update: the site's demo, importing the gallery's ui folder as the tests do.
  final String? preview;

  /// The widget [preview] declares.
  final String? previewWidget;
}
