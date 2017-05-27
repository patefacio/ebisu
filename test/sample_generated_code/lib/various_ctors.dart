library test_code_generation.various_ctors;

// custom <additional imports>
// end <additional imports>

class VariousCtors {
  VariousCtors(one, [two, three, this.six, this._seven])
      : one = one ?? 1.00001,
        two = two ?? two,
        three = three ?? 3;

  VariousCtors.fromFive([five]) : five = five ?? 5;

  VariousCtors.fromThreeAndFour(three, {four})
      : three = three ?? 3,
        four = four ?? 90;

  double one = 1.00001;
  String two = 'two';
  int three = 3;
  int four = 4;
  int five = 2;
  String six;
  String get seven => _seven;

  // custom <class VariousCtors>
  // end <class VariousCtors>

  String _seven;
}

// custom <library various_ctors>
// end <library various_ctors>

void main([List<String> args]) {
// custom <main>
// end <main>
}
