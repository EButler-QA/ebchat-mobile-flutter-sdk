import 'dart:convert';
import 'package:ebchat/src/lib/models/Mascotte.dart';

class Company {
  String? id;
  String? name;
  String? image;
  String? streamkey;
  String? ebchatkey;
  Mascotte? mascotte;
  Company({
    this.id,
    this.name,
    this.image,
    this.streamkey,
    this.ebchatkey,
    this.mascotte,
  });

  Company copyWith({
    String? id,
    String? name,
    String? image,
    String? streamkey,
    String? ebchatkey,
    Mascotte? mascotte,
  }) {
    return Company(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
      streamkey: streamkey ?? this.streamkey,
      ebchatkey: ebchatkey ?? this.ebchatkey,
      mascotte: mascotte ?? this.mascotte,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'streamkey': streamkey,
      'ebchatkey': ebchatkey,
      'mascotte': mascotte?.toMap(),
    };
  }

  factory Company.fromMap(Map<String, dynamic> map) {
    return Company(
      id: map['id'],
      name: map['name'],
      image: map['image'],
      streamkey: map['streamkey'],
      ebchatkey: map['ebchatkey'],
      mascotte:
          map['mascotte'] != null ? Mascotte.fromMap(map['mascotte']) : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Company.fromJson(String source) =>
      Company.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Company(id: $id, name: $name, image: $image, streamkey: $streamkey)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Company &&
        other.id == id &&
        other.name == name &&
        other.image == image &&
        other.streamkey == streamkey &&
        other.mascotte == mascotte;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        image.hashCode ^
        streamkey.hashCode ^
        mascotte.hashCode;
  }
}
