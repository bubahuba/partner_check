/// Active contact pair when launching Tetris from the contacts screen.
class TetrisSession {
  final String contact1Name;
  final int contact1Color;
  final String contact2Name;
  final int contact2Color;

  const TetrisSession({
    required this.contact1Name,
    required this.contact1Color,
    required this.contact2Name,
    required this.contact2Color,
  });

  /// Normalized pair key — order does not matter.
  static String pairKey(String name1, String name2) {
    final names = [name1, name2]..sort();
    return '${names[0]}|${names[1]}';
  }

  String get pairKeyValue => pairKey(contact1Name, contact2Name);
}

/// Best Tetris score for a contact pair, persisted locally.
class TetrisPlayerRecord {
  final String contact1Name;
  final int contact1Color;
  final String contact2Name;
  final int contact2Color;
  final int bestWeeks;

  const TetrisPlayerRecord({
    required this.contact1Name,
    required this.contact1Color,
    required this.contact2Name,
    required this.contact2Color,
    required this.bestWeeks,
  });

  String get pairKeyValue => TetrisSession.pairKey(contact1Name, contact2Name);

  TetrisPlayerRecord copyWith({
    String? contact1Name,
    int? contact1Color,
    String? contact2Name,
    int? contact2Color,
    int? bestWeeks,
  }) {
    return TetrisPlayerRecord(
      contact1Name: contact1Name ?? this.contact1Name,
      contact1Color: contact1Color ?? this.contact1Color,
      contact2Name: contact2Name ?? this.contact2Name,
      contact2Color: contact2Color ?? this.contact2Color,
      bestWeeks: bestWeeks ?? this.bestWeeks,
    );
  }

  Map<String, dynamic> toJson() => {
        'contact1Name': contact1Name,
        'contact1Color': contact1Color,
        'contact2Name': contact2Name,
        'contact2Color': contact2Color,
        'bestWeeks': bestWeeks,
      };

  factory TetrisPlayerRecord.fromJson(Map<String, dynamic> json) =>
      TetrisPlayerRecord(
        contact1Name: json['contact1Name'] as String,
        contact1Color: json['contact1Color'] as int,
        contact2Name: json['contact2Name'] as String,
        contact2Color: json['contact2Color'] as int,
        bestWeeks: json['bestWeeks'] as int,
      );

  factory TetrisPlayerRecord.fromSession(TetrisSession session, int weeks) {
    final names = [session.contact1Name, session.contact2Name]..sort();
    final firstIsContact1 = names[0] == session.contact1Name;
    return TetrisPlayerRecord(
      contact1Name: names[0],
      contact1Color:
          firstIsContact1 ? session.contact1Color : session.contact2Color,
      contact2Name: names[1],
      contact2Color:
          firstIsContact1 ? session.contact2Color : session.contact1Color,
      bestWeeks: weeks,
    );
  }
}

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
