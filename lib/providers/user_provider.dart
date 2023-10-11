import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user.dart';
import 'auth_provider.dart';

final userProvider = AsyncNotifierProvider<UserNotifier, UserState?>(() {
  return UserNotifier();
});

const String userCollectionKey = 'users';

class UserState {
  const UserState({required this.id, required this.user});

  final String id;
  final FirestoreUser user;

  UserState copyWith({
    String? id,
    FirestoreUser? user,
  }) {
    return UserState(
      id: id ?? this.id,
      user: user ?? this.user,
    );
  }
}

class UserNotifier extends AsyncNotifier<UserState?> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<UserState?> build() async {
    return ref.watch(authProvider).maybeWhen(
      data: (user) async {
        if (user != null) {
          return getLoggedInUser(user.uid);
        }
        return null;
      },
      orElse: () {
        return null;
      },
    );
  }

  Future<UserState> getLoggedInUser(String uid) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection(userCollectionKey).doc(uid).get();
      if (!snapshot.exists) {
        return Future.error(
            "No firestore user associated to authenticated email");
      }
      return UserState(
        id: snapshot.id,
        user: FirestoreUser.fromMap(snapshot.data()!),
      );
    } on FirebaseException catch (e) {
      return Future.error(e.message!);
    } catch (e) {
      return Future.error("Unknown error occurred");
    }
  }

  Future<void> updateUsername(String uid, String newUsername) async {
    try {
      await _firestore.collection(userCollectionKey).doc(uid).update(
        {FirestoreUser.usernameKey: newUsername},
      );
      state = AsyncData(await getLoggedInUser(uid));
    } on FirebaseException catch (e) {
      state = AsyncError(e.message!, StackTrace.current);
    } catch (e) {
      state = AsyncError("Unknown error occured", StackTrace.current);
    }
  }

  Future<void> loginWithApple() async {
    try {
      UserCredential userCredential =
          await _auth.signInWithProvider(AppleAuthProvider());
      if (userCredential.additionalUserInfo != null &&
          userCredential.additionalUserInfo!.isNewUser) {
        await _firestore
            .collection(userCollectionKey)
            .doc(userCredential.user!.uid)
            .set(
              FirestoreUser(
                      email: userCredential.user!.email!,
                      dateCreated: DateTime.now())
                  .toMap(),
            );
      }
    } on FirebaseAuthException catch (e) {
      return Future.error(e.message!);
    } catch (e) {
      return Future.error("Unknown error occurred");
    }
  }

  Future<void> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      return Future.error(e.message!);
    } catch (e) {
      return Future.error("Unknown error occurred");
    }
  }

  Future<void> signUp(String email, String password) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _firestore
          .collection(userCollectionKey)
          .doc(userCredential.user!.uid)
          .set(
            FirestoreUser(email: email, dateCreated: DateTime.now()).toMap(),
          );
    } on FirebaseAuthException catch (e) {
      return Future.error(e.message!);
    } catch (e) {
      return Future.error("Unknown error occurred");
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      return Future.error(e.message!);
    } catch (e) {
      return Future.error("Unknown error occurred");
    }
  }
}
