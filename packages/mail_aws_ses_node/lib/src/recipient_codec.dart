import 'dart:convert';

/// Encode name.
String encodeName(String name) {
  return '=?utf-8?B?${base64Encode(utf8.encode(name))}?=';
}
