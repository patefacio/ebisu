# Ebisu

![Build Status](https://travis-ci.org/patefacio/ebisu.svg)

A library supporting code generation of Dart pub packages and many constituent assets.

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

```dart
 class_('schema_node')
 ..doc = 'Represents one node in the schema diagram'
 ..members = [
   member('schema')
   ..doc = 'Referenced schema this node portrays'
   ..type = 'Schema',
   member('links')
   ..doc = 'List of links (resulting in graph edge) from this node to another'
   ..type = 'List<String>'
 ];
```

That declaration snippet will define a class called _SchemNode_ with two members
_schema_ of type _Schema_ and _links_ of type _List_. The _doc_ attribute is a
common way of providing descriptions for { _classes_, _members_, _variables_,
_pubSpec_ } and appear as document comments.

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

```dart
    // custom <TAG>
       ... Custom text here ...
    // end <TAG>
```    

All other code will be rewritten on code generation. Keep in mind that the
protection blocks are predefined in the libraries and templates, so the user
never attempts to create a custom block directly in generated code.

### Regeneration

When code is regenerated, this library creates the text to be written to the
file and matches up all protection blocks with those existing in the target file
on disk. It first does the merge of generated and custom text in memory and then
compares that to the full contents on disk. If there is no change in the
contents of the file, a message like the following will be output:

```bash
    No change: .../library/foo.dart
```    

If the regeneration results in a change, due to new *code assets* having been
added to the definition or less frequently due to changes in the ebisu
library/templates, a message like the following will be output:

```bash
    Wrote: .../library/foo.dart
```    

### Json Support

One of the benefits of code generation is it allows for easy addition
of boilerplate code. One such example is json serialization
support. Of course, there already exists a _serialization_ library,
which may be a good solotion. However, that does have dependencies on
mirrors and is a rather heavy weight solution.

So, adding _hasJsonSupport = true_ in the following ebisu declaration:

```dart
 class_('point')
 ..hasJsonSupport = true
 ..members = [
   member('x')..classInit = 0.0,
   member('y')..classInit = 0.0,      
 ],
```

will generate these additional methods for the _Point_ class:

```dart
 Map toJson() {
   return {
   "x": ebisu.toJson(x),
   "y": ebisu.toJson(y),
   };
 }

 static Point fromJson(String json) {
   Map jsonMap = ebisu.decodeJson(json);
   Point result = new Point();
   result._fromJsonMapImpl(jsonMap);
   return result;
 }

 static Point fromJsonMap(Map jsonMap) {
   Point result = new Point();
   result._fromJsonMapImpl(jsonMap);
   return result;
 }

 void _fromJsonMapImpl(Map jsonMap) {
   x = jsonMap["x"];
   y = jsonMap["y"];
 }
```

### Special Environment Variables

The following environment variables have special meaning:

    | variable           | meaning                                               |
    |--------------------+-------------------------------------------------------|
    | EBISU_AUTHOR       | If set, generated pubspecs will use this for author   |
    | EBISU_HOMEPAGE     | If set, generated pubspecs will use this for homepage |
    | EBISU_PUB_VERSIONS | Specifies a config file for overriding versions       |


The _EBISU\_PUB\_VERSIONS_ is a way to leverage the code generation
support which already generates pubspecs to overcome one of the
current shortcomings of _pub_. Sometimes it is desirable to set a
specific package to a local path for development. As the web of
dependencies grows the difficulty of keeping it straight also
grows. In order to set a package to a local path, that path must be
set to the same source in all pubspecs encountered in the transitive
closure. If it happens to be a package you are working on, it would be
nice to be able to change the pubspec entry in one place, regenerate,
and have all pubspecs updated to point to the same place.

The format of this file is a json instance with a "versions" key
outlining the versions to override. Each property in the _versions_
object must be the name of a package to override, and the value must
be an object with an entry that is either a "_path_" or "_version_"
specification. An example override file is:

```json
 {
   "versions" : {
     "id" : { "path" : "/Users/dbdavidson/dev/open_source/id" },
     "ebisu" : { "path" : "/Users/dbdavidson/dev/open_source/ebisu" },
     "ebisu_web_ui" : { "path" : "/Users/dbdavidson/dev/open_source/ebisu_web_ui" },
     "json_schema" : { "version" : ">=0.0.2" },
     "hop" : { "version" : ">=0.24.4" },
     "logging" : { "version" : ">=0.7.1" },
     "args" : { "version": ">=0.7.1" },
     "unittest" : { "version": ">=0.7.1" },
     "path" : { "version" : ">=0.7.1" }
   }
 }
```    

If this file exists as _~/.ebisu\_pub\_versions.json_ or in a file
referenced by environment variable _EBISU\_PUB\_VERSIONS_ then those
overrides will take effect and any generated puspecs will have those
versions if present.


# Examples

## A Toy Example

### my\_pub\_package

In the _example_ folder of this project there is a folder called _my\_pub\_package_ which shows one way to generate code. A typical approach is:

- Select a snake case name for the package (e.g. _my\_pub\_package_)
- Create a folder of that name where you want that package to exist
- Create a folder in there called _codegen_
- Create a dart script to generate the code you want. A reasonable convention for naming the file is *package\_name*.ebisu.dart. So the ebisu script for this example is: [my\_pub\_package.ebisu.dart](https://github.com/patefacio/ebisu/blob/master/example/my_pub_package/codegen/my_pub_package.ebisu.dart)
- Run that file to generate the package code and other assets

After code generation, _pub publish -n_ looks like the following:

    |-- LICENSE
    |-- README.md
    |-- codegen
    |   '-- my_pub_package.ebisu.dart
    |-- lib
    |   |-- multi_part.dart
    |   |-- self_contained.dart
    |   '-- src
    |       '-- multi_part
    |           |-- first_part.dart
    |           '-- second_part.dart
    |-- pubspec.yaml
    |-- test
    |   |-- runner.dart
    |   |-- test_it.dart
    |   '-- utils.dart
    '-- tool
        '-- hop_runner.dart

All files can be edited - *take care to only change code in custom blocks*. Regernating the code after editing within custom blocks will have no effect. Regenerating after modifying the _my\_pub\_package.ebisu.dart_ should cause the desired updates.


## A Real Example (Json Schema)

An example use of _ebisu_ to generate code structure can be found at
[Json Schema Codegen Bootstrap](https://github.com/patefacio/json_schema/blob/master/codegen/json_schema.ebisu.dart)

When this script is run it produces:

```bash
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
```    

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




