part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const home = _Paths.home;
  static const login = _Paths.login;
  static const users = _Paths.users;
  static const register = _Paths.register;
  static const chats = _Paths.chats;
  static const chatDetails = _Paths.chatDetails;
}

abstract class _Paths {
  _Paths._();
  static const home = '/home';
  static const login = '/login';
  static const users = '/users';
  static const register = '/register';
  static const chats = '/chats';
  static const chatDetails = '/chat-details';
}
