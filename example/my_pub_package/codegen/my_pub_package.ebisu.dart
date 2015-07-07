import "dart:io";
import "package:path/path.dart" as path;
import "package:ebisu/ebisu_dart_meta.dart";
import "package:logging/logging.dart";

String _topDir;
bool _loggingEnabled = false;

void main() {

  //////////////////////////////////////////////////////////////////////
  // Uncomment following for logging
  if(_loggingEnabled) {
    Logger.root.onRecord.listen((LogRecord r) =>
        print("${r.loggerName} [${r.level}]:\t${r.message}"));
  }

  String here = path.absolute(Platform.script.toFilePath());
  var topDir = path.dirname(path.dirname(here));
  System myPubPackage = system('my_pub_package')
    .. doc = '''
Simple example pub package composed of:
- A self-contained top level library with multiple classes and library variables
- A top level library with two parts and multiple classes
- Hop support
'''
    ..rootPath = topDir
    ..includesHop = true
    ..todos = [ 'Add some real code' ]
    ..license = 'boost'
    ..pubSpec.homepage = 'http://foo.com'
    ..pubSpec.doc = 'Just a toy, never see the light of day'
    ..testLibraries = [
      library('test_it')
    ]
    ..libraries = [
      library('self_contained')
      ..classes = [
        class_('address')
        ..hasJsonSupport = true
        ..doc = 'An address composed of zip, street and street number'
        ..members = [
          member('zip'),                         // Default type is String
          member('street'),
          member('street_number')..type = 'int',
        ],
        class_('address_book')
        ..hasJsonSupport = true
        ..members = [
          member('book')
          ..type = 'Map<String,Address>'
          ..classInit = '{}',
        ]
      ],
      library('multi_part')
      ..variables = [
        variable('global_var1')
        ..type = 'List<String>'
        ..isConst = true
        ..init = '["foo", "bar", "goo"]'
      ]
      ..parts = [
        part('first_part')
        ..classes = [
          class_('c11')
          ..members = [
            member('m1'),
            member('m2')
          ],
          class_('c12')
          ..members = [
            member('m1')..type = 'double',
            member('m2')..type = 'dynamic',
          ]
        ],
        part('second_part')
        ..classes = [
          class_('c21')
          ..members = [
            member('m1'),
            member('m2')
          ],
          class_('c22')
          ..members = [
            member('m1')..type = 'double',
            member('m2')..type = 'dynamic',
          ]
        ]
      ]
    ];

  myPubPackage.generate();

}