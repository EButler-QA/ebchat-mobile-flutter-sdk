import 'dart:convert';

class Mascotte {
  String? id;
  String? name;
  String? image;
  Mascotte({
    this.id,
    this.name,
    this.image,
  });

  Mascotte copyWith({
    String? id,
    String? name,
    String? image,
  }) {
    return Mascotte(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'image': image,
    };
  }

  factory Mascotte.fromMap(Map<String, dynamic> map) {
    return Mascotte(
      id: map['id'],
      name: map['name'],
      image: map['image'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Mascotte.fromJson(String source) =>
      Mascotte.fromMap(json.decode(source));

  @override
  String toString() => 'Mascotte(id: $id, name: $name, image: $image)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Mascotte &&
        other.id == id &&
        other.name == name &&
        other.image == image;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ image.hashCode;
}
