/// Provides support for mixing in recursive design pattern
part of ebisu.ebisu;

abstract class Identifiable {

  // custom <class Identifiable>

  Id get id;

  // end <class Identifiable>

}

/// Provides support for mixing in recursive design pattern among various
/// *Entities*
///
abstract class Entity implements Identifiable {

  /// Description of entity
  String descr;
  /// The entity containing this entity (e.g. the [Class] containing the [Member]).
  /// [Installation] is a top level entity and has no owner.
  Entity get owner => _owner;
  /// Path from root to this entity
  List<Entity> get entityPath => _entityPath;

  // custom <class Entity>

  /// All entities must provide iteration on [children] entities
  Iterable<Entity> get children;

  String get briefComment => brief != null ? '//! $brief' : null;

  String get detailedComment => descr != null ? blockComment(descr, ' ') : null;

  String get docComment => combine([briefComment, detailedComment]);

  Iterable<Id> get entityPathIds => _entityPath.map((e) => e.id);

  get uniqueId => entityPathIds.toString().hashCode;

  get dottedName => entityPathIds.map((id) => id.snake).join('.');

  get detailedPath => brCompact(
      entityPath.map((e) => '(${e.runtimeType}:${e.id.snake})').join(', '));

  set doc(String d) => descr = d;
  get doc => descr;

  get hasComment => brief != null || descr != null;

  /// Establishes the [Entity] that *this* [Entity] is owned by.
  set owner(Entity newOwner) {
    bool isRoot = newOwner == null;
    _owner = newOwner;
    onOwnershipEstablished();

    if (!isRoot) {
      _entityPath
        ..addAll(newOwner.entityPath)
        ..add(this);
    }

    _logger.info('Set owner ($id:${runtimeType}) to '
        '${newOwner == null? "root" : "(${newOwner.id}:${newOwner.runtimeType})"}');

    for (final child in children) {
      child.owner = this;
    }
  }

  /// Called when an owner is assigned to the [Entity]
  void onOwnershipEstablished() {}

  /// Returns a list of all children recursively
  List<Entity> get progeny => children.fold([], (all, child) => all
    ..add(child)
    ..addAll(child.progeny));

  findAncestorWhere(predicate) => predicate(this)
      ? this
      : owner == null ? owner : owner.findAncestorWhere(predicate);

  /// Walks the list up throuh the ownership chain, returning a List<Entity> of
  /// all owners
  List<Entity> get ancestry {
    final List<Entity> result = [];
    var parent = _owner;
    while (parent != null) {
      result.add(parent);
      parent = parent._owner;
    }
    return result;
  }

  /// Recursively walks up to root (i.e. Entity with null parent)
  get root => _owner == null ? this : _owner.root;

  // end <class Entity>

  Entity _owner;
  List<Entity> _entityPath = [];
}

// custom <part entity>
// end <part entity>
