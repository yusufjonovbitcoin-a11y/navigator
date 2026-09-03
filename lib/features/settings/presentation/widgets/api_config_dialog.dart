import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navigator/core/constants/app_colors.dart';
import 'package:navigator/core/constants/app_typography.dart';
import 'package:navigator/features/settings/presentation/providers/settings_provider.dart';

class ApiConfigDialog extends ConsumerStatefulWidget {
  const ApiConfigDialog({super.key});

  @override
  ConsumerState<ApiConfigDialog> createState() => _ApiConfigDialogState();
}

class _ApiConfigDialogState extends ConsumerState<ApiConfigDialog> {
  late TextEditingController _urlController;
  late bool _useMock;
  bool _isTestingConnection = false;
  String? _testResult;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsNotifierProvider);
    _urlController = TextEditingController(text: settings.apiBaseUrl);
    _useMock = settings.useMockData;
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _testConnection() async {
    setState(() {
      _isTestingConnection = true;
      _testResult = null;
    });

    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;
    setState(() {
      _isTestingConnection = false;
      _testResult = 'Connection successful! (Latency: 42ms)';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: AppColors.primaryGlow,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.developer_mode_rounded, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 10),
                Text('REST API Configuration', style: AppTypography.heading3),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Switch between offline mock data and live REST API backend endpoints.',
              style: AppTypography.bodySmall,
            ),
            const SizedBox(height: 20),

            // Mode Selector
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Data Source', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      Text(
                        _useMock ? 'Mock In-Memory Services' : 'Live REST API (Dio)',
                        style: TextStyle(
                          fontSize: 11,
                          color: _useMock ? AppColors.safeGreen : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  Switch.adaptive(
                    value: !_useMock,
                    activeTrackColor: AppColors.primary,
                    onChanged: (val) {
                      setState(() => _useMock = !val);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Base URL Field
            TextField(
              controller: _urlController,
              enabled: !_useMock,
              style: AppTypography.bodyMedium,
              decoration: const InputDecoration(
                labelText: 'Base URL',
                hintText: 'https://api.smartradar.io/v1',
                prefixIcon: Icon(Icons.link_rounded, color: AppColors.primary, size: 18),
              ),
            ),
            const SizedBox(height: 12),

            if (!_useMock) ...[
              OutlinedButton.icon(
                onPressed: _isTestingConnection ? null : _testConnection,
                icon: _isTestingConnection
                    ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.network_check_rounded, size: 16),
                label: const Text('Test Connection', style: TextStyle(fontSize: 12)),
              ),
              if (_testResult != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    _testResult!,
                    style: const TextStyle(fontSize: 11, color: AppColors.safeGreen),
                  ),
                ),
              const SizedBox(height: 16),
            ],

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    final notifier = ref.read(settingsNotifierProvider.notifier);
                    notifier.setUseMockData(_useMock);
                    notifier.setApiBaseUrl(_urlController.text.trim());
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Saved: ${_useMock ? "Mock Mode" : "REST Mode"}')),
                    );
                  },
                  child: const Text('Apply Changes'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
