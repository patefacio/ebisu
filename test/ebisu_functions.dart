library ebisu_functions;
import "package:ebisu/ebisu.dart";

main() {
  print(':${chomp("This is a test\n\n")}:');
  print(':${chomp("This is a test\n\n", true)}:');

  print(formatFill(
        ['void foo(', 
          'GobbledeeGook fingerPaint,',
          'SpookyCooky fenderBender,',
          'GlobalThermoNuclearWar ww3',
          ')']));

}