import 'package:flutter_insta/classes/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authProvider = StateNotifierProvider<Auth, AuthUser?>((ref) => Auth(ref));

class Auth extends StateNotifier<AuthUser?> {
  Auth(this.ref) : super(null);

  final Ref ref;

  void setAuthData(AuthUser authData) {
    state = authData;
  }

  void resetAuthData() {
    state = null;
  }
}
