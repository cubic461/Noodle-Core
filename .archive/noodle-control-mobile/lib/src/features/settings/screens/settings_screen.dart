import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../shared/widgets/common_widgets.dart';
import '../../../shared/models/models.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../core/app.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isLoading = false;
  AppSettings _appSettings = const AppSettings(
    serverUrl: 'ws://localhost:8080',
    autoConnect: true,
    notificationsEnabled: true,
    darkMode: false,
    themeMode: 'system',
    connectionTimeout: 30,
    maxRetries: 3,
    enableLogging: true,
    logLevel: 'INFO',
  );

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load settings from shared preferences
      final prefs = await SharedPreferences.getInstance();
      final serverUrl = prefs.getString('server_url') ?? 'ws://localhost:8080';
      final autoConnect = prefs.getBool('auto_connect') ?? true;
      final notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      final darkMode = prefs.getBool('dark_mode') ?? false;
      final themeMode = prefs.getString('theme_mode') ?? 'system';
      final connectionTimeout = prefs.getInt('connection_timeout') ?? 30;
      final maxRetries = prefs.getInt('max_retries') ?? 3;
      final enableLogging = prefs.getBool('enable_logging') ?? true;
      final logLevel = prefs.getString('log_level') ?? 'INFO';

      setState(() {
        _appSettings = AppSettings(
          serverUrl: serverUrl,
          autoConnect: autoConnect,
          notificationsEnabled: notificationsEnabled,
          darkMode: darkMode,
          themeMode: themeMode,
          connectionTimeout: connectionTimeout,
          maxRetries: maxRetries,
          enableLogging: enableLogging,
          logLevel: logLevel,
        );
        _isLoading = false;
      });
    } catch (e) {
      App.logger.e('Failed to load settings: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('server_url', _appSettings.serverUrl);
      await prefs.setBool('auto_connect', _appSettings.autoConnect);
      await prefs.setBool('notifications_enabled', _appSettings.notificationsEnabled);
      await prefs.setBool('dark_mode', _appSettings.darkMode);
      await prefs.setString('theme_mode', _appSettings.themeMode);
      await prefs.setInt('connection_timeout', _appSettings.connectionTimeout);
      await prefs.setInt('max_retries', _appSettings.maxRetries);
      await prefs.setBool('enable_logging', _appSettings.enableLogging);
      await prefs.setString('log_level', _appSettings.logLevel);

      // Update app theme mode
      final themeModeNotifier = ref.read(themeModeProvider.notifier);
      switch (_appSettings.themeMode) {
        case 'light':
          themeModeNotifier.setThemeMode(ThemeMode.light);
          break;
        case 'dark':
          themeModeNotifier.setThemeMode(ThemeMode.dark);
          break;
        case 'system':
        default:
          themeModeNotifier.setThemeMode(ThemeMode.system);
          break;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Settings saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      App.logger.e('Failed to save settings: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save settings: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _resetSettings() async {
    try {
      await App.clearAllData();
      await _loadSettings();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Settings reset to defaults'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      App.logger.e('Failed to reset settings: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to reset settings: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _logout() async {
    try {
      await App.clearAllData();
      if (mounted) {
        context.go('/auth/login');
      }
    } catch (e) {
      App.logger.e('Logout failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NoodleAppBar(
        title: 'Settings',
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveSettings,
            tooltip: 'Save Settings',
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Loading settings...')
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Connection Settings
                  _SettingsSection(
                    title: 'Connection',
                    icon: Icons.wifi,
                    child: Column(
                      children: [
                        ListTile(
                          title: const Text('Server URL'),
                          subtitle: Text(_appSettings.serverUrl),
                          trailing: const Icon(Icons.edit),
                          onTap: () => _showServerUrlDialog(),
                        ),
                        SwitchListTile(
                          title: const Text('Auto Connect'),
                          subtitle: const Text('Automatically connect on app start'),
                          value: _appSettings.autoConnect,
                          onChanged: (value) {
                            setState(() {
                              _appSettings = _appSettings.copyWith(autoConnect: value);
                            });
                          },
                        ),
                        ListTile(
                          title: const Text('Connection Timeout'),
                          subtitle: Text('${_appSettings.connectionTimeout} seconds'),
                          trailing: const Icon(Icons.edit),
                          onTap: () => _showConnectionTimeoutDialog(),
                        ),
                        ListTile(
                          title: const Text('Max Retries'),
                          subtitle: Text('${_appSettings.maxRetries} attempts'),
                          trailing: const Icon(Icons.edit),
                          onTap: () => _showMaxRetriesDialog(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Appearance Settings
                  _SettingsSection(
                    title: 'Appearance',
                    icon: Icons.palette,
                    child: Column(
                      children: [
                        ListTile(
                          title: const Text('Theme Mode'),
                          subtitle: Text(_appSettings.themeMode.toUpperCase()),
                          trailing: const Icon(Icons.arrow_drop_down),
                          onTap: () => _showThemeModeDialog(),
                        ),
                        SwitchListTile(
                          title: const Text('Dark Mode'),
                          subtitle: const Text('Override system theme setting'),
                          value: _appSettings.darkMode,
                          onChanged: (value) {
                            setState(() {
                              _appSettings = _appSettings.copyWith(darkMode: value);
                            });
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Notification Settings
                  _SettingsSection(
                    title: 'Notifications',
                    icon: Icons.notifications,
                    child: Column(
                      children: [
                        SwitchListTile(
                          title: const Text('Enable Notifications'),
                          subtitle: const Text('Receive notifications for important events'),
                          value: _appSettings.notificationsEnabled,
                          onChanged: (value) {
                            setState(() {
                              _appSettings = _appSettings.copyWith(notificationsEnabled: value);
                            });
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Logging Settings
                  _SettingsSection(
                    title: 'Logging',
                    icon: Icons.bug_report,
                    child: Column(
                      children: [
                        SwitchListTile(
                          title: const Text('Enable Logging'),
                          subtitle: const Text('Log app activities for debugging'),
                          value: _appSettings.enableLogging,
                          onChanged: (value) {
                            setState(() {
                              _appSettings = _appSettings.copyWith(enableLogging: value);
                            });
                          },
                        ),
                        ListTile(
                          title: const Text('Log Level'),
                          subtitle: Text(_appSettings.logLevel),
                          trailing: const Icon(Icons.arrow_drop_down),
                          onTap: () => _showLogLevelDialog(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // About Section
                  _SettingsSection(
                    title: 'About',
                    icon: Icons.info,
                    child: Column(
                      children: [
                        ListTile(
                          title: const Text('App Version'),
                          subtitle: Text(App.appVersion),
                        ),
                        ListTile(
                          title: const Text('Build Number'),
                          subtitle: Text('1'),
                        ),
                        ListTile(
                          title: const Text('About NoodleControl'),
                          subtitle: const Text('Mobile app for managing Noodle AI development environment'),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () => _showAboutDialog(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Danger Zone
                  _SettingsSection(
                    title: 'Danger Zone',
                    icon: Icons.warning,
                    child: Column(
                      children: [
                        ListTile(
                          title: const Text('Reset Settings'),
                          subtitle: const Text('Reset all settings to default values'),
                          leading: const Icon(Icons.restore, color: Colors.orange),
                          onTap: () => _showResetSettingsDialog(),
                        ),
                        ListTile(
                          title: const Text('Logout'),
                          subtitle: const Text('Sign out of your account'),
                          leading: const Icon(Icons.logout, color: Colors.red),
                          onTap: () => _showLogoutDialog(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 100), // Extra space for bottom navigation
                ],
              ),
            ),
      bottomNavigationBar: NoodleBottomNavigationBar(
        currentIndex: 4,
        onTap: (index) {
          if (index != 4) {
            switch (index) {
              case 0:
                context.go('/dashboard');
                break;
              case 1:
                context.go('/ide-control');
                break;
              case 2:
                context.go('/node-management');
                break;
              case 3:
                context.go('/reasoning-monitoring');
                break;
            }
          }
        },
      ),
    );
  }

  void _showServerUrlDialog() {
    final controller = TextEditingController(text: _appSettings.serverUrl);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Server URL'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'ws://localhost:8080',
            labelText: 'Server URL',
          ),
          keyboardType: TextInputType.url,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _appSettings = _appSettings.copyWith(serverUrl: controller.text.trim());
              });
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showConnectionTimeoutDialog() {
    final controller = TextEditingController(text: _appSettings.connectionTimeout.toString());
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Connection Timeout'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Timeout (seconds)',
            hintText: '30',
          ),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final timeout = int.tryParse(controller.text) ?? 30;
              setState(() {
                _appSettings = _appSettings.copyWith(connectionTimeout: timeout);
              });
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showMaxRetriesDialog() {
    final controller = TextEditingController(text: _appSettings.maxRetries.toString());
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Max Retries'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Max Retries',
            hintText: '3',
          ),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final maxRetries = int.tryParse(controller.text) ?? 3;
              setState(() {
                _appSettings = _appSettings.copyWith(maxRetries: maxRetries);
              });
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showThemeModeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Theme Mode'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('System'),
              value: 'system',
              groupValue: _appSettings.themeMode,
              onChanged: (value) {
                setState(() {
                  _appSettings = _appSettings.copyWith(themeMode: value!);
                });
                Navigator.of(context).pop();
              },
            ),
            RadioListTile<String>(
              title: const Text('Light'),
              value: 'light',
              groupValue: _appSettings.themeMode,
              onChanged: (value) {
                setState(() {
                  _appSettings = _appSettings.copyWith(themeMode: value!);
                });
                Navigator.of(context).pop();
              },
            ),
            RadioListTile<String>(
              title: const Text('Dark'),
              value: 'dark',
              groupValue: _appSettings.themeMode,
              onChanged: (value) {
                setState(() {
                  _appSettings = _appSettings.copyWith(themeMode: value!);
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLogLevelDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Level'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('DEBUG'),
              value: 'DEBUG',
              groupValue: _appSettings.logLevel,
              onChanged: (value) {
                setState(() {
                  _appSettings = _appSettings.copyWith(logLevel: value!);
                });
                Navigator.of(context).pop();
              },
            ),
            RadioListTile<String>(
              title: const Text('INFO'),
              value: 'INFO',
              groupValue: _appSettings.logLevel,
              onChanged: (value) {
                setState(() {
                  _appSettings = _appSettings.copyWith(logLevel: value!);
                });
                Navigator.of(context).pop();
              },
            ),
            RadioListTile<String>(
              title: const Text('WARNING'),
              value: 'WARNING',
              groupValue: _appSettings.logLevel,
              onChanged: (value) {
                setState(() {
                  _appSettings = _appSettings.copyWith(logLevel: value!);
                });
                Navigator.of(context).pop();
              },
            ),
            RadioListTile<String>(
              title: const Text('ERROR'),
              value: 'ERROR',
              groupValue: _appSettings.logLevel,
              onChanged: (value) {
                setState(() {
                  _appSettings = _appSettings.copyWith(logLevel: value!);
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: App.appName,
      applicationVersion: App.appVersion,
      applicationIcon: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.code,
          size: 24,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
      children: [
        const Text('Mobile app for managing Noodle AI development environment.'),
        const SizedBox(height: 16),
        const Text('© 2023 NoodleControl. All rights reserved.'),
      ],
    );
  }

  void _showResetSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text('Are you sure you want to reset all settings to their default values? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetSettings();
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout? You will need to sign in again to access your account.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _logout();
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SettingsSection({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          child,
        ],
      ),
    );
  }
}