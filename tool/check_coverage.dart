// Fails if line coverage of the files whose path contains a given fragment
// is below a threshold.
//
//   dart run tool/check_coverage.dart coverage/lcov.info 90 /domain/
import 'dart:io';

void main(List<String> args) {
  if (args.length != 3) {
    stderr.writeln('usage: check_coverage.dart <lcov file> <minimum percent> <path fragment>');
    exit(64);
  }
  final minimum = double.parse(args[1]);
  final fragment = args[2];

  var found = 0, hit = 0;
  final perFile = <String, (int, int)>{};
  String? file;
  var fileFound = 0, fileHit = 0;
  for (final line in File(args[0]).readAsLinesSync()) {
    if (line.startsWith('SF:')) {
      file = line.substring(3).replaceAll(r'\', '/');
      fileFound = 0;
      fileHit = 0;
    } else if (line.startsWith('DA:')) {
      fileFound++;
      if (!line.endsWith(',0')) fileHit++;
    } else if (line == 'end_of_record' && file != null && file.contains(fragment)) {
      perFile[file] = (fileHit, fileFound);
      found += fileFound;
      hit += fileHit;
    }
  }

  if (found == 0) {
    stderr.writeln('No covered lines found for "$fragment".');
    exit(1);
  }
  for (final entry in perFile.entries) {
    final (h, f) = entry.value;
    stdout.writeln('${(100 * h / f).toStringAsFixed(1).padLeft(5)}%  ${entry.key}');
  }
  final percent = 100 * hit / found;
  stdout.writeln('Coverage of "$fragment": ${percent.toStringAsFixed(1)}% ($hit/$found lines)');
  if (percent < minimum) {
    stderr.writeln('Below the required $minimum%.');
    exit(1);
  }
}
