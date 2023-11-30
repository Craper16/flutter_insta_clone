class User {
  final String userId;
  final String email;
  final String username;
  final int phoneNumber;
  final String countryCode;
  final String? profilePicture;
  final String fullName;
  final List<dynamic> followers;
  final List<dynamic> following;

  const User({
    required this.userId,
    required this.email,
    required this.countryCode,
    required this.fullName,
    required this.phoneNumber,
    required this.username,
    required this.followers,
    required this.following,
    this.profilePicture,
  });
}

class AuthUser extends User {
  final String accessToken;
  final String refreshToken;
  final String expiresAt;

  const AuthUser({
    required super.userId,
    required super.countryCode,
    required super.email,
    required super.fullName,
    required super.phoneNumber,
    required super.profilePicture,
    required super.username,
    required super.followers,
    required super.following,
    required this.accessToken,
    required this.expiresAt,
    required this.refreshToken,
  });
}
