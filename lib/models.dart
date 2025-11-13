class StoredContact {
  final String name;
  final int color;

  StoredContact({required this.name, required this.color});

  Map<String, dynamic> toJson() => {
        'name': name,
        'color': color,
      };

  factory StoredContact.fromJson(Map<String, dynamic> json) => StoredContact(
        name: json['name'],
        color: json['color'],
      );
}

