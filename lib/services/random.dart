import 'dart:math';

const ASCII_START = 33;
const ASCII_END = 126;

/// Generates a random integer where [from] <= [to].
int randomBetween(int from, int to) {
  if (from > to) throw new Exception('$from cannot be > $to');
  var rand = new Random();
  return ((to - from) * rand.nextDouble()).toInt() + from;
}

/// Generates a random string of [length] with characters
/// between ascii [from] to [to].
/// Defaults to characters of ascii '!' to '~'.
String randomString(int length, {int from: ASCII_START, int to: ASCII_END}) {
  return new String.fromCharCodes(
      new List.generate(length, (index) => randomBetween(from, to)));
}