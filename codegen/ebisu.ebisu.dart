import "dart:io";
import "package:path/path.dart" as path;
import "package:ebisu/ebisu.dart";
import "package:id/id.dart";
import "package:ebisu/ebisu_dart_meta.dart";
import "package:ebisu/ebisu_compiler.dart";

String _topDir;

void main() {

  Options options = new Options();
  String here = path.absolute(options.script);
  bool noCompile = options.arguments.contains('--no_compile');
  bool compileOnly = options.arguments.contains('--compile_only');
  _topDir = path.dirname(path.dirname(here));
  String templateFolderPath = 
    path.join(_topDir, 'lib', 'templates', 'dart_meta');
  if(! (new Directory(templateFolderPath).existsSync())) {
    throw new StateError(
        "Could not find ebisu templates in $templateFolderPath");
  }

  if(!noCompile) {
    TemplateFolder templateFolder = new TemplateFolder(templateFolderPath);
    int filesUpdated = templateFolder.compile();
    if(filesUpdated>0) {
      if(!noCompile && !compileOnly) {
        // Files were updated, since Dart does not have eval, call again to same
        // script using updated templates
        print("$filesUpdated files updated...rerunning");
        List<String> args = [ options.script, '--no_compile' ]
          ..addAll(options.arguments);
        print("Args are " + args.toString());
        Process.run('dart', args).then((ProcessResult results) {
          print(results.stdout);
          print(results.stderr);
        });
      }
    } else {
      if(!compileOnly)
        generate();
    }
  } else {
    generate();
  }
}

