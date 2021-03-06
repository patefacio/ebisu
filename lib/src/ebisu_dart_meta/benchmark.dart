part of ebisu.ebisu_dart_meta;

class Benchmark extends Object with Entity {
  Benchmark(this._id);

  /// Id for this benchmark
  Id get id => _id;

  /// Additional classes in the benchmark library
  List<Class> classes = [];

  // custom <class Benchmark>

  Iterable<Entity> get children => concat([classes]);

  onOwnershipEstablished() {}

  /// Generates the benchmark
  void generate() {
    final idStr = _id.snake;
    final dir = join(root.rootPath, 'benchmarks');
    final benchSnake = 'bench_$idStr';
    final benchLib = library_(benchSnake)
      ..imports = ['package:benchmark_harness/benchmark_harness.dart'];

    final klass = class_(benchSnake)
      ..extend = 'BenchmarkBase'
      ..owner = benchLib;

    klass.topInjection = '''
${klass.name}() : super('${_id.capCamel}');
''';

    benchLib
      ..classes.add(klass)
      ..path = dir
      ..libMain = '''
main() {
  ${klass.name}.main();
}
'''
      .._qualifiedName = 'benchmarks.$idStr';

    benchLib.generate();
  }

  // end <class Benchmark>

  final Id _id;
}

// custom <part benchmark>
// end <part benchmark>
