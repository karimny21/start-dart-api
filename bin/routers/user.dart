import 'package:shelf_router/shelf_router.dart';
import '../apps/users/user_controller.dart';

final router = Router();

Router userRouter() {
  router.get('/', UserController.getAllUsers);
  router.get('/<id>', UserController.getUserById);
  router.post('/', UserController.createUser);
  router.put('/<id>', UserController.updateUser);
  router.delete('/<id>', UserController.deleteUser);

  // router.get('/users', UserController.getAllUsers);
  // router.get('/users/<id>', UserController.getUserById);
  // router.post('/users', UserController.createUser);
  // router.put('/users/<id>', UserController.updateUser);
  // router.delete('/users/<id>', UserController.deleteUser);

  return router;
}
