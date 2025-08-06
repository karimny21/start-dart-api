import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';

import 'routers/index.dart';

// Custom logging middleware
Middleware logRequests() => (Handler innerHandler) {
  return (Request request) async {
    final stopwatch = Stopwatch()..start();
    final response = await innerHandler(request);
    stopwatch.stop();

    final duration = stopwatch.elapsedMilliseconds;
    final timestamp = DateTime.now().toIso8601String();

    print(
      '[$timestamp] ${request.method} ${request.requestedUri} - '
      '${response.statusCode} (${duration}ms)',
    );

    return response;
  };
};

// Custom error handling middleware
Middleware errorHandler() => (Handler innerHandler) {
  return (Request request) async {
    try {
      return await innerHandler(request);
    } catch (error, stackTrace) {
      print('Error: $error');
      print('Stack trace: $stackTrace');
      return Response.internalServerError(
        body: jsonEncode({'success': false, 'error': 'Internal server error'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  };
};

// Router setup
Router setupRouter() {
  final router = Router();

  // Health check endpoint
  router.get('/health', (Request request) {
    return Response.ok(
      jsonEncode({
        'status': 'healthy',
        'timestamp': DateTime.now().toIso8601String(),
        'version': '1.0.0',
      }),
      headers: {'Content-Type': 'application/json'},
    );
  });

  // all API routes
  router.mount('/api', routers().call);

  router.get('/api', (Request request) {
    return Response.ok("You request at /");
  });

  // 404 handler
  router.all('/<ignored|.*>', (Request request) {
    return Response.notFound(
      jsonEncode({
        'success': false,
        'error': 'Endpoint not found',
        'path': request.url.path,
      }),
      headers: {'Content-Type': 'application/json'},
    );
  });

  return router;
}

void main() async {
  final router = setupRouter();

  // Create the handler pipeline with middleware
  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsHeaders())
      .addMiddleware(errorHandler())
      .addHandler(router.call);

  // Start the server
  final server = await serve(handler, InternetAddress.anyIPv4, 8080);

  print(
    '🚀 Server started at http://${server.address.host}:${server.port} or http://localhost:${server.port}',
  );
  print('📚 API Documentation:');
  print('GET    /health              - Health check');
  print('GET    /api/users           - Get all users');
  print('GET    /api/users/:id       - Get user by ID');
  print('POST   /api/users           - Create new user');
  print('PUT    /api/users/:id       - Update user');
  print('DELETE /api/users/:id       - Delete user');
  print('\n💡 Example requests:');
  print('curl http://localhost:8080/health');
  print('curl http://localhost:8080/api/users');
  print(
    'curl -X POST http://localhost:8080/api/users -H "Content-Type: application/json" -d \'{"name":"Alice","email":"alice@example.com"}\'',
  );
}
