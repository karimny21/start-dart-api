import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';

// Data model
class User {
  final int id;
  final String name;
  final String email;
  final DateTime createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'createdAt': createdAt.toIso8601String(),
  };

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'],
    name: json['name'],
    email: json['email'],
    createdAt: DateTime.parse(json['createdAt']),
  );
}

// In-memory database (for demonstration)
class UserRepository {
  static final List<User> _users = [
    User(
      id: 1,
      name: 'John Doe',
      email: 'john@example.com',
      createdAt: DateTime.now().subtract(Duration(days: 30)),
    ),
    User(
      id: 2,
      name: 'Jane Smith',
      email: 'jane@example.com',
      createdAt: DateTime.now().subtract(Duration(days: 15)),
    ),
  ];
  static int _nextId = 3;

  static List<User> getAllUsers() => _users;

  static User? getUserById(int id) {
    try {
      return _users.firstWhere((user) => user.id == id);
    } catch (e) {
      return null;
    }
  }

  static User createUser(String name, String email) {
    final user = User(
      id: _nextId++,
      name: name,
      email: email,
      createdAt: DateTime.now(),
    );
    _users.add(user);
    return user;
  }

  static bool updateUser(int id, String name, String email) {
    final index = _users.indexWhere((user) => user.id == id);
    if (index != -1) {
      _users[index] = User(
        id: id,
        name: name,
        email: email,
        createdAt: _users[index].createdAt,
      );
      return true;
    }
    return false;
  }

  static bool deleteUser(int id) {
    final index = _users.indexWhere((user) => user.id == id);
    if (index != -1) {
      _users.removeAt(index);
      return true;
    }
    return false;
  }
}

// API Handlers
class UserController {
  // GET /users
  static Response getAllUsers(Request request) {
    final users = UserRepository.getAllUsers();
    return Response.ok(
      jsonEncode({
        'success': true,
        'data': users.map((user) => user.toJson()).toList(),
        'count': users.length,
      }),
      headers: {'Content-Type': 'application/json'},
    );
  }

  // GET /users/:id
  static Response getUserById(Request request, String id) {
    final userId = int.tryParse(id);
    if (userId == null) {
      return Response.badRequest(
        body: jsonEncode({'success': false, 'error': 'Invalid user ID format'}),
        headers: {'Content-Type': 'application/json'},
      );
    }

    final user = UserRepository.getUserById(userId);
    if (user == null) {
      return Response.notFound(
        jsonEncode({'success': false, 'error': 'User not found'}),
        headers: {'Content-Type': 'application/json'},
      );
    }

    return Response.ok(
      jsonEncode({'success': true, 'data': user.toJson()}),
      headers: {'Content-Type': 'application/json'},
    );
  }

  // POST /users
  static Future<Response> createUser(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      final name = data['name'] as String?;
      final email = data['email'] as String?;

      if (name == null || name.isEmpty || email == null || email.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'Name and email are required',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final user = UserRepository.createUser(name, email);
      return Response(
        201,
        body: jsonEncode({
          'success': true,
          'data': user.toJson(),
          'message': 'User created successfully',
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'success': false, 'error': 'Invalid JSON format'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  // PUT /users/:id
  static Future<Response> updateUser(Request request, String id) async {
    try {
      final userId = int.tryParse(id);
      if (userId == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'Invalid user ID format',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      final name = data['name'] as String?;
      final email = data['email'] as String?;

      if (name == null || name.isEmpty || email == null || email.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'Name and email are required',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final success = UserRepository.updateUser(userId, name, email);
      if (!success) {
        return Response.notFound(
          jsonEncode({'success': false, 'error': 'User not found'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final updatedUser = UserRepository.getUserById(userId);
      return Response.ok(
        jsonEncode({
          'success': true,
          'data': updatedUser?.toJson(),
          'message': 'User updated successfully',
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'success': false, 'error': 'Invalid JSON format'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  // DELETE /users/:id
  static Response deleteUser(Request request, String id) {
    final userId = int.tryParse(id);
    if (userId == null) {
      return Response.badRequest(
        body: jsonEncode({'success': false, 'error': 'Invalid user ID format'}),
        headers: {'Content-Type': 'application/json'},
      );
    }

    final success = UserRepository.deleteUser(userId);
    if (!success) {
      return Response.notFound(
        jsonEncode({'success': false, 'error': 'User not found'}),
        headers: {'Content-Type': 'application/json'},
      );
    }

    return Response.ok(
      jsonEncode({'success': true, 'message': 'User deleted successfully'}),
      headers: {'Content-Type': 'application/json'},
    );
  }
}

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

  // User routes
  router.get('/users', UserController.getAllUsers);
  router.get('/users/<id>', UserController.getUserById);
  router.post('/users', UserController.createUser);
  router.put('/users/<id>', UserController.updateUser);
  router.delete('/users/<id>', UserController.deleteUser);

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

  print('🚀 Server started at http://${server.address.host}:${server.port}');
  print('📚 API Documentation:');
  print('  GET    /health           - Health check');
  print('  GET    /users            - Get all users');
  print('  GET    /users/:id        - Get user by ID');
  print('  POST   /users            - Create new user');
  print('  PUT    /users/:id        - Update user');
  print('  DELETE /users/:id        - Delete user');
  print('\n💡 Example requests:');
  print('  curl http://localhost:8080/health');
  print('  curl http://localhost:8080/users');
  print('  curl -X POST http://localhost:8080/users -H "Content-Type: application/json" -d \'{"name":"Alice","email":"alice@example.com"}\'');
}
