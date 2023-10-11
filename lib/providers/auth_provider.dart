import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authProvider = StreamProvider((ref) {
  return FirebaseAuth.instance.authStateChanges();
});
