import 'package:shelf_router/shelf_router.dart';
import 'user.dart';

final router = Router();

Router routers() {
  router.mount('/users', userRouter().call);
  return router;
}
