import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:my_ai_gateway/models/message.dart';
import 'package:my_ai_gateway/models/provider.dart';
import 'package:my_ai_gateway/pages/settings.dart';
import 'package:my_ai_gateway/services/api.dart';
import 'package:my_ai_gateway/models/chat.dart';
import 'package:my_ai_gateway/services/database.dart';
import 'package:my_ai_gateway/widgets/collapsible_thought.dart';
import 'package:my_ai_gateway/pages/model_details.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();

  List<Message> _messages = [];
  List<Provider> _providers = [];
  List<String> _models = [];
  List<Chat> _chats = [];

  StreamSubscription<String>? streamSubscription;

  final List<String> _suggestions = [
    "Tell me a fun fact!",
    "Can you help me with my homework?",
    "Explain the concept of AI in simple terms.",
    "What are the latest tech trends?",
  ];

  int _selectedChat = 0;
  int _selectedProvider = 0;
  String _selectedModel = "";
  bool _loading = false;
  bool _sendingMessage = false;
  final ScrollController _scrollController = ScrollController();
  bool _showScrollDownButton = false;

  ApiService llmApi = ApiService(apiUrl: '', authToken: "", apiType: "");

  @override
  void initState() {
    super.initState();

    // Scroll controller listener for showing the scroll-down button
    _scrollController.addListener(() {
      if (_scrollController.position.atEdge) {
        final isAtBottom = _scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent;
        setState(() {
          _showScrollDownButton = !isAtBottom;
        });
      }
    });

    _refetchKeyData();
  }

  Future<void> _refetchKeyData() async {
    try {
      DatabaseService.instance.readAllProviders().then((providers) {
        setState(() {
          _providers = providers;
        });
        debugPrint('Providers fetched');
      }).catchError((e) {
        debugPrint('Error fetching providers: $e');
      });

// Fetch the last opened chat
      DatabaseService.instance.getLastOpenedChat().then((chatId) async {
        if (chatId != null && chatId != 0) {
          debugPrint('Last opened chat found: $chatId');
          await _switchChat(chatId);
        } else {
          debugPrint('No last opened chat found');
          // Get the default provider: default_provider_id
          final defaultProviderId =
              await DatabaseService.instance.getConfig('default_provider_id');
          if (defaultProviderId != null) {
            var provider = await DatabaseService.instance
                .getProviderById(int.parse(defaultProviderId));
            _selectedProvider = int.parse(defaultProviderId);
            _selectedModel = provider?.defaultModel ?? "";
            await _fetchProviderModels(_selectedProvider);
          }
        }
      }).catchError((e) {
        debugPrint('Error fetching last opened chat: $e');
      });

      // Load all chats
      DatabaseService.instance.readAllChats().then((chats) {
        setState(() {
          _chats = chats;
        });
        debugPrint('Chats fetched');
      }).catchError((e) {
        debugPrint('Error fetching chats: $e');
      });
    } catch (e) {
      debugPrint('Error re-fetching data: $e');
    }
  }

  void _navigateToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsPage(),
      ),
    ).then((_) {
      // This will trigger when returning to ChatPage
      _refetchKeyData();
    });
  }

  Future<void> _fetchProviderModels(int providerId) async {
    try {
      // Get provider details
      final provider =
          await DatabaseService.instance.getProviderById(providerId);
      if (provider != null) {
        llmApi = ApiService(
            apiUrl: provider.url,
            authToken: provider.authToken,
            apiType: provider.apiType);
        final models = await llmApi.fetchModels();
        setState(() {
          _models = models;
        });
        debugPrint('Models fetched for provider $providerId');
      }
    } catch (e) {
      debugPrint('Error fetching models for provider $providerId: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'An unexpected error occurred while fetching models.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _refetchModels() async {
    try {
      final models = await llmApi.fetchModels();
      setState(() {
        _models = models;
      });
      debugPrint('Models refetched');
    } catch (e) {
      debugPrint('Error fetching models: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'An unexpected error occurred while fetching models.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _closeChat() async {
    await DatabaseService.instance.setLastOpenedChat(0);

    Provider? provider;
    // should load the default provider and model
    // Get the default provider: default_provider_id
    final defaultProviderId =
        await DatabaseService.instance.getConfig('default_provider_id');
    if (defaultProviderId != null) {
      provider = await DatabaseService.instance
          .getProviderById(int.parse(defaultProviderId));
    }

    setState(() {
      _selectedChat = 0;
      _selectedProvider = provider?.id ?? 0;
      _selectedModel = provider?.defaultModel ?? "";
      _messages = [];
    });

    debugPrint('Chat closed');
  }

  Future<void> _createNewChat() async {
    final chat = Chat(
      id: 0,
      name: 'New Chat ${_chats.length + 1}',
      providerId: _selectedProvider,
      modelName: _selectedModel,
      createdAt: DateTime.now().toString(),
    );

    final chatId = await DatabaseService.instance.createChat(chat);

    chat.id = chatId;
    setState(() {
      _chats.add(chat);
    });

    debugPrint('New chat created: $chatId');

    await _switchChat(chatId);
  }

  Future<void> _switchChat(int id) async {
    setState(() {
      _loading = true;
    });

    final chat = await DatabaseService.instance.getChatById(id);
    if (chat == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chat not found')),
      );
      setState(() {
        _loading = false;
      });
      return;
    }

    // Set the selected chat and provider
    setState(() {
      _selectedChat = id;
      _selectedProvider = chat.providerId;
      _selectedModel = chat.modelName;
    });

    // Fetch models for the chat's provider
    await _fetchProviderModels(chat.providerId);

    // Fetch messages for the selected chat
    final messages =
        await DatabaseService.instance.getMessagesByChatId(_selectedChat);
    setState(() {
      _messages = messages;
      _loading = false;
    });

    // Save the last opened chat
    await DatabaseService.instance.setLastOpenedChat(_selectedChat);

    debugPrint('Chat switched to $id');
  }

  Future<void> _switchProvider(int providerId) async {
    setState(() {
      _selectedProvider = providerId;
    });

    debugPrint('Provider switched to $providerId');

    // Fetch models for the provider
    await _fetchProviderModels(providerId);

    // select the default model for the provider
    Provider? provider =
        await DatabaseService.instance.getProviderById(providerId);
    setState(() {
      _selectedModel = provider?.defaultModel ?? "";
    });
  }

  Future<void> _switchModel(String model) async {
    setState(() {
      _selectedModel = model;
    });

    if (_selectedChat != 0) {
      await DatabaseService.instance.updateChatModelName(_selectedChat, model);
    }

    debugPrint('Model switched to $model');
  }

  Future<void> _sendMessage() async {
    setState(() {
      _sendingMessage = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {});
    });

    if (_selectedModel.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a model'),
        ),
      );

      setState(() {
        _sendingMessage = false;
      });
      return;
    }

    if (_controller.text.isNotEmpty) {
      // if selected chat is 0, create a new chat
      if (_selectedChat == 0) {
        await _createNewChat();
      }

      var firstTime = _messages.isEmpty;

      var messageUser = Message(
        id: 0,
        chatId: _selectedChat,
        providerId: _selectedProvider,
        modelName: _selectedModel,
        isUser: 1,
        content: _controller.text,
        createdAt: DateTime.now().toString(),
      );
      var messageUserId =
          await DatabaseService.instance.createMessage(messageUser);
      messageUser.id = messageUserId;

      setState(() {
        _messages.add(messageUser);
        _controller.clear();
      });

      // Update the chats model name if it is different than the selected model
      var chat = _chats.firstWhere((chat) => chat.id == _selectedChat);
      if (chat.modelName != _selectedModel) {
        await DatabaseService.instance
            .updateChatModelName(_selectedChat, _selectedModel);
        setState(() {
          chat.modelName = _selectedModel;
        });
      }

      var streamOutput =
          await DatabaseService.instance.getConfig('stream_output');

      if (streamOutput == '1') {
        // Create an empty assistant message
        var assistantMessage = Message(
          id: 0,
          chatId: _selectedChat,
          providerId: _selectedProvider,
          modelName: _selectedModel,
          isUser: 0,
          content: "",
          createdAt: DateTime.now().toString(),
        );

        var assistantMessageId =
            await DatabaseService.instance.createMessage(assistantMessage);
        assistantMessage.id = assistantMessageId;

        setState(() {
          _messages.add(assistantMessage);
        });

        // Use StringBuffer for efficient concatenation
        StringBuffer contentBuffer = StringBuffer();

        debugPrint(
            'Fetching completions for chat $_selectedChat through stream');

        // Stream tokens and update the assistant message
        final stream = llmApi.fetchStreamedTokens(_selectedModel, _messages);
        streamSubscription = stream.listen(
          (token) {
            // Append the new token to the buffer
            contentBuffer.write(token);

            setState(() {
              assistantMessage.content = contentBuffer.toString();
            });

            // Update the message content in the database
            DatabaseService.instance.updateMessageContent(
              assistantMessage.id,
              assistantMessage.content,
            );
          },
          onDone: () async {
            debugPrint('Stream done for chat $_selectedChat');
            setState(() {
              _sendingMessage = false;
            });

            if (firstTime) {
              debugPrint('Summarizing chat $_selectedChat');
              var summary = await _summarizeChat(_selectedChat);
              if (summary != null) {
                await DatabaseService.instance
                    .updateChatName(_selectedChat, summary);

                setState(() {
                  _chats.firstWhere((chat) => chat.id == _selectedChat).name =
                      summary;
                });

                debugPrint('Chat $_selectedChat renamed to $summary');
              }
            }
          },
          onError: (error) {
            debugPrint('Stream error: $error');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'An unexpected error occurred while streaming tokens.',
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.red,
              ),
            );
            setState(() {
              _sendingMessage = false;
            });
          },
        );
      } else {
        debugPrint('Fetching completions for chat $_selectedChat');
        var response = await llmApi.fetchCompletions(_selectedModel, _messages);

        var messageAssistant = Message(
          id: 0,
          chatId: _selectedChat,
          providerId: _selectedProvider,
          modelName: _selectedModel,
          isUser: 0,
          content: response,
          createdAt: DateTime.now().toString(),
        );

        try {
          var messageAssistantId =
              await DatabaseService.instance.createMessage(messageAssistant);
          messageAssistant.id = messageAssistantId;
        } catch (e) {
          debugPrint('Error creating assistant message: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'An unexpected error occurred while creating the assistant message.',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }

        setState(() {
          _messages.add(
            messageAssistant,
          );
        });

        setState(() {
          _sendingMessage = false;
        });

        if (firstTime) {
          debugPrint('Summarizing chat $_selectedChat');
          var summary = await _summarizeChat(_selectedChat);
          if (summary != null) {
            await DatabaseService.instance
                .updateChatName(_selectedChat, summary);

            setState(() {
              _chats.firstWhere((chat) => chat.id == _selectedChat).name =
                  summary;
            });

            debugPrint('Chat $_selectedChat renamed to $summary');
          }
        }
      }
    }
  }

  Future<void> _renameChat(BuildContext context, int chatId) async {
    final chat = _chats.firstWhere((chat) => chat.id == chatId);
    String newName = chat.name;

    await showDialog(
      context: context,
      builder: (context) {
        final TextEditingController controller =
            TextEditingController(text: chat.name);

        return AlertDialog(
          title: const Text('Rename Chat'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Enter new name'),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                // Use AI to summarize chat messages
                final summary = await _summarizeChat(chatId);
                if (summary != null) {
                  newName = summary;
                }
                Navigator.pop(context);
              },
              child: const Text('Use AI Summary'),
            ),
            TextButton(
              onPressed: () {
                newName = controller.text;
                Navigator.pop(context);
              },
              child: const Text('Rename'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );

    // Update the chat name in the database and state
    if (newName.isNotEmpty && newName != chat.name) {
      await DatabaseService.instance.updateChatName(chatId, newName);
      setState(() {
        chat.name = newName;
      });

      debugPrint('Chat $chatId renamed to $newName');
    }
  }

  Future<String?> _summarizeChat(int chatId) async {
    try {
      final messages =
          await DatabaseService.instance.getMessagesByChatId(chatId);

      if (messages.isEmpty) {
        return null;
      }

      // If the number of messages is greater than 2, prompt the user that this task may take a while
      // and ask if they would like to proceed
      if (messages.length > 2) {
        final shouldProceed = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Summarize Chat'),
              content: const Text(
                  'Summarizing a chat with multiple messages may take a while. Do you want to proceed?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  child: const Text('Yes'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  child: const Text('No'),
                ),
              ],
            );
          },
        );

        if (shouldProceed != true) {
          return null;
        }
      }

      // Send the prompt to the AI
      final response = await llmApi.fetchCompletions(
        _selectedModel,
        [
          ...messages,
          Message(
              id: 0,
              isUser: 1,
              providerId: 0,
              chatId: chatId,
              modelName: "",
              createdAt: "",
              content:
                  "Summarize the following chat in the least amount of words possible. Use a maximum of 10 words, do not use any styling/markdown, or any other formatting other than the words needed. Only output the chat title, nothing else.")
        ],
      );

      return _removeThinkTags(response.trim());
    } catch (e) {
      debugPrint('Error summarizing chat: $e');
      return null;
    }
  }

  void _deleteChat(int id) async {
    await DatabaseService.instance.deleteMessagesByChatId(id);
    await DatabaseService.instance.deleteChatById(id);
    if (await DatabaseService.instance.getLastOpenedChat() == id) {
      await DatabaseService.instance.setLastOpenedChat(0);
    }

    setState(() {
      _chats.removeWhere((chat) => chat.id == id);
    });

    // Clear messages if the deleted chat is the selected chat
    if (_selectedChat == id) {
      await _closeChat();
    }

    debugPrint('Chat $id deleted');
  }

  List<String> _extractThoughts(String content) {
    final RegExp thinkTagRegex = RegExp(r'<think>(.*?)</think>', dotAll: true);
    final thoughts = thinkTagRegex
        .allMatches(content)
        .map((match) => match.group(1)?.trim() ?? "")
        .toList();

    // Handle case where there is an unmatched <think> tag
    final unmatchedThinkIndex = content.indexOf('<think>');
    if (unmatchedThinkIndex != -1 && !content.contains('</think>')) {
      final unmatchedThought =
          content.substring(unmatchedThinkIndex + 7).trim();
      thoughts.add(unmatchedThought);
    }

    return thoughts;
  }

  String _removeThinkTags(String content) {
    final RegExp thinkTagRegex = RegExp(r'<think>.*?</think>', dotAll: true);
    content = content.replaceAll(thinkTagRegex, "").trim();

    // Handle case where there is an unmatched <think> tag
    final unmatchedThinkIndex = content.indexOf('<think>');
    if (unmatchedThinkIndex != -1) {
      content = content.substring(0, unmatchedThinkIndex).trim();
    }

    return content;
  }

  Widget _buildChatBubble(Message message, bool isUserMessage) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Extract thoughts and cleaned content
    final thoughts = _extractThoughts(message.content);
    final cleanedContent = _removeThinkTags(message.content);

    return Align(
      alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: isUserMessage
              ? colorScheme.primaryContainer
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...thoughts.map((thought) => CollapsibleThought(thought: thought)),
            MarkdownBody(
              data: cleanedContent,
              onTapLink: (text, href, title) {
                debugPrint('Link clicked: $href');
              },
              styleSheet: MarkdownStyleSheet(
                p: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestions() {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Suggestions:',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          ..._suggestions.map((suggestion) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _controller.text = suggestion;
                  });
                  _sendMessage();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
                child: Text(suggestion),
              ),
            );
          }),
        ],
      ),
    );
  }

  // Cancel the stream if necessary
  Future<void> _cancelRequest() async {
    await streamSubscription?.cancel();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Request canceled'),
      ),
    );
    setState(() {
      _sendingMessage = false;
    });
    debugPrint('Request canceled');
  }

  // UI for canceling the request
  Widget _buildLoadingOrCancelButton() {
    return _sendingMessage
        ? GestureDetector(
            onTap: _cancelRequest,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(),
                const Icon(Icons.close),
              ],
            ),
          )
        : IconButton(
            icon: const Icon(Icons.arrow_upward),
            color: Theme.of(context).colorScheme.primary,
            onPressed: _sendMessage,
          );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        title: InkWell(
          onTap: _selectedModel.isNotEmpty
              ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return ModelDetailsPage(
                          modelName: _selectedModel,
                          providerType: _providers
                              .firstWhere((provider) =>
                                  provider.id == _selectedProvider)
                              .type);
                    }),
                  );
                }
              : null,
          child: Text(
            _selectedModel == "" ? "Select a model" : _selectedModel,
            style: theme.textTheme.titleLarge?.copyWith(
              color: colorScheme.onPrimary,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            color: colorScheme.onPrimary,
            onPressed: () {
              _closeChat();
            },
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: colorScheme.onPrimary),
            onSelected: (value) {
              if (value == 'view-model-details') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return ModelDetailsPage(
                        modelName: _selectedModel,
                        providerType: _providers
                            .firstWhere(
                                (provider) => provider.id == _selectedProvider)
                            .type);
                  }),
                );
              } else if (value.contains('provider_')) {
                final providerId = int.parse(value.split('_')[1]);
                _switchProvider(providerId);
              } else if (value.contains('model_')) {
                final model = value.split('_')[1];
                _switchModel(model);
              } else if (value == 'Refresh') {
                _refetchModels();
              } else if (value == 'delete') {
                _deleteChat(_selectedChat);
              } else if (value == 'rename') {
                _renameChat(context, _selectedChat);
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              if (_selectedModel != "")
                const PopupMenuItem<String>(
                  value: 'view-model-details',
                  child: ListTile(
                    leading: Icon(Icons.info),
                    title: Text('View Details'),
                  ),
                ),
              if (_selectedChat != 0 || _selectedModel != "")
                const PopupMenuDivider(),
              if (_selectedChat != 0)
                PopupMenuItem<String>(
                  value: 'rename',
                  child: const ListTile(
                    leading: Icon(Icons.edit),
                    title: Text('Rename'),
                  ),
                ),
              if (_selectedChat != 0)
                PopupMenuItem<String>(
                  value: 'delete',
                  child: const ListTile(
                    leading: Icon(Icons.delete),
                    title: Text('Delete'),
                  ),
                ),
              if (_selectedChat != 0) const PopupMenuDivider(),
              ..._providers.map(
                (provider) => PopupMenuItem<String>(
                  value: "provider_${provider.id}",
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    // Align items to the top
                    children: [
                      if (_selectedProvider == provider.id)
                        Icon(Icons.check, size: 20, color: colorScheme.primary)
                      else
                        const SizedBox(width: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          provider.name,
                          softWrap: true,
                          // Enable text wrapping
                          maxLines: 2,
                          // Limit to 2 lines (optional)
                          overflow: TextOverflow.visible,
                          // Allow full text display
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const PopupMenuDivider(),
              ..._models.map(
                (model) => PopupMenuItem<String>(
                  value: "model_$model",
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    // Align items to the top
                    children: [
                      if (_selectedModel == model)
                        Icon(Icons.check, size: 20, color: colorScheme.primary)
                      else
                        const SizedBox(width: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          model,
                          softWrap: true,
                          // Enable text wrapping
                          maxLines: 2,
                          // Limit to 2 lines (optional)
                          overflow: TextOverflow.visible,
                          // Allow full text display
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
                // Refetch models
              ),
              const PopupMenuDivider(),
              PopupMenuItem<String>(
                value: 'Refresh',
                child: const ListTile(
                  leading: Icon(Icons.refresh, color: Colors.blue),
                  title: Text('Refresh Models'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    if (_loading)
                      Expanded(
                        child: Center(
                          child: CircularProgressIndicator(
                            color: colorScheme.primary,
                          ),
                        ),
                      )
                    else
                      Expanded(
                        child: _messages.isEmpty
                            ? _buildSuggestions()
                            : ListView.builder(
                                controller: _scrollController,
                                itemCount: _messages.length,
                                itemBuilder: (context, index) {
                                  final message = _messages[index];
                                  return GestureDetector(
                                    onLongPress: () {
                                      Clipboard.setData(
                                          ClipboardData(text: message.content));
                                    },
                                    child: _buildChatBubble(
                                        message, message.isUser == 1),
                                  );
                                },
                              ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _controller,
                              minLines: 1,
                              maxLines: 8,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(45.0),
                                  borderSide: BorderSide.none,
                                ),
                                hintText: 'Message',
                                filled: true,
                                fillColor: colorScheme.surfaceContainerHighest,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 10.0,
                                  horizontal: 15.0,
                                ),
                              ),
                            ),
                          ),
                          _buildLoadingOrCancelButton(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_showScrollDownButton)
            Positioned(
              bottom: 80, // Distance from the bottom of the screen
              left: MediaQuery.of(context).size.width / 2 -
                  28, // Center horizontally
              child: Container(
                width: 56, // Circle size
                height: 56, // Circle size
                decoration: BoxDecoration(
                  shape:
                      BoxShape.circle, // Ensures the button is a perfect circle
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_downward),
                  onPressed: () {
                    _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  },
                ),
              ),
            ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: colorScheme.primary),
              child: Center(
                child: Text(
                  'My AI Gateway',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _chats.length,
                itemBuilder: (context, index) {
                  final chat = _chats[index];
                  final isSelected = chat.id == _selectedChat;

                  return GestureDetector(
                    onLongPress: () async {
                      final selectedOption = await showModalBottomSheet<String>(
                        context: context,
                        builder: (context) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: const Icon(Icons.edit),
                                title: const Text('Rename'),
                                onTap: () {
                                  Navigator.pop(context, 'rename');
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.delete),
                                title: const Text('Delete'),
                                onTap: () {
                                  Navigator.pop(context, 'delete');
                                },
                              ),
                            ],
                          );
                        },
                      );

                      if (selectedOption == 'rename') {
                        _renameChat(context, _chats[index].id);
                      } else if (selectedOption == 'delete') {
                        _deleteChat(_chats[index].id);
                      }
                    },
                    child: ListTile(
                      leading: Icon(
                        Icons.chat,
                        color: isSelected
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                      title: Text(
                        chat.name,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Provider: ${_providers.firstWhere((provider) => provider.id == chat.providerId, orElse: () => Provider(id: 0, name: 'Unknown', url: '', authToken: '', type: 'unknown', apiType: 'unknown')).name}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            'Model: ${chat.modelName.isEmpty ? "None" : chat.modelName}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      tileColor: isSelected
                          ? Theme.of(context).colorScheme.primaryContainer
                          : Colors.transparent,
                      onTap: () {
                        _switchChat(chat.id);
                        Navigator.pop(context);
                      },
                    ),
                  );
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text("Create New Chat"),
              onTap: () {
                _closeChat();
                Navigator.pop(context);
              }, // Adds a new chat
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Settings"),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                _navigateToSettings();
              },
            ),
          ],
        ),
      ),
    );
  }
}
