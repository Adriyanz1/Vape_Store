import 'dart:convert';
import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

class ImageHelper {

  /// KOMPRES + ENCODE
  static Future<String> compressAndEncode(File file) async {

    final dir = await getTemporaryDirectory();

    final targetPath =
        "${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg";

    final compressedFile = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 60,        // 0-100 (60 ideal)
      minWidth: 600,
      minHeight: 600,
    );

    if (compressedFile == null) return "";

    final bytes = await compressedFile.readAsBytes();
    return base64Encode(bytes);
  }

}
