class Model {
  final String id;
  final String object;
  final String ownedBy;

  Model({required this.id, required this.object, required this.ownedBy});

  // Factory constructor to create a Model instance from JSON
  factory Model.fromJson(Map<String, dynamic> json) {
    return Model(
      id: json['id'] as String,
      object: json['object'] as String,
      ownedBy: json['owned_by'] as String,
    );
  }
}
