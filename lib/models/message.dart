class Message {
  int id;
  final int chatId;
  final int isUser;
  final int providerId;
  final String modelName;
  final String createdAt;
  String content;

  Message({required this.id, required this.chatId, required this.isUser, required this.providerId, required this.modelName, required this.createdAt, required this.content});

  // Factory constructor to create a Model instance from JSON
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as int,
      chatId: json['chat_id'] as int,
      isUser: json['is_user'] as int,
      providerId: json['provider_id'] as int,
      modelName: json['model_name'] as String,
      createdAt: json['created_at'] as String,
      content: json['content'] as String,
    );
  }

  // Serialize the Model instance
  Map<String, dynamic> toMap() => {
    'id': id,
    'chat_id': chatId,
    'is_user': isUser,
    'provider_id': providerId,
    'model_name': modelName,
    'created_at': createdAt,
    'content': content,
  };

  Map<String, dynamic> standardMessageFormat() => {
    'role': isUser == 1 ? 'user' : 'assistant',
    'content': content,
  };
}
