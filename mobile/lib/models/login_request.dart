class LoginRequest {
  LoginRequest({
    required this.username,
    required this.pin,
  });

  final String username;
  final String pin;

  Map<String, dynamic> toJson() => {
        'username': username,
        'pin': pin,
      };
}
