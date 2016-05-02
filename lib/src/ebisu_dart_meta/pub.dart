part of ebisu.ebisu_dart_meta;

/// A dependency of the system
class PubDependency {
  PubDependency(this.name);

  /// Name of dependency
  String name;

  /// Required version for this dependency
  String version = 'any';

  /// Path to package, infers package type for git (git:...), hosted (http:...), path
  String path;

  /// Git reference
  String gitRef;

  // custom <class PubDependency>

  PubDepType get type {
    if (_type == null) {
      if (path != null) {
        var match = _pubTypeRe.firstMatch(path);

        switch (match.group(1)) {
          case 'git:':
            {
              _type = PubDepType.GIT;
            }
            break;
          case 'http:':
            {
              _type = PubDepType.HOSTED;
            }
            break;
          default:
            {
              _type = PubDepType.PATH;
            }
        }
      } else {
        _type = PubDepType.HOSTED;
      }
    }

    return _type;
  }

  bool get isHosted => (type == PubDepType.HOSTED);
  bool get isGit => (type == PubDepType.GIT);
  bool get isPath => (type == PubDepType.PATH);

  String get yamlEntry {
    String result;

    if (isHosted) {
      result = '''
  ${name}: ${version!=null? '"${version}"' : ''}
''';
    } else if (isPath || isGit) {
      result = '''
  $name:
''';
    } else {
      result = '''
  $name: '$version'
''';
    }

    if (path != null) {
      if (isHosted) {
        result += '''
      hosted:
        name: $name
        url: $path
      version: '$version'
''';
      } else if (isGit) {
        if (gitRef != null) {
          result += '''
      git:
        url: ${path}
        ref: ${gitRef}
''';
        } else {
          result += '''
      git: $path
''';
        }
      } else {
        result += '''
      path: $path
''';
      }
    }
    return result;
  }

  // end <class PubDependency>

  /// Type for the pub dependency
  PubDepType _type;
}

/// Entry in the transformer sections
abstract class PubTransformer {
  PubTransformer(this.name);

  /// Name of transformer
  String name;

  // custom <class PubTransformer>

  String get yamlEntry;

  // end <class PubTransformer>

}

/// A polymer transformer entry
class PolymerTransformer extends PubTransformer {
  /// List of entry points
  List<String> entryPoints;

  // custom <class PolymerTransformer>

  PolymerTransformer(this.entryPoints) : super('polymer');

  String get yamlEntry {
    final entryPointList = entryPoints
        .map((String entryPoint) => '- $entryPoint')
        .join('\n        ');

    return '''
  - polymer:
      entry_points:
        $entryPointList
''';
  }

  // end <class PolymerTransformer>

}

/// Information for the pubspec of the system
class PubSpec extends Object with Entity {
  PubSpec(this._id);

  /// Id for this pub spec
  Id get id => _id;

  /// Version for this package
  String version = '0.0.1';

  /// Name of the project described in spec.
  /// If not set, id of system is used.
  String name;

  /// Author of the pub package
  String author;

  /// Homepage of the pub package
  String homepage;
  List<PubDependency> dependencies = [];
  List<PubDependency> devDependencies = [];
  List<PubTransformer> pubTransformers = [];
  String sdk = '>=1.8.2 <2.0.0';

  // custom <class PubSpec>

  /// PubSpec has no children
  Iterable<Entity> get children => new Iterable<Entity>.generate(0);

  onOwnershipEstablished() {
    if (author == null && Platform.environment['EBISU_AUTHOR'] != null) {
      author = Platform.environment['EBISU_AUTHOR'];
    }

    if (homepage == null && Platform.environment['EBISU_HOMEPAGE'] != null) {
      homepage = Platform.environment['EBISU_HOMEPAGE'];
    }

    if (name == null) name = _id.snake;
  }

  void addTransformer(PubTransformer transformer) =>
      pubTransformers.add(transformer);

  void addDependency(PubDependency dep, [bool ignoreIfPresent = false]) {
    if (depNotFound(dep.name)) {
      dependencies.add(dep);
    } else {
      if (!ignoreIfPresent)
        throw new ArgumentError(
            "${dep.name} is already a dependency of ${_id}");
    }
  }

  void addDevDependency(PubDependency dep, [bool ignoreIfPresent = false]) {
    if (depNotFound(dep.name)) {
      devDependencies.add(dep);
    } else {
      if (!ignoreIfPresent)
        throw new ArgumentError(
            "${dep.name} is already a dev dependency of ${_id}");
    }
  }

  void addDependencies(List<PubDependency> deps) =>
      deps.forEach((dep) => addDependency(dep));

  bool depNotFound(String name) =>
      !devDependencies.any((d) => d.name == name) &&
      !dependencies.any((d) => d.name == name);

  get content => [
        _name,
        _version,
        _author,
        _homepage,
        _description,
        _sdk,
        _dependencies,
        _devDependencies,
        _dependencyOverrides,
        _transformers,
        _custom,
      ].where((line) => line != '').join('\n');

  get _sdk => '''
environment:
  sdk: ${smartQuote(sdk)}
''';
  get _name => 'name: $name';
  get _version => 'version: $version';
  get _author => author != null ? 'author: $author' : '';
  get _homepage => homepage != null ? 'homepage: $homepage' : '';
  get _description => doc != null ? 'description: >\n${indentBlock(doc)}' : '';

  get _dependencies => '''
dependencies:
${dependencies.map((d) => d.yamlEntry).join()}
${scriptCustomBlock('$name dependencies')}''';

  get _devDependencies => '''
dev_dependencies:
${devDependencies.map((d) => d.yamlEntry).join()}
${scriptCustomBlock('$name dev dependencies')}''';

  get _dependencyOverrides => '''
dependency_overrides:
${scriptCustomBlock('$name dependency overrides')}''';

  get _transformers => '''
transformers:
${pubTransformers.map((t) => t.yamlEntry).join()}''';

  get _custom => scriptCustomBlock('$name transformers');

  // end <class PubSpec>

  Id _id;
}

// custom <part pub>
// end <part pub>
