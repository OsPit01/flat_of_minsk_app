import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/app_user.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  // Геттер для текущего пользователя
  User? get currentUser => _firebaseAuth.currentUser;

  // Stream для отслеживания состояния аутентификации (ИСПРАВЛЕНО)
  Stream<User?> get authState => _firebaseAuth.authStateChanges();

  // Вход по email
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<User?> registerWithEmail(
    String email,
    String password,
    String name,
  ) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      // Обновляем имя пользователя
      await userCredential.user?.updateDisplayName(name);
      await userCredential.user?.reload();

      // Отправляем подтверждение email
      await userCredential.user?.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Вход по телефону
  Future<void> signInWithPhone(
    String phoneNumber,
    Function(String verificationId) onCodeSent,
  ) async {
    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _firebaseAuth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        throw _handleAuthException(e);
      },
      codeSent: (String verifactionId, int? resendToken) {
        onCodeSent(verifactionId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  // Подтверждение SMS кода

  Future<User?> verifyPhoneCode(String verificationId, String smsCode) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  //сброс пароля
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }
  //выход

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  //удаление аккаунта

  Future<void> deleteAccoutn() async {
    try {
      await _firebaseAuth.currentUser?.delete();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Обработка ошибок
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Этот email уже зарегистрирован';
      case 'invalid-email':
        return 'Неверный формат email';
      case 'weak-password':
        return 'Пароль должен быть не менее 6 символов';
      case 'user-not-found':
        return 'Пользователь не найден';
      case 'wrong-password':
        return 'Неверный пароль';
      case 'user-disabled':
        return 'Пользователь заблокирован';
      case 'too-many-requests':
        return 'Слишком много попыток. Попробуйте позже';
      case 'invalid-phone-number':
        return 'Неверный номер телефона';
      case 'invalid-verification-code':
        return 'Неверный код подтверждения';
      case 'network-request-failed':
        return 'Ошибка сети. Проверьте подключение';
      default:
        return 'Ошибка: ${e.message}';
    }
  }
}
