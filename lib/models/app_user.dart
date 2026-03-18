import 'package:firebase_auth/firebase_auth.dart';

class AppUser {
  final String uid;
  final String? email;
  final String? phoneNumber;
  final String? displayName;
  final bool isEmailVerified;
  final bool isPhoneVerified;

  AppUser({
    required this.uid,
    this.email,
    this.phoneNumber,
    this.displayName,
    this.isEmailVerified = false,
    this.isPhoneVerified = false,
  });

  factory AppUser.fromFirebase(User user) {
    return AppUser(
      uid: user.uid,
      email: user.email,
      phoneNumber: user.phoneNumber,
      displayName: user.displayName,
      isEmailVerified: user.emailVerified,
      isPhoneVerified: user.phoneNumber != null,
    );
  }

  // Для пустого пользователя (не авторизован)
  static final empty = AppUser(uid: '');

  bool get isEmpty => uid.isEmpty;
  bool get isNotEmpty => uid.isNotEmpty;
}
