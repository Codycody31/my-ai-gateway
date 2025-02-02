import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:url_launcher/url_launcher.dart';

class ModelDetailsPage extends StatefulWidget {
  final String modelName;
  final String providerType;

  const ModelDetailsPage(
      {super.key, required this.modelName, required this.providerType});

  @override
  _ModelDetailsPageState createState() => _ModelDetailsPageState();
}

class _ModelDetailsPageState extends State<ModelDetailsPage> {
  Map<String, dynamic>? _modelDetails;
  bool _loading = true;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _fetchModelDetails();
  }

  Future<void> _fetchModelDetails() async {
    setState(() {
      _loading = true;
      _error = false;
    });

    try {
      if (widget.providerType == 'openai') {
        // Simulate fetching OpenAI model details (replace with actual API if available)
        await Future.delayed(const Duration(seconds: 1)); // Simulate API delay
        setState(() {
          _modelDetails = {
            'modelId': widget.modelName,
            'description': 'This is an OpenAI model.',
            'link': 'https://platform.openai.com/docs/models'
          };
          _loading = false;
        });
      } else {
        var modelName = widget.modelName;
        // If hf.co in model name strip it out
        if (modelName.contains('hf.co')) {
          modelName = modelName.split('hf.co/').last;
        }

        // If : in model name strip it out and everything after it
        if (modelName.contains(':')) {
          modelName = modelName.split(':').first;
        }

        final response = await http.get(
          Uri.parse(
            'https://huggingface.co/api/models?search=$modelName',
          ),
        );

        if (response.statusCode == 200) {
          final List<dynamic> models = json.decode(response.body);
          if (models.isNotEmpty) {
            setState(() {
              _modelDetails = models.first;
              _loading = false;
            });
          } else {
            setState(() {
              _error = true;
              _loading = false;
            });
          }
        } else {
          throw Exception('Failed to fetch model details');
        }
      }
    } catch (e) {
      debugPrint('Error fetching model details: $e');
      setState(() {
        _error = true;
        _loading = false;
      });
    }
  }

  Widget _getLogo() {
    final isOpenAI = widget.providerType == 'openai';
    return Image.asset(
      isOpenAI ? 'assets/openai_logo.png' : 'assets/huggingface_logo.png',
      height: 50,
      color: isOpenAI && Theme.of(context).brightness == Brightness.dark
          ? Colors.white
          : null,
    );
  }

  Widget _buildContent(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    if (widget.providerType == 'openai' && _modelDetails != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: _getLogo(),
          ),
          const SizedBox(height: 16),
          Text(
            'Model: ${_modelDetails!['modelId']}',
            style: textTheme.titleLarge?.copyWith(color: colorScheme.primary),
          ),
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 18),
          Text(
            _modelDetails!['description'],
            style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
          ),
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.secondary,
                foregroundColor: colorScheme.onSecondary,
              ),
              onPressed: () {
                final url = _modelDetails!['link'];
                _openUrl(context, url);
              },
              child: const Text('View on OpenAI'),
            ),
          ),
        ],
      );
    } else if (_modelDetails != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: _getLogo(),
          ),
          const SizedBox(height: 16),
          Text(
            'Model: ${_modelDetails!['modelId']}',
            style: textTheme.titleLarge?.copyWith(color: colorScheme.primary),
          ),
          const SizedBox(height: 8),
          Text(
            'The details below are fetched from Hugging Face and may not be entirely accurate.',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const Divider(),
          const SizedBox(height: 16),
          if (_modelDetails!.containsKey('likes'))
            Text(
              'Likes: ${_modelDetails!['likes']}',
              style:
                  textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
            ),
          if (_modelDetails!.containsKey('downloads'))
            Text(
              'Downloads: ${_modelDetails!['downloads']}',
              style:
                  textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
            ),
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.secondary,
                foregroundColor: colorScheme.onSecondary,
              ),
              onPressed: () {
                if (_modelDetails!['id'] != null) {
                  final url = 'https://huggingface.co/${_modelDetails!['id']}';
                  _openUrl(context, url);
                }
              },
              child: const Text('View on Hugging Face'),
            ),
          ),
        ],
      );
    } else {
      return Text(
        'No details available.',
        style: textTheme.bodyMedium?.copyWith(color: colorScheme.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.modelName,
          style: textTheme.titleLarge?.copyWith(color: colorScheme.onPrimary),
        ),
        backgroundColor: colorScheme.primary,
        iconTheme: IconThemeData(color: colorScheme.onPrimary),
      ),
      body: _loading
          ? Center(
              child: CircularProgressIndicator(color: colorScheme.primary),
            )
          : _error
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Error fetching model details.',
                        style: textTheme.bodyLarge?.copyWith(
                          color: colorScheme.error,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                        ),
                        onPressed: _fetchModelDetails,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildContent(context),
                ),
    );
  }

  Future<void> _openUrl(BuildContext context, String url) async {
    if (await canLaunchUrl((Uri.parse(url)))) {
      launchUrl(Uri.parse(url));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not launch $url'),
        ),
      );
    }
  }
}
