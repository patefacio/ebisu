part of ebisu.ebisu_dart_meta;

class Benchmark {
  Benchmark(this._id);

  /// Id for this benchmark
  Id get id => _id;
  /// Documentation for this benchmark
  String doc;
  /// Reference to System parent of this benchmark
  System get parent => _parent;
  /// Additional classes in the benchmark library
  List<Class> classes = [];

  // custom <class Benchmark>

  set parent(p) {
    _parent = p;
  }

  void generate() {
    final idStr = _id.snake;
    final dir = join(_parent.rootPath, 'benchmarks');
    final benchSnake = 'bench_$idStr';
    final benchLib = library(benchSnake)
      ..imports = ['package:benchmark_harness/benchmark_harness.dart'];

    final klass = class_(benchSnake)
      ..extend = 'BenchmarkBase'
      ..parent = benchLib;

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
  System _parent;
}
// custom <part benchmark>
// end <part benchmark>
