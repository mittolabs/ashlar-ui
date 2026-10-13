/// A component the ashlar command can add: its files, the components it needs, and
/// the packages it needs from pub.dev.
class Component {
  const Component({required this.description, required this.files, this.requires = const [], this.packages = const [], this.block = false});

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
}
