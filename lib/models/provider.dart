class Provider {
  final int id;
  final String name;
  final String url;
  final String authToken;
  final String type;
  final String apiType;
  final String? defaultModel;

  Provider({
    required this.id,
    required this.name,
    required this.url,
    required this.authToken,
    required this.type,
    required this.apiType,
    this.defaultModel,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'url': url,
      'auth_token': authToken,
      'type': type,
      'api_type': apiType,
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
      apiType: json['api_type'] as String,
      defaultModel: json['default_model'] as String?,
    );
  }

  Provider copyWith({
    int? id,
    String? name,
    String? url,
    String? authToken,
    String? type,
    String? apiType,
    String? defaultModel,
  }) {
    return Provider(
      id: id ?? this.id,
      name: name ?? this.name,
      url: url ?? this.url,
      authToken: authToken ?? this.authToken,
      type: type ?? this.type,
      apiType: apiType ?? this.apiType,
      defaultModel: defaultModel ?? this.defaultModel,
    );
  }
}
