class StoredContact {
  final String name;
  final int color;
  final bool isFavorite;

  StoredContact({
    required this.name,
    required this.color,
    this.isFavorite = false,
  });

  StoredContact copyWith({String? name, int? color, bool? isFavorite}) {
    return StoredContact(
      name: name ?? this.name,
      color: color ?? this.color,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'color': color,
        'isFavorite': isFavorite,
      };

  factory StoredContact.fromJson(Map<String, dynamic> json) => StoredContact(
        name: json['name'],
        color: json['color'],
        isFavorite: json['isFavorite'] ?? false,
      );
}
