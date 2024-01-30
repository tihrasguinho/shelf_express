import 'package:shelf_express/shelf_express.dart';

void main() async {
  final app = Express();

  app.useSwagger('swagger.yaml');

  await app.start(port: 5254);
}
