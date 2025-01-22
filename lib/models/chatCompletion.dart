class ChatCompletion {
  final String id;
  final String object;
  final int created;
  final String model;
  final List<ChatCompletionChoice> choices;
  final ChatCompletionUsage usage;
  final String systemFingerprint;

  ChatCompletion({
    required this.id,
    required this.object,
    required this.created,
    required this.model,
    required this.choices,
    required this.usage,
    required this.systemFingerprint,
  });

  factory ChatCompletion.fromJson(Map<String, dynamic> json) {
    return ChatCompletion(
      id: json['id'],
      object: json['object'],
      created: json['created'],
      model: json['model'],
      choices: (json['choices'] as List)
          .map((choice) => ChatCompletionChoice.fromJson(choice))
          .toList(),
      usage: ChatCompletionUsage.fromJson(json['usage']),
      systemFingerprint: json['system_fingerprint'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'object': object,
      'created': created,
      'model': model,
      'choices': choices.map((choice) => choice.toJson()).toList(),
      'usage': usage.toJson(),
      'system_fingerprint': systemFingerprint,
    };
  }
}

class ChatCompletionChoice {
  final int index;
  final dynamic logprobs; // Assuming null or another type, keep as dynamic
  final String finishReason;
  final ChatCompletionMessage message;

  ChatCompletionChoice({
    required this.index,
    this.logprobs,
    required this.finishReason,
    required this.message,
  });

  factory ChatCompletionChoice.fromJson(Map<String, dynamic> json) {
    return ChatCompletionChoice(
      index: json['index'],
      logprobs: json['logprobs'],
      finishReason: json['finish_reason'],
      message: ChatCompletionMessage.fromJson(json['message']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'index': index,
      'logprobs': logprobs,
      'finish_reason': finishReason,
      'message': message.toJson(),
    };
  }
}

class ChatCompletionMessage {
  final String role;
  final String content;

  ChatCompletionMessage({
    required this.role,
    required this.content,
  });

  factory ChatCompletionMessage.fromJson(Map<String, dynamic> json) {
    return ChatCompletionMessage(
      role: json['role'],
      content: json['content'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'content': content,
    };
  }
}

class ChatCompletionUsage {
  final int promptTokens;
  final int completionTokens;
  final int totalTokens;

  ChatCompletionUsage({
    required this.promptTokens,
    required this.completionTokens,
    required this.totalTokens,
  });

  factory ChatCompletionUsage.fromJson(Map<String, dynamic> json) {
    return ChatCompletionUsage(
      promptTokens: json['prompt_tokens'],
      completionTokens: json['completion_tokens'],
      totalTokens: json['total_tokens'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'prompt_tokens': promptTokens,
      'completion_tokens': completionTokens,
      'total_tokens': totalTokens,
    };
  }
}