generate() {

  Library ebisu_compiler = library('ebisu_compiler');
  ebisu_compiler..doc = '''

Supports generating dart code from template files.  A choice had to be made
about a templating system. Originally dart had a library to support templates
but it was later abandoned in preference for a new approach (_Web UI_) that does
much more than just templating as it is a very web specific solution. Mustache
is another good option, but for code generation the arguments for separating
templates and logic fall apart (the coders are the ones writing the templates to
make their life of coding easier). Rather than try to incorporate one in NIH/DIY
fashion a very simple template engine is provided here. The rules for templating
are simple:

- Template file is line based (each line is a comment, code or template text)
- _#<# dart comment here >_
- _#< dart code here >_
- All template text is wrapped in tripple quotes.


'''
    ..includeLogger = true
    ..imports = [
      'io',
      '"package:ebisu/ebisu.dart"',
      '"package:ebisu/ebisu_dart_meta.dart"',
      '"package:path/path.dart" as path',
    ]
    ..variables = [
      variable('code_re')
      ..doc = 'Regex to match a single line if dart code (i.e. in looks like #< ... >)'
      ..type = 'RegExp'
      ..isFinal = true
      ..init = r'new RegExp("^#<(.*)>\\s*")',
      variable('comment_re')
      ..doc = 'Regex to match the comment portion of a comment line (i.e. in looks like #<# ... >)'
      ..type = 'RegExp'
      ..isFinal = true
      ..init = r'new RegExp("^\\s*#")',
    ]
    ..parts = [
      part('compiler')
      ..classes = [
        class_('template_file')
        ..doc = 'A file with ".tmpl" extension containing mixed dart code and text that can be "realized" by the template engine'
        ..ctorSansNew = true
        ..members = [
          member('input_path')
          ..doc = 'Path to file containting template code'
          ..ctors = [ '' ],
          member('output_path')
          ..doc = 'Path to write the supporting dart file for the template'
          ..ctorsNamed = [ '' ],
          member('part_of')
          ..doc = 'Name of library this "part" is a part of'
          ..ctorsNamed = [ '' ],
          member('function_name')
          ..access = Access.RO
        ],
        class_('template_folder')
        ..doc = '''A class to process a folder full of templates, 
all of which get compiled into a single dart library'''
        ..members = [
          member('input_path')
          ..doc = 'Path to folder of templates'
          ..ctors = [ 'default' ],
          member('output_path')
          ..ctorsOpt = [ 'default' ]
          ..doc = 'Path to write the supporting dart files for the template folder',
          member('lib_name')
          ..ctorsOpt = [ 'default' ]
          ..doc = 'Name of dart library to be generated',
          member('imports')
          ..doc = 'List of imports required by the generated dart library'
          ..type = 'List<String>'
          ..classInit = '[]',
        ]
      ]
    ];

  Library ebisu_utils = library('ebisu_utils')
    ..imports = [ 'math', "'dart:json' as JSON" ]
    ..includeLogger = true
    ..doc = 'Support code to be used by libraries generated with ebisu. Example (toJson)';

  // The following are commonly used members of the meta data classes
  Member doc_member(String owner) => member('doc')
    ..doc = "Documentation for this $owner";

  Member public_member(String owner) => member('is_public')
    ..doc = "True if $owner is public.\nCode generation support will prefix private variables appropriately"
    ..type = 'bool'
    ..classInit = 'true';

  Member id_member(String owner) => member('id')
    ..doc = "Id for this $owner"
    ..type = 'Id'
    ..access = Access.RO
    ..ctors = ['']
    ..isFinal = true;

  Member non_final_id_member(String owner) => member('id')
    ..doc = "Id for this $owner"
    ..type = 'Id'
    ..access = Access.RO;

  Member parent_member(String owner) => member('parent')
    ..doc = "Reference to parent of this $owner"
    ..type = 'dynamic'
    ..jsonTransient = true
    ..access = Access.RO;

  Member custom_member(String owner) => member('include_custom')
    ..doc = "If true a custom section will be included for $owner"
    ..type = 'bool'
    ..classInit = 'true';

  Library ebisu_dart_meta = library('ebisu_dart_meta')
    ..doc = '''

Support for storing dart meta data for purpose of generating code. Essentially
this is a model of structural code items that comprise dart systems. Things like
libraries (Library), classes (Class), class members (Member), pubspecs
(PubSpec), etc. A very nice feature of Dart is the dot-dot _.._ operator, which
allows one to conveniently string together accessor calls to objects. For
example, the following is the structure of the imported id library.

      library('id')
      ..doc = '...'
      ..includeLogger = true
      ..imports = [
        'dart:convert'
      ]
      ..classes = [
        class_('id')
        ..doc = "Given an id (all lower case string of words separated by '_')..."
        ..ctorSansNew = true
        ..members = [
          member('id')
          ..doc = "String containing the lower case words separated by '_'"
          ..access = Access.RO
          ..isFinal = true,
          member('words')
          ..doc = "Words comprising the id"
          ..type = 'List<String>'
          ..access = Access.RO
          ..isFinal = true
        ]
      ]
    ];


The libraries are composed into a system and the system is generated. So, all
the code structure in ebisu was generated by itself. Code generation of this
sort is much more useful in the more verbose languages like C++ where things
like ORM, object serialization, object streaming etc are very
boilerplate. However some good use cases exist in Dart, like generating the
structure of a large Dart library from an existing spec or data input
(e.g. imagine trying to create a Dart library to support a FIX specification
which is stored in XML). A simple use that is provided as an extension is the
ability take a simple Altova UML model in XMI format and convert it to Dart
classes with JSON support.

'''
    ..imports = [
      'io', 'json', 
      '"package:ebisu/ebisu.dart"', 
      '"package:id/id.dart"', 
      '"package:ebisu/ebisu_utils.dart" as EBISU_UTILS', 
      '"templates/dart_meta.dart" as META',
    ]
    ..includeLogger = true
    ..parts = [
      part('dart_meta')
      ..enums = [
        enum_('access')
        ..doc = 'Access for member variable - ia - inaccessible, ro - read/only, rw read/write'
        ..values = [
          id('ia'), id('ro'), id('rw')
        ],
        enum_('pub_dep_type')
        ..doc = 'Dependency type of a PubDependency '
        ..values = [
          id('path'), id('git'), id('hosted')
        ],
      ]
      ..classes = [
        class_('variable')
        ..members = [
          id_member('variable'),
          doc_member('variable'),
          parent_member('variable'),
          public_member('variable'),
          member('type')
          ..doc = 'Type for the variable'
          ..type = 'String'
          ..classInit = 'dynamic',
          member('init')
          ..doc = '''Text used to initialize the variable
(e.g. 'DateTime(1929, 10, 29)' for <DateTime crashDate = DateTime(1929, 10, 29)>
''',
          member('is_final')
          ..doc = 'True if the variable is final'
          ..type = 'bool'
          ..classInit = 'false',
          member('is_const')
          ..doc = 'True if the variable is const'
          ..type = 'bool'
          ..classInit = 'false',
          member('is_static')
          ..doc = 'True if the variable is static'
          ..type = 'bool'
          ..classInit = 'false',
          member('name')
          ..doc = "Name of the enum class generated sans access prefix"
          ..access = Access.RO,
          member('var_name')
          ..doc = 'Name of variable - varies depending on public/private'
          ..access = Access.RO,
        ],
        class_('enum')
        ..doc = '''Defines an enum - to be generated idiomatically as a class
See (http://stackoverflow.com/questions/13899928/does-dart-support-enumerations)
At some point when true enums are provided this may be revisited.
'''
        ..members = [
          id_member('enum'),
          doc_member('enum'),
          public_member('enum'),
          parent_member('enum'),
          member('values')
          ..doc = "List of id's naming the values"
          ..type = 'List<Id>'
          ..classInit = '[]',
          member('json_support')
          ..doc = "If true, generate toJson/fromJson on wrapper class"
          ..type = 'bool'
          ..classInit = 'false',
          member('name')
          ..doc = "Name of the enum class generated sans access prefix"
          ..access = Access.RO,
          member('enum_name')
          ..doc = "Name of the enum class generated with access prefix"
          ..access = Access.RO,
          member('has_custom')
          ..doc = 'If true includes custom block for additional user supplied ctor code'
          ..type = 'bool'
          ..classInit = 'false',
          member('is_snake_string')
          ..doc = 'If true string value for each entry is snake case (default is shout)'
          ..type = 'bool'
          ..classInit = 'false',
        ],
        class_('pub_dependency')
        ..doc = 'A dependency of the system'
        ..members = [
          member('name')
          ..doc = 'Name of dependency',
          member('version')
          ..doc = 'Required version for this dependency'
          ..classInit = 'any',
          member('path')
          ..doc = "Path to package, infers package type for git (git:...), hosted (http:...), path ",
          member('git_ref')
          ..doc = "Git reference",
          member('type')
          ..doc = "Type for the pub dependency"
          ..type = 'PubDepType'
          ..access = IA,
          member('pub_type_re')
          ..type = 'RegExp'
          ..isFinal = true
          ..classInit = 'new RegExp(r"(git:|http:|[\./.])")'
        ],
        class_('pub_spec')
        ..doc = 'Information for the pubspec of the system'
        ..members = [
          id_member('pub spec'),
          doc_member('pub spec'),
          parent_member('pub spec'),
          member('version')
          ..doc = 'Version for this package'
          ..classInit = '0.0.1',
          member('name')
          ..doc = "Name of the project described in spec - if not set, id of system is used to generate",
          member('author')
          ..doc = "Author of the pub package",
          member('homepage')
          ..doc = "Homepage of the pub package",
          member('dependencies')
          ..type = 'List<PubDependency>'
          ..classInit = '[]',
          member('dev_dependencies')
          ..type = 'List<PubDependency>'
          ..classInit = '[]',
        ],
        class_('system')
        ..doc = 'Defines a dart system (collection of libraries and apps)'
        ..members = [
          non_final_id_member('system'),
          doc_member('system'),
          member('root_path')
          ..doc = 'Path to which code is generated',
          member('scripts')
          ..doc = 'Scripts in the system'
          ..type = 'List<Script>'
          ..classInit = '[]',
          member('app')
          ..doc = 'App for this package'
          ..type = 'App',
          member('test_libraries')
          ..doc = 'List of test libraries of this app'
          ..type = 'List<Library>'
          ..classInit = '[]',
          member('libraries')
          ..doc = 'Libraries in the system'
          ..type = 'List<Library>'
          ..classInit = '[]',
          member('all_libraries')
          ..doc = 'Regular and test libraries'
          ..type = 'List<Library>'
          ..classInit = '[]',
          member('pub_spec')
          ..doc = 'Information for the pubspec'
          ..type = 'PubSpec',
          member('jsonable_classes')
          ..doc = 'Map of all classes that have jsonSupport'
          ..type = 'Map<String,Class>'
          ..classInit = '{}',
          member('finalized')
          ..doc = 'Set to true on finalize'
          ..access = Access.RO
          ..type = 'bool'
          ..classInit = 'false',
          member('generate_pub_spec')
          ..doc = 'If true generate a pubspec.xml file'
          ..type = 'bool'
          ..classInit = 'true',
          member('license')
          ..doc = 'If found in licenseMap, value is used, else license is used',
          member('include_readme')
          ..doc = 'If true standard outline for readme provided'
          ..type = 'bool'
          ..classInit = 'false',
          member('include_hop')
          ..doc = 'If true generates tool folder with hop_runner'
          ..type = 'bool'
          ..classInit = 'false',
        ],
        class_('test')
        ..doc = 'A test generated in a standard format',
        class_('script_arg')
        ..doc = 'An agrument to a script'
        ..members = [
          id_member('script argument'),
          doc_member('script argument'),
          parent_member('script argument'),
          member('name')
          ..doc = 'Name of the the arg (emacs naming convention)'
          ..access = Access.RO,
          member('is_required')
          ..doc = 'If true the argument is required'
          ..type = 'bool'
          ..classInit = 'false',
          member('is_flag')
          ..doc = 'If true this argument is a boolean flag (i.e. no option is required)'
          ..type = 'bool'
          ..classInit = 'false',
          member('is_multiple')
          ..doc = 'If true the argument may be specified mutiple times'
          ..type = 'bool'
          ..classInit = 'false',
          member('defaults_to')
          ..doc = 'Used to initialize the value in case not set'
          ..type = 'dynamic',
          member('allowed')
          ..doc = 'A list of allowed values to choose from'
          ..type = 'List<String>'
          ..classInit = '[]',
          member('position')
          ..doc = 'If not null - holds the position of a positional (i.e. unnamed) argument'
          ..type = 'int',
          member('abbr')
          ..doc = 'An abbreviation (single character)'
        ],
        class_('script')
        ..doc = 'A typical script - (i.e. like a bash/python/ruby script but in dart)'
        ..members = [
          id_member('script'),
          doc_member('script'),
          parent_member('script'),
          custom_member('script'),
          member('imports')
          ..doc = 'List of imports to be included by this script'
          ..type = 'List<String>'
          ..classInit = '[]',
          member('args')
          ..doc = 'Arguments for this script'
          ..type = 'List<ScriptArg>'
          ..classInit = '[]',
        ],
        class_('app')
        ..doc = 'Defines a dart *web* application. For non-web console app, use Script'
        ..members = [
          id_member('app'),
          doc_member('app'),
          parent_member('app'),
          custom_member('app'),
          member('classes')
          ..doc = 'Classes defined in this app'
          ..type = 'List<Class>'
          ..classInit = '[]',
          member('dependencies')
          ..type = 'List<PubDependency>'
          ..classInit = '[]',
          member('libraries')
          ..doc = 'List of libraries of this app'
          ..type = 'List<Library>'
          ..classInit = '[]',
          member('variables')
          ..doc = 'List of global variables for this library'
          ..type = 'List<Variable>'
          ..classInit = '[]',
          member('is_web_ui')
          ..doc = 'If true this is a web ui app'
          ..type = 'bool'
          ..classInit = 'false',
        ],
        class_('library')
        ..doc = "Defines a dart library - a collection of parts"
        ..members = [
          id_member('library'),
          doc_member('library'),
          parent_member('library'),
          custom_member('library'),
          member('imports')
          ..doc = 'List of imports to be included by this library'
          ..type = 'List<String>'
          ..classInit = '[]',
          member('parts')
          ..doc = 'List of parts in this library'
          ..type = 'List<Part>'
          ..classInit = '[]',
          member('variables')
          ..doc = 'List of global variables for this library'
          ..type = 'List<Variable>'
          ..classInit = '[]',
          member('classes')
          ..doc = 'Classes defined in this library'
          ..type = 'List<Class>'
          ..classInit = '[]',
          member('enums')
          ..doc = 'Enums defined in this library'
          ..type = 'List<Enum>'
          ..classInit = '[]',
          member('name')
          ..doc = "Name of the library - for use in naming the library file, the 'library' and 'part of' statements"
          ..access = Access.RO,
          member('include_logger')
          ..doc = 'If true includes logging support and a _logger'
          ..type = 'bool'
          ..classInit = 'false',
          member('is_test')
          ..doc = 'If true this library is a test library to appear in test folder'
          ..type = 'bool'
          ..classInit = 'false',
          member('include_main')
          ..doc = 'If true a main is included in the library file'
          ..type = 'bool'
          ..classInit = 'false',
        ],
        class_('part')
        ..doc = "Defines a dart part - as in 'part of' source file"
        ..members = [
          id_member('part'),
          doc_member('part'),
          parent_member('part'),
          custom_member('app'),
          member('classes')
          ..doc = 'Classes defined in this part of the library'
          ..type = 'List<Class>'
          ..classInit = '[]',
          member('enums')
          ..doc = 'Enums defined in this part of the library'
          ..type = 'List<Enum>'
          ..classInit = '[]',
          member('name')
          ..doc = "Name of the part - for use in naming the part file"
          ..access = Access.RO,
          member('file_path')
          ..doc = "Path to the generated part dart file"
          ..access = Access.RO,
        ],
        class_('class')
        ..doc = 'Metadata associated with a Dart class'
        ..members = [
          id_member('Dart class'),
          doc_member('Dart class'),
          parent_member('Dart class'),
          public_member('Dart class'),
          member('mixins')
          ..doc = 'List of mixins'
          ..type = 'List<String>'
          ..classInit = '[]',
          member('extend')
          ..doc = 'Any extends (NOTE extend not extends) declaration for the class - conflicts with mixin'
          ..type = 'String',
          member('implement')
          ..doc = 'Any implements (NOTE implement not implements)'
          ..type = 'List<String>'
          ..classInit = '[]',
          custom_member('Dart class'),
          member('default_member_access')
          ..doc = 'Default access for members'
          ..classInit = 'Access.RW'
          ..type = 'Access',
          member('members')
          ..doc = 'List of members of this class'
          ..type = 'List<Member>'
          ..classInit = '[]',
          member('ctor_customs')
          ..doc = 'List of ctors requiring custom block'
          ..type = 'List<String>'
          ..classInit = '[]',
          member('ctor_const')
          ..doc = 'List of ctors that should be const'
          ..type = 'List<String>'
          ..classInit = '[]',
          member('ctors')
          ..doc = 'List of ctors of this class'
          ..type = 'Map<String,Ctor>'
          ..classInit = '{}'
          ..access = Access.RO,
          member('is_abstract')
          ..doc = "If true, class is abstract"
          ..type = 'bool'
          ..classInit = 'false',
          member('to_json_support')
          ..doc = "If true, generate toJson"
          ..type = 'bool'
          ..classInit = 'false',
          member('ctor_sans_new')
          ..doc = "If true creates library functions to construct forwarding to ctors"
          ..type = 'bool'
          ..classInit = 'false',
          member('json_support')
          ..doc = "If true, generate toJson/fromJson on all members that are not jsonTransient"
          ..type = 'bool'
          ..classInit = 'false',
          member('name')
          ..doc = "Name of the class - sans any access prefix (i.e. no '_')"
          ..access = Access.RO,
          member('class_name')
          ..doc = "Name of the class, including access prefix"
          ..access = Access.RO,
        ],
        class_('ctor')
        ..doc = 'Metadata associated with a constructor'
        ..members = [
          member('class_name')
          ..doc = "Name of the class of this ctor.",
          member('name')
          ..doc = "Name of the ctor. If 'default' generated as name of class, otherwise as CLASS.NAME()",
          member('members')
          ..doc = 'List of members initialized in this ctor'
          ..type = 'List<Member>'
          ..classInit = '[]',
          member('opt_members')
          ..doc = 'List of optional members initialized in this ctor (i.e. those in [])'
          ..type = 'List<Member>'
          ..classInit = '[]',
          member('named_members')
          ..doc = 'List of optional members initialized in this ctor (i.e. those in {})'
          ..type = 'List<Member>'
          ..classInit = '[]',
          member('has_custom')
          ..doc = 'If true includes custom block for additional user supplied ctor code'
          ..type = 'bool'
          ..classInit = 'false',
          member('is_const')
          ..doc = 'True if the variable is const'
          ..type = 'bool'
          ..classInit = 'false',
        ],
        class_('member')
        ..doc = 'Metadata associated with a member of a Dart class'
        ..members = [
          id_member('class member'),
          doc_member('class member'),
          parent_member('class member'),
          member('type')
          ..doc = 'Type of the member'
          ..type = 'String'
          ..classInit = 'String',
          member('access')
          ..doc = 'Access level supported for this member'
          ..type = 'Access',
          member('class_init')
          ..doc = "If provided the member will be initialized to this text in place of declaration of class",
          member('ctor_init')
          ..doc = "If provided the member will be initialized to this text in generated ctor initializers",
          member('ctors')
          ..doc = "List of ctor names to include this member in"
          ..type = 'List<String>'
          ..classInit = '[]',
          member('ctors_opt')
          ..doc = "List of ctor names to include this member in as optional parameter"
          ..type = 'List<String>'
          ..classInit = '[]',
          member('ctors_named')
          ..doc = "List of ctor names to include this member in as named optional parameter"
          ..type = 'List<String>'
          ..classInit = '[]',
          member('is_final')
          ..doc = 'True if the member is final'
          ..type = 'bool'
          ..classInit = 'false',
          member('is_const')
          ..doc = 'True if the member is const'
          ..type = 'bool'
          ..classInit = 'false',
          member('is_static')
          ..doc = 'True if the member is static'
          ..type = 'bool'
          ..classInit = 'false',
          member('json_transient')
          ..doc = 'True if the member should not be serialized if the parent class has jsonSupport'
          ..type = 'bool'
          ..classInit = 'false',
          member('name')
          ..doc = "Name of variable for the member, excluding access prefix (i.e. no '_')"
          ..access = Access.RO,
          member('var_name')
          ..doc = 'Name of variable for the member - varies depending on public/private'
          ..access = Access.RO,
        ]
      ]
    ];

  System ebisu = system('ebisu')
    ..rootPath = _topDir
    ..pubSpec = (pubspec('ebisu')
        ..doc = '''
A library that supports code generation of the structure Dart (and potentially
other languages like D) using a fairly declarative aproach.
'''
        ..dependencies = [
          pubdep('path'),
        ]
                 )
    ..libraries = [
      library('ebisu')
      ..doc = 'Primary library for client usage of ebisu'
      ..includeLogger = true
      ..variables = [
        variable('ebisu_path')
        ..doc = 'Path to this package - for use until this becomes a pub package'
        ..isFinal = true
        ..init = "Platform.environment['EBISU_PATH']",
        variable('ebisu_author')
        ..doc = 'Author of the generated code'
        ..isFinal = true
        ..init = "Platform.environment['EBISU_AUTHOR']",
        variable('ebisu_homepage')
        ..doc = 'Hompage for pubspec'
        ..isFinal = true
        ..init = "Platform.environment['EBISU_HOMEPAGE']",
        variable('license_map')
        ..init = '''
{
   'boost' : 'License: <a href="http://www.boost.org/LICENSE_1_0.txt">Boost License 1.0</a>'
}
'''

      ]
      ..imports = [
        'io',
        '"package:path/path.dart" as path'
      ]
      ..parts = [
        part('ebisu')
        ..classes = [
          class_('context')
          ..doc = "Convenience wrapper for a map - passed into templates as variable '_'"
          ..members = [
            member('data')
            ..isFinal = true
            ..doc = "Data being wrapped"
            ..type = 'Map'
            ..access = Access.RO
          ]
        ]
      ],
      ebisu_compiler,
      ebisu_dart_meta,
      ebisu_utils
    ];

  ebisu_dart_meta.parts.forEach((part) {
    part.classes.forEach((c) {
      c.toJsonSupport = true;
    });
  });

  ebisu.generate();
}