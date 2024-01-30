import 'dart:async';
import 'dart:io';

import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;
import 'package:shelf_express/shelf_express.dart';

class SwaggerController extends Controller {
  late final File _file;
  late final String _swaggerTitle;
  String? _prefix;

  SwaggerController(
    String filePath, {
    String swaggerPath = '/swagger',
    String swaggerTitle = 'Swagger UI',
    String? prefix,
  }) : super(swaggerPath.startsWith('/') ? swaggerPath : '/$swaggerPath') {
    _file = File(p.join(Directory.current.path, filePath));
    _prefix = prefix;
    _swaggerTitle = swaggerTitle;

    assert(p.extension(_file.path).endsWith('.json') || p.extension(_file.path).endsWith('.yaml'), Exception('File must be .json or .yaml'));

    assert(_file.existsSync(), Exception('File ${p.basename(_file.path)} not found'));

    get('/src/${p.basename(_file.path)}', _swaggerSrc);

    get('/', _swagger);
  }

  Future<Response> _swaggerSrc(Request request) async {
    return Response(
      200,
      body: _file.openRead(),
      headers: {
        'content-type': lookupMimeType(p.basename(_file.path)) ?? 'application/octet-stream',
      },
    );
  }

  Future<Response> _swagger(Request request) async {
    final uri = request.requestedUri.origin;

    return Response(
      200,
      body: '''
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <meta
    name="description"
    content="SwaggerUI"
  />
  <title>$_swaggerTitle</title>
  <link rel="stylesheet" href="https://unpkg.com/swagger-ui-dist@4.5.0/swagger-ui.css" />
</head>
<body>
<div id="swagger-ui"></div>
<script src="https://unpkg.com/swagger-ui-dist@4.5.0/swagger-ui-bundle.js" crossorigin></script>
<script src="https://unpkg.com/swagger-ui-dist@4.5.0/swagger-ui-standalone-preset.js" crossorigin></script>

<script>
  window.onload = () => {
    window.ui = SwaggerUIBundle({
      dom_id: '#swagger-ui',
      title: '$_swaggerTitle',
      deepLinking: true,
      presets: [
          SwaggerUIBundle.presets.apis,
          SwaggerUIStandalonePreset
      ],
      url: "$uri${_prefix ?? ''}$path/src/${p.basename(_file.path)}",
      layout: "BaseLayout",
    });
  };
</script>
</body>
</html>
''',
      headers: {
        'content-type': 'text/html',
      },
    );
  }
}
