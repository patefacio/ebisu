/// Support for code blocks - markers for custom hand-written or code
/// generation injected code.
part of ebisu.ebisu;

/// Mixin to provide a common approach to adding custom code
class CustomCodeBlock {

  /// A custom code block for a class
  set customCodeBlock(CodeBlock customCodeBlock) =>
      _customCodeBlock = customCodeBlock;

  // custom <class CustomCodeBlock>

  bool get includesCustom => _customCodeBlock != null;

  set includesCustom(bool ic) {
    if (ic) {
      _initCustomBlock();
    } else {
      if (_customCodeBlock != null && _customCodeBlock.snippets.isNotEmpty) {
        _logger.warning('Custom code disabled for $runtimeType');
        _logger.warning('Snippets removed: ${br(_customCodeBlock.snippets)}');
      }
      _customCodeBlock = null;
    }
  }

  CodeBlock get customCodeBlock => _initCustomBlock();

  withCustomBlock(f(CodeBlock)) => f(customCodeBlock);

  CodeBlock _initCustomBlock() {
    if (_customCodeBlock == null) {
      _customCodeBlock = new CodeBlock(null);
    }
    return _customCodeBlock;
  }

  taggedBlockText(String tag) =>
      _customCodeBlock != null ? (_customCodeBlock..tag = tag).toString() : '';

  //_copyCodeBlock(String tag) =>

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
///       versionId = "0.1.21";
///       /// custom begin top
///       /// custom end top
///     ...
///       /// custom begin bottom
///       /// custom end bottom
///     }
///     """
///
///
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
