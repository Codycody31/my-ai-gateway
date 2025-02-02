import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';
import 'package:provider/provider.dart' as pkg_provider;
import 'package:url_launcher/url_launcher.dart';
import '../models/provider.dart';
import '../services/api.dart';
import '../services/database.dart';
import '../services/theme_notifier.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  List<Provider> _providers = [];
  int _defaultProviderId = 0;
  int _streamOutput = 0;
  bool _showProviderModelInfo = false;
  bool _formatModelNames = false;
  final String _githubLink = "https://github.com/codycody31/my-ai-gateway";

  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
    installerStore: 'Unknown',
  );

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  Widget _infoTile(String title, String subtitle) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle.isEmpty ? 'Not set' : subtitle),
    );
  }

  Future<void> _loadSettings() async {
    await _loadStreamOutput();
    await _loadProviders();
    await _loadShowProviderModelInfo();
    await _loadFormatModelNames();
  }

  Future<void> _loadStreamOutput() async {
    final streamOutput =
        await DatabaseService.instance.getConfig('stream_output');
    setState(() {
      _streamOutput = streamOutput != null ? int.parse(streamOutput) : 0;
    });
  }

  Future<void> _setStreamOutput(int value) async {
    await DatabaseService.instance.setConfig('stream_output', value.toString());
    setState(() {
      _streamOutput = value;
    });
  }

  Future<void> _loadProviders() async {
    final providers = await DatabaseService.instance.readAllProviders();
    final defaultProviderId =
        await DatabaseService.instance.getConfig('default_provider_id');
    setState(() {
      _providers = providers;
      _defaultProviderId =
          defaultProviderId != null ? int.parse(defaultProviderId) : 0;
    });
  }

  Future<void> _setDefaultProvider(int providerId) async {
    await DatabaseService.instance
        .setConfig('default_provider_id', providerId.toString());
    setState(() {
      _defaultProviderId = providerId;
    });
  }

  Future<void> _loadShowProviderModelInfo() async {
    final showInfo =
        await DatabaseService.instance.getConfig('show_provider_model_info');
    setState(() {
      _showProviderModelInfo = showInfo == '1';
    });
  }

  Future<void> _setShowProviderModelInfo(bool value) async {
    await DatabaseService.instance
        .setConfig('show_provider_model_info', value ? '1' : '0');
    setState(() {
      _showProviderModelInfo = value;
    });
  }

  Future<void> _loadFormatModelNames() async {
    final formatModelNames =
        await DatabaseService.instance.getConfig('format_model_names');
    setState(() {
      _formatModelNames = formatModelNames == '1';
    });
  }

  Future<void> _setFormatModelNames(bool value) async {
    await DatabaseService.instance
        .setConfig('format_model_names', value ? '1' : '0');
    setState(() {
      _formatModelNames = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SettingsList(
        sections: [
          SettingsSection(
            title: const Text('General'),
            tiles: [
              SettingsTile.switchTile(
                initialValue: _streamOutput == 1,
                leading: const Icon(Icons.notifications),
                title: const Text('Stream Output'),
                description: const Text(
                  'Rather than waiting for the model to finish, stream tokens/characters as they are generated.',
                ),
                onToggle: (value) => _setStreamOutput(value ? 1 : 0),
              ),
              SettingsTile.switchTile(
                initialValue: _showProviderModelInfo,
                leading: const Icon(Icons.visibility),
                title: const Text('Show Provider & Model Info'),
                description: const Text(
                  'Toggle visibility of provider and model info under chat selection.',
                ),
                onToggle: (value) => _setShowProviderModelInfo(value),
              ),
              SettingsTile.switchTile(
                initialValue: _formatModelNames,
                leading: const Icon(Icons.format_textdirection_l_to_r),
                title: const Text('Format Model Names'),
                description: const Text(
                  'Toggle whether to display formatted or raw model names.',
                ),
                onToggle: (value) => _setFormatModelNames(value),
              ),
              SettingsTile(
                title: const Text('About'),
                leading: const Icon(Icons.info),
                onPressed: (context) {
                  showAboutDialog(
                    context: context,
                    applicationName: "My AI Gateway",
                    applicationIcon: Image.asset(
                      'assets/icon/icon.png',
                      height: 40,
                    ),
                    children: <Widget>[
                      _infoTile('Build',
                          "v${_packageInfo.version}-${_packageInfo.buildNumber} (${Platform.operatingSystem})"),
                      ListTile(
                        title: const Text('GitHub'),
                        subtitle: Text(_githubLink),
                        onTap: () async {
                          if (await canLaunchUrl(Uri.parse(_githubLink))) {
                            await launchUrl(Uri.parse(_githubLink));
                          }
                        },
                        onLongPress: () {
                          Clipboard.setData(ClipboardData(
                            text: _githubLink,
                          ));
                        },
                      ),
                      if (Platform.isAndroid || Platform.isIOS)
                        _infoTile('Package name', _packageInfo.packageName),
                      if (Platform.isAndroid || Platform.isIOS)
                        _infoTile(
                            'Build signature', _packageInfo.buildSignature),
                      if (Platform.isAndroid || Platform.isIOS)
                        _infoTile(
                          'Installer store',
                          _packageInfo.installerStore ?? 'not available',
                        ),
                    ],
                  );
                },
              ),
              SettingsTile(
                title: const Text('Reset Database'),
                leading: const Icon(Icons.delete_forever),
                onPressed: (context) async {
                  final shouldReset = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Reset Database'),
                      content: const Text(
                          'Are you sure you want to reset the database? All data will be lost.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Reset'),
                        ),
                      ],
                    ),
                  );

                  if (shouldReset == true) {
                    await DatabaseService.instance.resetDatabase();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Database reset successfully'),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
          SettingsSection(
            title: const Text('Providers'),
            tiles: [
              for (var provider in _providers)
                SettingsTile(
                  title: Row(
                    children: [
                      Flexible(
                        child: Text(
                          provider.name,
                          overflow: TextOverflow.ellipsis,
                          // Ensures long text is truncated
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ],
                  ),
                  description: Row(
                    children: [
                      Flexible(
                        child: Text(
                          provider.url,
                          overflow: TextOverflow.ellipsis,
                          // Ensures long URLs are truncated
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (provider.id == _defaultProviderId)
                        const Icon(Icons.check, color: Colors.green),
                      if (provider.id != _defaultProviderId)
                        TextButton(
                          onPressed: () => _setDefaultProvider(provider.id),
                          child: const Text('Make Default'),
                        ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () async {
                          final updatedProvider =
                              await _showEditProviderDialog(context, provider);
                          if (updatedProvider != null) {
                            await _updateProvider(updatedProvider);
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteProvider(provider.id),
                      ),
                    ],
                  ),
                ),
              SettingsTile(
                title: const Text('Create New Provider'),
                leading: const Icon(Icons.add),
                onPressed: (context) async {
                  final newProvider = await _showCreateProviderDialog(context);
                  if (newProvider != null) {
                    await _createProvider(newProvider);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<Provider?> _showCreateProviderDialog(BuildContext context) {
    final nameController = TextEditingController();
    final urlController = TextEditingController();
    final authTokenController = TextEditingController();
    String selectedType = 'local';
    String selectedApiType = 'ollama';

    return showDialog<Provider>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create New Provider'),
          content: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height *
                    0.7, // Limit dialog height
              ),
              child: SingleChildScrollView(
                  child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration:
                        const InputDecoration(labelText: 'Provider Name'),
                  ),
                  TextField(
                    controller: urlController,
                    decoration: const InputDecoration(labelText: 'API URL'),
                  ),
                  TextField(
                    controller: authTokenController,
                    decoration: const InputDecoration(labelText: 'Auth Token'),
                  ),
                  DropdownButtonFormField<String>(
                    value: selectedType,
                    items: [
                      DropdownMenuItem(
                          value: 'local', child: const Text('Local LLM')),
                      DropdownMenuItem(
                          value: 'openai', child: const Text('OpenAI')),
                      DropdownMenuItem(
                          value: 'custom', child: const Text('Custom')),
                    ],
                    onChanged: (value) => selectedType = value ?? 'local',
                    decoration: const InputDecoration(labelText: 'Type'),
                  ),
                  DropdownButtonFormField<String>(
                    value: selectedApiType,
                    items: [
                      DropdownMenuItem(
                          value: 'ollama', child: const Text('Ollama')),
                      DropdownMenuItem(
                          value: 'openai', child: const Text('OpenAI')),
                    ],
                    onChanged: (value) => selectedApiType = value ?? 'ollama',
                    decoration: const InputDecoration(labelText: 'Api Type'),
                  ),
                ],
              ))),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final provider = Provider(
                  id: 0,
                  name: nameController.text,
                  url: urlController.text,
                  authToken: authTokenController.text,
                  type: selectedType,
                  apiType: selectedApiType,
                );
                Navigator.pop(context, provider);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<Provider?> _showEditProviderDialog(
      BuildContext context, Provider provider) async {
    final nameController = TextEditingController(text: provider.name);
    final urlController = TextEditingController(text: provider.url);
    final authTokenController = TextEditingController(text: provider.authToken);
    String selectedType = provider.type;
    String selectedApiType = provider.apiType;
    String? selectedModel = provider.defaultModel;
    String? selectedSummaryModel = provider.summaryModel;
    List<String> models = [];

    // Fetch models for the provider if the URL is valid
    Future<List<String>> fetchModels() async {
      if (urlController.text.isNotEmpty) {
        ApiService llmApi = ApiService(
            apiUrl: urlController.text,
            authToken: authTokenController.text,
            apiType: selectedApiType);
        List<String> m;

        try {
          m = await llmApi.fetchModels();
        } catch (e) {
          return [];
        }

        return m;
      } else {
        return [];
      }
    }

    // Fetch models immediately if API URL is already populated
    if (urlController.text.isNotEmpty && models.isEmpty) {
      var m = await fetchModels();
      setState(() {
        models = m;
      });
    }

    return showDialog<Provider>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
                title: const Text('Edit Provider'),
                actions: [
                  IconButton(
                      onPressed: () {
                        fetchModels().then((m) {
                          setState(() {
                            models = m;
                          });
                        });
                      },
                      icon: const Icon(Icons.refresh)),
                  TextButton(
                    onPressed: () => Navigator.pop(context, null),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      if (urlController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('API URL must be provided')),
                        );
                        return;
                      }
                      final updatedProvider = provider.copyWith(
                        name: nameController.text,
                        url: urlController.text,
                        authToken: authTokenController.text,
                        type: selectedType,
                        defaultModel: selectedModel,
                        summaryModel: selectedSummaryModel,
                      );
                      Navigator.pop(context, updatedProvider);
                    },
                    child: const Text('Save'),
                  ),
                ],
                content: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height *
                          0.7, // Limit dialog height
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: nameController,
                            decoration: const InputDecoration(
                                labelText: 'Provider Name'),
                          ),
                          TextField(
                            controller: urlController,
                            decoration:
                                const InputDecoration(labelText: 'API URL'),
                            onChanged: (value) {
                              fetchModels(); // Fetch models when the API URL is updated
                            },
                          ),
                          TextField(
                            controller: authTokenController,
                            decoration:
                                const InputDecoration(labelText: 'Auth Token'),
                          ),
                          DropdownButtonFormField<String>(
                            value: selectedType,
                            items: [
                              DropdownMenuItem(
                                  value: 'local',
                                  child: const Text('Local LLM')),
                              DropdownMenuItem(
                                  value: 'openai', child: const Text('OpenAI')),
                              DropdownMenuItem(
                                  value: 'custom', child: const Text('Custom')),
                            ],
                            onChanged: (value) =>
                                selectedType = value ?? provider.type,
                            decoration:
                                const InputDecoration(labelText: 'Type'),
                          ),
                          DropdownButtonFormField<String>(
                            value: selectedApiType,
                            items: [
                              DropdownMenuItem(
                                  value: 'ollama', child: const Text('Ollama')),
                              DropdownMenuItem(
                                  value: 'openai', child: const Text('OpenAI')),
                            ],
                            onChanged: (value) =>
                                selectedApiType = value ?? 'ollama',
                            decoration:
                                const InputDecoration(labelText: 'API Type'),
                          ),
                          if (models.isNotEmpty)
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.8,
                              child: DropdownButtonFormField<String>(
                                value: models.contains(selectedModel)
                                    ? selectedModel
                                    : null,
                                isExpanded: true,
                                items: models.map((model) {
                                  return DropdownMenuItem(
                                    value: model,
                                    child: Text(
                                      model,
                                      overflow: TextOverflow.ellipsis,
                                      softWrap: true,
                                      maxLines: 2,
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) => selectedModel = value,
                                decoration: const InputDecoration(
                                    labelText: 'Default Model'),
                                selectedItemBuilder: (BuildContext context) {
                                  return models.map((model) {
                                    return Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        model,
                                        overflow: TextOverflow.ellipsis,
                                        softWrap: true,
                                        maxLines: 1,
                                      ),
                                    );
                                  }).toList();
                                },
                              ),
                            ),
                          if (selectedModel != null &&
                              !models.contains(selectedModel))
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                'Warning: The selected model "$selectedModel" no longer exists.',
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          if (urlController.text.isEmpty && models.isEmpty)
                            const Text(
                              'Enter API URL to fetch models',
                              style: TextStyle(color: Colors.red),
                            ),
                          if (models.isNotEmpty)
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.8,
                              child: DropdownButtonFormField<String>(
                                value: models.contains(selectedSummaryModel)
                                    ? selectedSummaryModel
                                    : null,
                                isExpanded: true,
                                items: models.map((model) {
                                  return DropdownMenuItem(
                                    value: model,
                                    child: Text(
                                      model,
                                      overflow: TextOverflow.ellipsis,
                                      softWrap: true,
                                      maxLines: 2,
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) => selectedSummaryModel = value,
                                decoration: const InputDecoration(
                                    labelText: 'Summarization Model'),
                                selectedItemBuilder: (BuildContext context) {
                                  return models.map((model) {
                                    return Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        model,
                                        overflow: TextOverflow.ellipsis,
                                        softWrap: true,
                                        maxLines: 1,
                                      ),
                                    );
                                  }).toList();
                                },
                              ),
                            ),
                          if (selectedSummaryModel != null &&
                              !models.contains(selectedSummaryModel))
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                'Warning: The selected summary model "$selectedSummaryModel" no longer exists.',
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                        ],
                      ),
                    )));
          },
        );
      },
    );
  }

  Future<void> _createProvider(Provider provider) async {
    final providerId = await DatabaseService.instance.createProvider(provider);
    final newProvider = provider.copyWith(id: providerId);

    // If the provider is the first one, set it as the default
    if (_providers.isEmpty) {
      await _setDefaultProvider(providerId);
    }

    setState(() {
      _providers.add(newProvider);
    });
  }

  Future<void> _updateProvider(Provider provider) async {
    await DatabaseService.instance.updateProvider(provider);
    setState(() {
      _providers =
          _providers.map((p) => p.id == provider.id ? provider : p).toList();
    });
  }

  Future<void> _deleteProvider(int id) async {
    final confirmed = await _showConfirmationDialog(
      context,
      'Delete Provider',
      'Are you sure you want to delete this provider? This action cannot be undone.',
    );

    if (confirmed) {
      await DatabaseService.instance.deleteProviderById(id);
      setState(() {
        _providers.removeWhere((p) => p.id == id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Provider deleted successfully')),
      );
    }
  }

  Future<bool> _showConfirmationDialog(
      BuildContext context, String title, String content) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(title),
              content: Text(content),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Confirm'),
                ),
              ],
            );
          },
        ) ??
        false; // Default to false if dismissed
  }
}
