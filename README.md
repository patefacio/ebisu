# Ebisu


A library supporting code generation of Dart pub packages and many constituent assets.
<!--- custom <introduction> --->
<!--- end <introduction> --->


# Purpose
There are two potentially distinct purposes for this package. First, for those
wanting to keep consistency across Dart assets being developed, a declarative
approach to the specification of them as well as their subsequent generation is
provided for. This is soothing to people with extreme need for consistency and
can be helpful for those wanting strict structure for projects expected to grow
large.

A second purpose is for large scale data driven development efforts that are
highly structured/standardized. This library can be used to bootstrap their
development. 

Example:

- Model driven development. For example, suppose _Json Schema_ were used to
  define data models. This library could be used as a base to generate GUI
  supporting code.


## How It Works

This library does not attempt to allow for the generation of all aspects of Dart
code. Rather the focus is on generation of the structure of items along with
user ability to augment. These items or *code assets* include, but are not
limited to:

- Libraries
- Parts
- Scripts
- Classes
- Enumerations
- Members
- Variables

The idea is come up with a reasonable/good enough single approach that works in
defining the assets. Then provide enough flexibility to allow developers to do
what is needed (i.e. not be too restrictive). As more common patterns develop
support for them may be added. The hope is the benefit of consistency will
outweigh the need for creativity along the dimensions chosen for
generation. Ideally there will be little loss on the creativity front since the
concepts generated are pretty standardized already (e.g. location of library
files, where parts go and how they are laied out, where pubspec goes and its
contents, the layout of a class, ...etc)

For a small taste:

        class_('schema_node')
        ..members = [
          member('schema')
          ..type = 'Schema',
          member('links')
          ..type = 'List<String>'
        ]

That declaration snippet will define a class called _SchemNode_ with two members
_schema_ of type _Schema_ and _links_ of type _List_.

There are areas where the code generation gets a bit opinionated. For example,
members are either public or private and the naming convention is enforced - so
you do not need to name variables with an underscore prefix; that will be taken
care of. By default members are public, so to make them private just set
_isPublic = false_. But then, what about accessors. These are very boilerplate,
so the approach taken is to add a designation called _access_ for each member
which is one of:

- ReadWrite (_AccessType.RW_): In this case the field is public and no accessors
  are provided

- ReadOnly (_AccessType.RO_): In this case the field is private and the typical
  _get_ accessor is provided

- Inaccessible (_Accessor.IA_): In this case the field is private and no
  accessors are provided

The default access is _ReadWrite_.

### A Note on Naming

All assets are named, because they all end up in code with some form of file or
identifier associated with them. All identifer names are provided to
declarations in _snake\_case_ form. This is a hard rule, as the code generation
chooses the appropriate casing in the generated assets based on context. For
instance, the name _schema\_node_ is a class and therefore will be generated as
_SchemaNode_. Similarly, _schema\_node_ as a variable name would be generated
as _schemaNode_.

### Customization

Since the shell/structure is what is generated, there needs to be a way to add
user supplied code and have it mixin with what is generated. This is
accomplished with code protection blocks. Pretty much all *text* that appears
between blocks are protected.

    // custom <TAG>
       ... Custom text here ...
    // end <TAG>

All other code will be rewritten on code generation. Keep in mind that the
protection blocks are predefined in the libraries and templates, so the user
never attempts to create a custom block directly in generated code.

### Regeneration

When code is regenerated, this library creates the text to be written to the
file and matches up all protection blocks with those existing in the target file
on disk. It first does the merge of generated and custom text in memory and then
compares that to the full contents on disk. If there is no change in the
contents of the file, a message like the following will be output:
    
    No change: .../library/foo.dart

If the regeneration results in a change, due to new *code assets* having been
added to the definition or less frequently due to changes in the ebisu
library/templates, a message like the following will be output:

    Wrote: .../library/foo.dart


<!--- custom <purpose> --->
<!--- end <purpose> --->


<!--- custom <body> --->
<!--- end <body> --->


# Examples

<!--- custom <examples> --->

## A Toy Example



## A Real Example (Json Schema)

An example use of _ebisu_ to generate code structure can be found at
[Json Schema Codegen Bootstrap](https://github.com/patefacio/json_schema/blob/master/codegen/json_schema.ebisu.dart)

When this script is run it produces:

    Running: dart --checked --package-root=/Users/dbdavidson/dev/dart_packages/packages/ /Users/dbdavidson/dev/open_source/json_schema/codegen/json_schema.ebisu.dart
    No change: /Users/dbdavidson/dev/open_source/json_schema/bin/schemadot.dart
    No change: /Users/dbdavidson/dev/open_source/json_schema/lib/schema_dot.dart
    No change: /Users/dbdavidson/dev/open_source/json_schema/lib/json_schema.dart
    No change: /Users/dbdavidson/dev/open_source/json_schema/lib/src/json_schema/schema.dart
    No change: /Users/dbdavidson/dev/open_source/json_schema/lib/src/json_schema/validator.dart
    No change: /Users/dbdavidson/dev/open_source/json_schema/test/test_invalid_schemas.dart
    No change: /Users/dbdavidson/dev/open_source/json_schema/test/test_validation.dart
    No change: /Users/dbdavidson/dev/open_source/json_schema/pubspec.yaml
    No change: /Users/dbdavidson/dev/open_source/json_schema/.gitignore
    No change: /Users/dbdavidson/dev/open_source/json_schema/tool/hop_runner.dart
    No change: /Users/dbdavidson/dev/open_source/json_schema/test/utils.dart
    No change: /Users/dbdavidson/dev/open_source/json_schema/test/runner.dart

This script generates the following assets:

- *pubspec.yaml*: The script specifies _homepage_, _version_, _doc_, and any _dependencies_
- *json\_schema.dart*: The main library, broken into _parts_ => {_schema.dart_, _validation.dart_}
- *classes*: _Schema_ and _Validator_ with all constituent members
- *hop\_support*: _tool/hop\_runner.dart_, _test/utils.dart_, _test/runner.dart_
- *.gitignore*: Basic gititnore file
- two tests: _test\_invalid\_schemas.dart_ and _test\_validation.dart_
- *schema\_dott.dart*: library used to generate _Graphviz_ content for displaying image
- *schemadot.dart*: Script used to generate dot file from input _json schema_

In all these files it is the structure with as much of the content as
possible that is generated. But with code generation we will always
need to add additional custom code. Each of the files supports adding
additional content in the form of custom blocks wrapped in the
appropriate comment type for the file.

For example the _pubspec.yaml_ looks something like:

    name: json_schema
    version: 0.0.2
    author: Daniel Davidson
    homepage: https://github.com/patefacio/json_schema
    description: >
      Provide support for validating instances against json schema
    dependencies:
      path: ">=0.7.1"
    
      logging: ">=0.7.1"
    
    # custom <json_schema dependencies>
    
    # end <json_schema dependencies>
    
    dev_dependencies:
      unittest: ">=0.7.1"

      hop: ">=0.24.4"
    
    # custom <json_schema dev dependencies>
    
    # end <json_schema dev dependencies>


<!--- end <examples> --->


# Todos

- Add examples
<!--- custom <todos> --->
<!--- end <todos> --->


