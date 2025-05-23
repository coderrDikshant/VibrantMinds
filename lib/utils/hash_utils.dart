import 'dart:convert';
import 'package:crypto/crypto.dart';

class HashUtils {
  static String generateUserId(String name, String email) {
    final input = '$name-$email';
    final bytes = utf8.encode(input);
    final digest = md5.convert(bytes);
    return digest.toString();
  }
}