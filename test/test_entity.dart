library ebisu.test_entity;

import 'package:ebisu/ebisu.dart';
import 'package:id/id.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

// custom <additional imports>
// end <additional imports>

final Logger _logger = new Logger('test_entity');

class Base {
  int ownershipCount = 0;

  // custom <class Base>

  ownerSet() {
    _logger.info('onOwnershipEstablished called ${runtimeType}');
    ownershipCount++;
  }

  toString() => '${runtimeType}:ownershipCount $ownershipCount';

  // end <class Base>

}

class RootEntity extends Base with Entity {
  List<ChildEntity> children = [];

  // custom <class RootEntity>

  final Id _id;
  RootEntity(id) : _id = makeId(id);
  get id => _id;
  onOwnershipEstablished() => ownerSet();

  // end <class RootEntity>

}

class ChildEntity extends Base with Entity {
  List<GrandchildEntity> grandChildren = [];

  // custom <class ChildEntity>

  final Id _id;
  ChildEntity(id) : _id = makeId(id);
  get id => _id;
  Iterable<Entity> get children => grandChildren;
  onOwnershipEstablished() => ownerSet();

  // end <class ChildEntity>

}

class GrandchildEntity extends Base with Entity {
  List<GreatGrandchildEntity> greatGrandChildren = [];

  // custom <class GrandchildEntity>

  final Id _id;
  GrandchildEntity(id) : _id = makeId(id);
  get id => _id;
  Iterable<Entity> get children => greatGrandChildren;
  onOwnershipEstablished() => ownerSet();

  // end <class GrandchildEntity>

}

class GreatGrandchildEntity extends Base with Entity {
  // custom <class GreatGrandchildEntity>

  final Id _id;
  GreatGrandchildEntity(id) : _id = makeId(id);
  get id => _id;
  Iterable<Entity> get children => [];
  onOwnershipEstablished() => ownerSet();

  // end <class GreatGrandchildEntity>

}

// custom <library test_entity>
// end <library test_entity>

void main([List<String> args]) {
  if (args?.isEmpty ?? false) {
    Logger.root.onRecord.listen(
        (LogRecord r) => print("${r.loggerName} [${r.level}]:\t${r.message}"));
    Logger.root.level = Level.OFF;
  }
// custom <main>

  group('entity', () {
    final root = new RootEntity(idFromString('root'))
      ..children = [
        new ChildEntity('c1')
          ..grandChildren = [
            new GrandchildEntity('gc1')
              ..greatGrandChildren = [
                new GreatGrandchildEntity('ggc11'),
                new GreatGrandchildEntity('ggc12'),
                new GreatGrandchildEntity('ggc13'),
              ],
            new GrandchildEntity('gc2')
              ..greatGrandChildren = [
                new GreatGrandchildEntity('ggc21'),
                new GreatGrandchildEntity('ggc22'),
                new GreatGrandchildEntity('ggc23'),
              ],
          ]
      ];

    root.setAsRoot();

    _logger
        .info(brCompact(root.progeny.map((e) => '${e.runtimeType}::${e.id}')));

    test('progeny finds all', () {
      expect(root.progeny.length, 9);
      expect(root.progeny.where((e) => e is GreatGrandchildEntity).length, 6);
    });

    test('progeny finds grandchild', () {
      final gcc23 = root.progeny.firstWhere((e) => e.id.toString() == 'ggc23');
      final gc1 = root.progeny.firstWhere((e) => e.id.toString() == 'gc1');
      final gc2 = root.progeny.firstWhere((e) => e.id.toString() == 'gc2');
      expect(gcc23.id, new Id('ggc23'));
      expect(gcc23.root, root);
      expect(gcc23.findAncestorWhere((a) => a == gc2), gc2);
      expect(gcc23.findAncestorWhere((a) => a == gc1), null);
      expect(gcc23.findAncestorWhere((a) => a == root), root);
    });

    test('ownershipCount', () {
      final Base gcc23 =
          root.progeny.firstWhere((e) => e.id.toString() == 'ggc23') as Base;
      final Base gc1 =
          root.progeny.firstWhere((e) => e.id.toString() == 'gc1') as Base;
      final Base gc2 =
          root.progeny.firstWhere((e) => e.id.toString() == 'gc2') as Base;
      expect(gcc23.ownershipCount, 1);
      expect(gc1.ownershipCount, 1);
      expect(gc2.ownershipCount, 1);
    });

    test('entityPathIds, detailedPath', () {
      final gcc23 = root.progeny.firstWhere((e) => e.id.toString() == 'ggc23');

      final c1Id = idFromString('c1');
      final gc2Id = idFromString('gc2');
      final ggc23Id = idFromString('ggc23');

      expect(gcc23.entityPathIds, [c1Id, gc2Id, ggc23Id]);
      expect(chomp(gcc23.detailedPath),
          '(ChildEntity:c1), (GrandchildEntity:gc2), (GreatGrandchildEntity:ggc23)');
    });
  });

// end <main>
}
