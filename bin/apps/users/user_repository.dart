import '../models/users.dart';

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
