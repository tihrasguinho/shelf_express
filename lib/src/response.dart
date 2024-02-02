import 'dart:convert';
import 'dart:io';

import 'package:mime/mime.dart';
import 'package:shelf/shelf.dart' as shelf;

class Response extends shelf.Response {
  Response._(
    super.statusCode, {
    super.body,
    super.headers,
    super.context,
    super.encoding,
  });

  factory Response(
    int statusCode, {
    Object? body,
    Map<String, Object>? headers,
    Map<String, Object>? context,
    Encoding? encoding,
  }) {
    return Response._(
      statusCode,
      body: body,
      headers: headers,
      context: context,
      encoding: encoding,
    );
  }

  factory Response.json({
    int statusCode = HttpStatus.ok,
    Object? body,
    Map<String, Object>? headers,
    Map<String, Object>? context,
    Encoding? encoding,
  }) {
    return Response._(
      statusCode,
      body: body != null ? jsonEncode(body) : null,
      headers: {'Content-Type': 'application/json', ...?headers},
      context: context,
      encoding: encoding,
    );
  }

  factory Response.file({
    int statusCode = HttpStatus.ok,
    required File file,
    Map<String, Object>? headers,
    Map<String, Object>? context,
    Encoding? encoding,
  }) {
    return Response._(
      statusCode,
      body: file.openRead(),
      headers: {
        'Content-Type': lookupMimeType(file.path) ?? 'application/octet-stream',
        'Content-Length': file.lengthSync().toString(),
        ...?headers,
      },
      context: context,
      encoding: encoding,
    );
  }
}
