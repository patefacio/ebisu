/// Support for code blocks - markers for custom hand-written or code
/// generation injected code.
part of ebisu.ebisu;

/// Mixin to provide a common approach to adding custom code.
///
/// *Custom* in this context may be either hand-coded text in a *protection block*
/// or *injected* custom code.
///
/// This is a way for [Entity] objects, like [Part], [Library], [Ctor], etc, to
/// include a single [CodeBlock] allowing support for hand-written code (via the
/// *protect block* of [CodeBlock]) or injected code (via the [snippets] list within
/// the [CodeBlock]).
class CustomCodeBlock {
  /// A custom code block for a class
  set customCodeBlock(CodeBlock customCodeBlock) =>
      _customCodeBlock = customCodeBlock;

  // custom <class CustomCodeBlock>

  /// True iff the [CodeBlock] has been initialized and has a valid [tag]
  bool get includesProtectBlock =>
      _customCodeBlock != null && _customCodeBlock.tag != null;

  /// True iff the [CodeBlock] has been initialized and has some injected
  /// [snippets]
  bool get includesSnippets =>
      _customCodeBlock != null && _customCodeBlock.snippets.isNotEmpty;

  /// True if either [includesProtectBlock] or [includesSnippets]
  bool get includesContent => includesSnippets || includesProtectBlock;

  /// *Auto-initializing* access to the [customCodeBlock]
  CodeBlock get customCodeBlock => _initCustomBlock();

  /// *Auto-initializing* access to the [customCodeBlock] via callback
  withCustomBlock(f(CodeBlock)) => f(customCodeBlock);

  /// The text associated with the [CodeBlock] if iniialized, null otherwise
  get blockText => _customCodeBlock?.toString();

  /// Set the tag associated with the custom block
  ///
  /// Note: calling this auto-initialized the customCodeBlock
  set tag(String protectBlockTag) => customCodeBlock.tag = protectBlockTag;

  /// The tag associated with the [CodeBlock] if initialized, null otherwise
  get tag => _customCodeBlock?.tag;

  /// Returns true if the [CustomCodeBlock] has content which is true if the
  /// [CodeBlock] has been tagged or there is data in the [snippets]
  get hasContent => _customCodeBlock?.hasContent ?? false;

  /// Returns the list of snippets in the [CustomCodeBlock]
  ///
  /// Initializes the [CodeBlock] if not yet initialized
  get snippets => _initCustomBlock().snippets;

  CodeBlock _initCustomBlock() => _customCodeBlock ??= new CodeBlock(null);

  // end <class CustomCodeBlock>

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
///       versionId = "0.1.22";
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

  /// Returns [CodeBlock] text contents suitable for protection on regeneration
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

/// Create CodeBlock without new, for more declarative construction
CodeBlock codeBlock(String tag) => new CodeBlock(tag);

/// Same as code block but uses script style protection block
class ScriptCodeBlock extends CodeBlock {
  // custom <class ScriptCodeBlock>

  ScriptCodeBlock(tag) : super(tag);

  /// Returns [ScriptCodeBlock] text contents suitable for protection on regeneration using
  /// script style protection block
  String toString() {
    if (hasTag) {
      return hasSnippetsFirst
          ? brCompact([snippets, scriptCustomBlock(tag)])
          : br([scriptCustomBlock(tag)]..add(brCompact(snippets)));
    }
    return combine(snippets);
  }

  // end <class ScriptCodeBlock>

}

// custom <part code_block>
// end <part code_block>
