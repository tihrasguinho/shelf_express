import 'dart:io';

import 'package:shelf/shelf.dart' hide Response;

import 'exceptions/exceptions.dart';
import 'response.dart';

Handler fileHandler(
  String path, {
  Map<String, Object>? headers,
  Map<String, Object>? context,
}) {
  final file = File(path);

  assert(file.existsSync(), NotFoundException('File $path not found'));

  return (Request request) async {
    return Response.file(
      file: file,
      headers: headers,
      context: context,
    );
  };
}
