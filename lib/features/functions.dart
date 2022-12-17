import 'dart:convert';
import 'package:flutter/services.dart';

List<Uint8List> stringToUintList({required String imagesString}) {
  var images = imagesString.split('\n');
  List<Uint8List> imagesBytes = [];
  for (var image in images) {
    if (image.isNotEmpty) {
      imagesBytes.add(base64Decode(image));
    }
  }
  return imagesBytes;
}

String imageToString({required List<Uint8List> bytes}) {
  String imagesString = '';

  for (var byte in bytes) {
    imagesString += base64Encode(byte);
    imagesString += '\n';
  }
  return imagesString;
}
