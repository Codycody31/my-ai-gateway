class Provider {
  final int id;
  final String name;
  final String url;
  final String authToken;
  final String type;
  final String? defaultModel;

  Provider({
    required this.id,
    required this.name,
    required this.url,
    required this.authToken,
    required this.type,
    this.defaultModel,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'url': url,
      'auth_token': authToken,
      'type': type,
      'default_model': defaultModel,
    };
  }

  factory Provider.fromJson(Map<String, dynamic> json) {
    return Provider(
      id: json['id'] as int,
      name: json['name'] as String,
      url: json['url'] as String,
      authToken: json['auth_token'] as String,
      type: json['type'] as String,
      defaultModel: json['default_model'] as String?,
    );
  }

  Provider copyWith({
    int? id,
    String? name,
    String? url,
    String? authToken,
    String? type,
    String? defaultModel,
  }) {
    return Provider(
      id: id ?? this.id,
      name: name ?? this.name,
      url: url ?? this.url,
      authToken: authToken ?? this.authToken,
      type: type ?? this.type,
      defaultModel: defaultModel ?? this.defaultModel,
    );
  }
}
