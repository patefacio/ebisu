/// Support for code blocks - markers for custom hand-written or code
/// generation injected code.
part of ebisu.ebisu;

/// Mixin to provide a common approach to adding custom code.
///
/// This is a way for [Entity] objects, like [Part], [Library], [Ctor], etc, to
/// include a single [CodeBlock] allowing support for hand-written code (via the
/// *protect block* of [CodeBlock]) or injected code (via the [snippets] list within
/// the [CodeBlock].
class CustomCodeBlock {

  /// A custom code block for a class
  set customCodeBlock(CodeBlock customCodeBlock) =>
      _customCodeBlock = customCodeBlock;

  // custom <class CustomCodeBlock>

  /// Returns whether the inclusion of the [customBlock] of this mixin has been
  /// requested.
  ///
  /// By default, if the [customCodeBlock] has been initialized (eg via
  /// accessing [customCodeBlock] or using it via [withCustomBlock]) then this
  /// returns true. However, the custom portion of a [CodeBlock] (i.e. the
  /// custom begin/end tags) may be destracting or not needed if code can be
  /// entirely generated. Setting [includesCustom] to false will result in any
  /// *injected* code being returned via [taggedBlockText] without the custom
  /// protection block.
  bool get includesCustom => (_includesCustom != null &&
      _includesCustom == false) ? false : _customCodeBlock != null;

  /// Requests that the custom portion (ie protect block) of the [CodeBlock] be
  /// included or excluded.
  set includesCustom(bool ic) {
    if (ic) {
      _includesCustom = true;
      _initCustomBlock();
    } else {
      if (_customCodeBlock != null && _customCodeBlock.snippets.isNotEmpty) {
        _logger.warning('Custom code disabled for $runtimeType');
        _logger.warning('Snippets removed: ${br(_customCodeBlock.snippets)}');
      }
      _includesCustom = false;
      _customCodeBlock = null;
    }
  }

  /// *Auto-initializing* access to the [customCodeBlock]
  CodeBlock get customCodeBlock => _initCustomBlock();

  /// *Auto-initializing* access to the [customCodeBlock] via callback
  withCustomBlock(f(CodeBlock)) => f(customCodeBlock);

  /// Get the contents of the [CodeBlock] including both the *custom protect
  /// block* portion as well as any injected code (ie snippets)
  String taggedBlockText(String tag) => _customCodeBlock != null
      ? (_customCodeBlock..tag = (includesCustom ? tag : null)).toString()
      : '';

  CodeBlock _initCustomBlock() {
    if (_customCodeBlock == null) {
      _customCodeBlock = new CodeBlock(null);
    }
    return _customCodeBlock;
  }

  /// Set the tag associated with the custom block
  set tag(String protectBlockTag) {
    if (protectBlockTag != null && protectBlockTag.isNotEmpty) {
      includesCustom = true;
    }
    customCodeBlock.tag = protectBlockTag;
  }

  /// Get the tag associated with the custom block
  ///
  /// Note: calling this auto-initialized the customCodeBlock
  get tag => customCodeBlock.tag;

  // end <class CustomCodeBlock>

  bool _includesCustom;
  CodeBlock _customCodeBlock = new CodeBlock(null);
}

/// Wraps an optional protection block with optional code injection
///
/// [CodeBlock]s have two functions, they provide an opportunity
/// to include hand written code with a protection block and they
/// provide specific target locations for injecting generated code.
///
/// For contrived example, assume there were two variables, *topCodeBlock*
/// and *bottomCodeBlock* of type CodeBlock and they were used in a
/// context like this:
///
///     """
///     class Imaginary {
///       ${topCodeBlock}
///     ....
///       ${bottomCodeBlock}
///     }
///     """
///
/// The generated text might look like:
///     """
///     class Imaginary {
///       /// custom begin top
///       /// custom end top
///     ....
///       /// custom begin bottom
///       /// custom end bottom
///     }
///     """
///
/// Now assume a code generator needed to inject into the top portion
/// something specific to the class, like a versionId stored in a file and
/// available during code generation:
///
///     topCodeBlock
///     .snippets
///     .add("versionId = ${new File(version.txt).readAsStringSync()}")
///
/// the newly generated code might look like:
///
///     """
///     class Imaginary {
///       /// custom begin top
///       /// custom end top
///       versionId = "0.1.21";
///     ...
///       /// custom begin bottom
///       /// custom end bottom
///     }
///     """
///
/// and adding:
///
///     topCodeBlock.hasSnippetsFirst = true
///
/// would give:
///
///     """
///     class Imaginary {
///       versionId = "0.1.21";
///       /// custom begin top
///       /// custom end top
///     ...
///       /// custom begin bottom
///       /// custom end bottom
///     }
///     """
class CodeBlock {
  CodeBlock(this.tag);

  /// Tag for protect block. If present includes protect block
  String tag;
  /// Effecitively a hook to throw in generated text
  List<String> snippets = [];
  /// Determines whether the injected code snippets come before the
  /// protection block or after
  bool hasSnippetsFirst = false;

  // custom <class CodeBlock>

  /// Returns true if has [tag] string that is not empty
  bool get hasTag => tag != null && tag.length > 0;

  /// Returns true if [hasTag] or has snippets content
  bool get hasContent => hasTag || snippets.isNotEmpty;

  String toString() {
    if (hasTag) {
      return hasSnippetsFirst
          ? brCompact([snippets, customBlock(tag)])
          : br([customBlock(tag)]..add(brCompact(snippets)));
    }
    return combine(snippets);
  }

  // end <class CodeBlock>

}

/// Create a CodeBlock sans new, for more declarative construction
CodeBlock codeBlock([String tag]) => new CodeBlock(tag);

// custom <part code_block>
// end <part code_block>
