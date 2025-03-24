class UserModel {
  final String id;
  final String email;
  final String name;
  final bool isBlocked;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.isBlocked,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      email: map['email'] as String,
      name: map['name'] as String,
      isBlocked: map['isBlocked'] as bool,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'isBlocked': isBlocked,
    };
  }
}