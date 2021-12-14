class User {
  User({
    required this.id,
    required this.password,
    required this.login,
  });
  String password;
  String login;
  int id;

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        password: json["password"],
        login: json["login"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "password": password,
        "login": login,
      };
}
