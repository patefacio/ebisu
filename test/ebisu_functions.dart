library ebisu_functions;
import "package:ebisu/ebisu.dart";

main() {
  print(':${chomp("This is a test\n\n")}:');
  print(':${chomp("This is a test\n\n", true)}:');
}