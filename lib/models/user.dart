import 'dart:convert';

class FirestoreUser {
  final String email;
  final String? username;
  final DateTime dateCreated;

  const FirestoreUser({
    required this.email,
    this.username,
    required this.dateCreated,
  });

  static const String emailKey = 'email';
  static const String usernameKey = 'username';
  static const String dateCreatedKey = 'dateCreated';

  FirestoreUser copyWith({
    String? email,
    String? username,
    DateTime? dateCreated,
  }) {
    return FirestoreUser(
      email: email ?? this.email,
      username: username ?? this.username,
      dateCreated: dateCreated ?? this.dateCreated,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'username': username,
      'dateCreated': dateCreated.millisecondsSinceEpoch,
    };
  }

  factory FirestoreUser.fromMap(Map<String, dynamic> map) {
    return FirestoreUser(
      email: map['email'] ?? '',
      username: map['username'],
      dateCreated: DateTime.fromMillisecondsSinceEpoch(map['dateCreated']),
    );
  }

  String toJson() => json.encode(toMap());

  factory FirestoreUser.fromJson(String source) =>
      FirestoreUser.fromMap(json.decode(source));

  @override
  String toString() =>
      'FirestoreUser(email: $email, username: $username, dateCreated: $dateCreated)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FirestoreUser &&
        other.email == email &&
        other.username == username &&
        other.dateCreated == dateCreated;
  }

  @override
  int get hashCode => email.hashCode ^ username.hashCode ^ dateCreated.hashCode;
}
