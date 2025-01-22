import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';
import 'package:my_ai_gateway/models/model.dart';
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

  @override
  Widget build(BuildContext context) {
    final themeNotifier = pkg_provider.Provider.of<ThemeNotifier>(context);

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
                initialValue: themeNotifier.isDarkMode,
                onToggle: (value) => themeNotifier.toggleTheme(),
                leading: const Icon(Icons.dark_mode),
                title: const Text('Dark Mode'),
              ),
              SettingsTile.switchTile(
                initialValue: _streamOutput == 1,
                leading: const Icon(Icons.notifications),
                title: const Text('Stream Output'),
                description: const Text(
                  'Rather than waiting for the model to finish, stream tokens/characters as they are generated.',
                ),
                onToggle: (value) => _setStreamOutput(value ? 1 : 0),
              ),
              SettingsTile(
                title: const Text('Reset Database'),
                leading: const Icon(Icons.delete),
                onPressed: (context) async {
                  final confirmed = await _showConfirmationDialog(
                    context,
                    'Reset Database',
                    'This will delete all data. Are you sure you want to proceed?',
                  );

                  if (confirmed) {
                    await DatabaseService.instance.resetDatabase();
                    await _loadProviders();

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Database reset successfully')),
                    );
                  }
                },
              ),
              SettingsTile(
                title: const Text('About'),
                leading: const Icon(Icons.info),
                onPressed: (context) {
                  showAboutDialog(
                    context: context,
                    applicationName: _packageInfo.appName,
                    applicationIcon: Image.asset(
                      'assets/icon/icon.png',
                      height: 40,
                    ),
                    children: <Widget>[
                      _infoTile('Build', "v${_packageInfo.version}b${_packageInfo.buildNumber} - ${Platform.isIOS ? 'iOS' : 'Android'}"),
                      ListTile(
                        title: const Text('GitHub'),
                        subtitle: Text(_githubLink),
                        onTap: () async {
                          if (await canLaunchUrl(Uri.parse(
                              _githubLink))) {
                            await launchUrl(Uri.parse(
                                _githubLink));
                          }
                        },
                        onLongPress: () {
                          Clipboard.setData(ClipboardData(
                            text: "https://github.com/codycody31/my-ai-gateway",
                          ));
                        },
                      ),
                      _infoTile('Package name', _packageInfo.packageName),
                      _infoTile('Build signature', _packageInfo.buildSignature),
                      _infoTile(
                        'Installer store',
                        _packageInfo.installerStore ?? 'not available',
                      ),
                    ],
                  );
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
    String? selectedModel = provider.defaultModel;
    List<String> models = [];

    // Fetch models for the provider if the URL is valid
    Future<List<String>> fetchModels() async {
      if (urlController.text.isNotEmpty) {
        ApiService llmApi = ApiService(
            apiUrl: urlController.text, authToken: authTokenController.text);
        List<Model> m;

        try {
          m = await llmApi.fetchModels();
        } catch (e) {
          return [];
        }

        return m.map((model) => model.id).toList();
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
                          if (models.isNotEmpty)
                            SizedBox(
                              width: MediaQuery.of(context).size.width *
                                  0.8, // Constrain the width
                              child: DropdownButtonFormField<String>(
                                value: selectedModel,
                                isExpanded: true,
                                // Ensures the dropdown expands to fit the screen width
                                items: models.map((model) {
                                  return DropdownMenuItem(
                                    value: model,
                                    child: Text(
                                      model,
                                      overflow: TextOverflow.ellipsis,
                                      // Prevents overflow in the dropdown items
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
                                        // Prevents overflow in the value display
                                        softWrap: true,
                                        maxLines: 1, // Adjust as needed
                                      ),
                                    );
                                  }).toList();
                                },
                              ),
                            ),
                          if (urlController.text.isEmpty && models.isEmpty)
                            const Text(
                              'Enter API URL to fetch models',
                              style: TextStyle(color: Colors.red),
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

  Future<String?> _showModelSelectionDialog(
      BuildContext context, Provider provider) async {
    final models = await _getModelsForProvider(
        provider); // Define a method to get models for the provider.
    String? selectedModel;

    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Select Default Model for ${provider.name}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: models.map((model) {
                return ListTile(
                  title: Text(model.id),
                  onTap: () => Navigator.pop(context, model.id),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<List<Model>> _getModelsForProvider(Provider provider) async {
    ApiService llmApi =
        ApiService(apiUrl: provider.url, authToken: provider.authToken);
    return await llmApi.fetchModels();
  }

  Future<void> _setDefaultModel(int providerId, String modelName) async {
    final key = 'default_model_$providerId';
    await DatabaseService.instance.setConfig(key, modelName);
    setState(() {
      final providerIndex = _providers.indexWhere((p) => p.id == providerId);
      if (providerIndex != -1) {
        _providers[providerIndex] =
            _providers[providerIndex].copyWith(defaultModel: modelName);
      }
    });
  }
}
