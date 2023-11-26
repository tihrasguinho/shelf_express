import 'dart:async';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart' as shelf_router;

import 'controller.dart';
import 'method.dart';
import 'route.dart';

abstract interface class ExpressBase {
  ExpressBase all(String path, Function handler);
  ExpressBase add(Method method, String path, Function handler);
  ExpressBase get(String path, Function handler);
  ExpressBase post(String path, Function handler);
  ExpressBase put(String path, Function handler);
  ExpressBase delete(String path, Function handler);
  ExpressBase withController(Controller controller);
  ExpressBase withMiddleware(Middleware middleware);
  Future<HttpServer> start({Object address = '0.0.0.0', int port = 8080, void Function()? onListen});
}

final class Express implements ExpressBase {
  final String? prefix;
  final List<Route> _routes = [];
  final List<Controller> _controllers = [];
  final List<Middleware> _middlewares = [];

  Express({this.prefix}) {
    if (prefix != null) {
      assert(prefix!.startsWith('/'), 'Prefix must start with "/"');
    }
  }

  @override
  Express all(String path, Function handler) {
    _routes.addAll([
      Route.get(path, handler),
      Route.post(path, handler),
      Route.put(path, handler),
      Route.delete(path, handler),
    ]);

    return this;
  }

  @override
  Express add(Method method, String path, Function handler) {
    _routes.add(Route(method, path, handler));
    return this;
  }

  @override
  Express get(String path, Function handler) {
    _routes.add(Route.get(path, handler));
    return this;
  }

  @override
  Express post(String path, Function handler) {
    _routes.add(Route.post(path, handler));
    return this;
  }

  @override
  Express put(String path, Function handler) {
    _routes.add(Route.put(path, handler));
    return this;
  }

  @override
  Express delete(String path, Function handler) {
    _routes.add(Route.delete(path, handler));
    return this;
  }

  @override
  Express withController(Controller controller) {
    _controllers.add(controller);
    return this;
  }

  @override
  Express withMiddleware(Middleware middleware) {
    _middlewares.add(middleware);
    return this;
  }

  @override
  Future<HttpServer> start({Object address = '0.0.0.0', int port = 8080, void Function()? onListen}) async {
    final router = shelf_router.Router();

    for (final route in _routes) {
      router.add(route.method.verb, '${prefix ?? ''}${route.path}', route.handler);
    }
    for (final controller in _controllers) {
      router.mount('${prefix ?? ''}${controller.path}', controller.routes);
    }
    var handler = Pipeline().addHandler(router);
    for (final middleware in _middlewares) {
      handler = middleware(handler);
    }

    return await shelf_io.serve(handler, address, port).whenComplete(() => onListen?.call());
  }
}
