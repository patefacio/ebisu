/// Provides support for mixing in recursive design pattern
part of ebisu.ebisu;

abstract class Identifiable {
  // custom <class Identifiable>

  Id get id;

  // end <class Identifiable>

}

/// Used to track composition hierarchy of named entities
///
/// Provides support for mixing in recursive design pattern among various
/// *Entities*
abstract class Entity implements Identifiable {
  /// Brief description for the entity.
  ///
  /// These items support both a brief comment ([brief]) and a more
  /// descriptive comment [descr]
  String brief;

  /// Description of entity
  String descr;

  /// Owner of this [Entity]
  ///
  /// The entity containing this entity (e.g. the [Class] containing the [Member]).
  /// The top level entity and has the value *null* since it has no owner.
  Entity get owner => _owner;

  /// Path from root to this entity
  List<Entity> get entityPath => _entityPath;

  // custom <class Entity>

  /// All entities must provide iteration on [children] entities
  Iterable<Entity> get children;

  /// Returns the [brief] comment as a comment
  String get briefComment => brief != null ? '//! $brief' : null;

  /// Returns a dart style triple slash comment including the [brief] and
  /// [descr] (i.e. detailed portion).
  String get docComment {
    final contents = chomp(br([brief, descr]), true);
    if (contents.isNotEmpty) {
      return dartComment(contents);
    }
    return null;
  }

  /// Returns an iterable of ids from root to this item
  Iterable<Id> get entityPathIds => _entityPath.map((e) => e.id);

  /// In order to provide a unique id which may be used as *tag* of custom
  /// block, this method creates a string of the entire path and uses its
  /// hashcode
  get uniqueId => entityPathIds.toString().hashCode;

  /// The path displayed as iterable of *runtimeType:id*
  get detailedPath => brCompact(
      entityPath.map((e) => '(${e.runtimeType}:${e.id.snake})').join(', '));

  /// Sets the detailed portion of the comment (ie [descr]).
  set doc(String d) => descr = d;

  /// Gets the detailed portion of the comment (ie [descr]).
  get doc => descr;

  /// Returns true if this has the brief or more detailed comment
  get hasComment => brief != null || descr != null;

  get _displayKey => '($id:$runtimeType)';

  /// Establishes the [Entity] that *this* [Entity] is owned by.
  set owner(Entity newOwner) {
    bool isRoot = newOwner == null;

    _logger.info('Setting owner of ${_displayKey} to ${newOwner?._displayKey}');

    if (_owner != null) {
      _logger.severe('Owner set multiple times '
          '${_owner._displayKey}:${newOwner._displayKey}\n${getStackTrace()}');
    }

    _owner = newOwner;
    onOwnershipEstablished();

    if (!isRoot) {
      _entityPath = []
        ..addAll(newOwner.entityPath)
        ..add(this);
    }

    for (final child in children) {
      child.owner = this;
    }
  }

  /// Called when an owner is assigned to the [Entity]
  void onOwnershipEstablished() {}

  /// Returns a list of all children recursively
  List<Entity> get progeny => children.fold(
      [],
      (all, child) => all
        ..add(child)
        ..addAll(child.progeny));

  /// Returns all enity ancestors where [predicate] is true
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

  /// Call this to make the entity the owner.
  /// Doing this establishes al owner/child relations
  setAsRoot() => owner = null;

  /// Recursively walks up to root (i.e. Entity with null parent)
  get rootEntity => _owner == null ? this : _owner.root;

  /// Alias to [rootEntity] - deprecated
  get root => rootEntity;

  // end <class Entity>

  Entity _owner;
  List<Entity> _entityPath = [];
}

// custom <part entity>
// end <part entity>
