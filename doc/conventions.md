
### with.*(...)

One of the goals of this setup for code generation is to make it as
declarative as possible. To that end, there is a push for
fluidity. Dart cascades are excelletn for this. However, there are
some times where a little extra coding will add to the
fluidity. Consider:

final myLib = lib('my_lib')
  ..headers = [
    header('my_header')
    ..classes = [
      class_('my_class')
      ..members = [
        member('my_member'),
      ]
      ..getCodeBlock(clsPublic).snippets.add(['// some public section code'])
      ..getCodeBlock(clsPublic).snippets.add(['// some more public section code'])
      ..getCodeBlock(clsPublic).snippets.add(['// even more public section code'])
    ]
  ];

There is not an easy way to start a sub-cascade chain, so that there
is not repitition of the calls to *getCodeBlock*. This is the purpose
of the *with...(...)* convention. In this case class has a
*withCustomBlock* method which simply returns the initialized instance
of the desired custom block.

final myLib = lib('my_lib')
  ..headers = [
    header('my_header')
    ..classes = [
      class_('my_class')
      ..members = [
        member('my_member'),
      ]
      ..withCustomBlock(clsPublic, (codeBlock) {
         codeBlock.snippets
           ..add(['// some public section code'])
           ..add(['// some more public section code'])
           ..add(['// even more public section code']);
      })
    ]
  ];
