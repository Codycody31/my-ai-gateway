class Chat {
  int id;
  String name;
  int providerId;
  String modelName;
  final String createdAt;

  Chat({required this.id, required this.name, required this.providerId, required this.modelName, required this.createdAt});

  // Factory constructor to create a Model instance from JSON
  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['id'] as int,
      name: json['name'] as String,
      providerId: json['provider_id'] as int,
      modelName: json['model_name'] as String,
      createdAt: json['created_at'] as String,
    );
  }

  // Serialize the Model instance to JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'provider_id': providerId,
    'model_name': modelName,
    'created_at': createdAt,
  };

  // Serialize the Model instance to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'provider_id': providerId,
      'model_name': modelName,
      'created_at': createdAt,
    };
  }
}
