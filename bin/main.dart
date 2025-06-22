import 'dart:io';
import 'dart:convert';

import 'package:scientry_api/auth/login/api.dart';
import 'package:scientry_api/auth/register/api.dart';
import 'package:scientry_api/service/executor_manager.dart';
import 'package:scientry_api/service/jwt_manager.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';

Middleware verifyJwtMiddleware({bool protectAll = true}) {
  return (Handler innerHandler) {
    return (Request request) async {
      if (!protectAll && _isNotProtected(request.url.path)) {
        return innerHandler(request);
      }

      final authHeader = request.headers['Authorization'];
      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return Response.forbidden(
          jsonEncode({
            "errorCode": -1,
            "errorMessage": "Missing or invalid Authorization header",
          }),
        );
      }

      final token = authHeader.substring(7);
      final jwt = JWTManager.verifyAccessToken(token);
      if (jwt == null) {
        return Response.forbidden(
          jsonEncode({
            "errorCode": -1,
            "errorMessage": "Invalid or expired token",
          }),
        );
      }
      final updatedRequest = request.change(context: {'claims': jwt.payload});
      return innerHandler(updatedRequest);
    };
  };
}

bool _isNotProtected(String path) {
  const nonProtectedPrefixes = ['api/auth'];
  return nonProtectedPrefixes.any((prefix) => path.startsWith(prefix));
}

Future<void> main() async {
  final router = Router()
    ..post('/api/auth/register', RegisterHandler().register)
    ..post("/api/auth/login", LoginHandler().handler);

  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(verifyJwtMiddleware(protectAll: false))
      .addHandler(router.call);

  final port = int.parse(Platform.environment['PORT'] ?? '7860');
  final server = await serve(handler, InternetAddress.anyIPv4, port);
  print('Server running at http://localhost:${server.port}');

  ProcessSignal.sigint.watch().listen((_) async {
    print('\nShutting down isolate pool...');
    ExecutorManager().shutdown();
    exit(0);
  });
}
