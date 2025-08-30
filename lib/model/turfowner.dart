class TurfOwner {
  final int id;
  final String name;
  final String email;
  final int phone;

  TurfOwner({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
  });

  factory TurfOwner.fromJson(Map<String, dynamic> json) {
    return TurfOwner(
      id: int.parse(json['id'].toString()),
      name: json['name'],
      email: json['email'],
      phone: int.parse(json['phone'].toString()),
    );
  }
}
