import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'user_repository.dart';

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