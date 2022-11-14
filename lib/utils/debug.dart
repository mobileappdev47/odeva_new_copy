import 'dart:core' as core;
import 'dart:core';

class Debug {
  static bool isDevelopment;

  static void print(dynamic statement) {
    if (isDevelopment) {
      core.print(statement);
    }
  }
}
