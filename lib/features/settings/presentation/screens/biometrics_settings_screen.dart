import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

/// Screen for biometric authentication settings
class BiometricsSettingsScreen extends StatefulWidget {
  const BiometricsSettingsScreen({super.key});

  @override
  State<BiometricsSettingsScreen> createState() =>
      _BiometricsSettingsScreenState();
}

class _BiometricsSettingsScreenState extends State<BiometricsSettingsScreen> {
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _isAvailable = false;
  bool _isAuthenticated = false;
  List<BiometricType> _availableBiometrics = [];
  String _statusMessage = 'Checking biometrics...';

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isSupported = await _localAuth.isDeviceSupported();
      final available = await _localAuth.getAvailableBiometrics();

      setState(() {
        _isAvailable = canCheck && isSupported;
        _availableBiometrics = available;
        _statusMessage = _isAvailable
            ? 'Biometrics available'
            : 'Biometrics not available on this device';
      });
    } catch (e) {
      setState(() {
        _isAvailable = false;
        _statusMessage = 'Error checking biometrics: $e';
      });
    }
  }

  Future<void> _authenticate() async {
    if (!_isAvailable) {
      _showSnackBar('Biometrics not available');
      return;
    }

    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to access secure features',
      );

      setState(() {
        _isAuthenticated = authenticated;
        _statusMessage = authenticated
            ? 'Authentication successful!'
            : 'Authentication failed';
      });

      _showSnackBar(
        authenticated ? 'Authenticated successfully!' : 'Authentication failed',
        isSuccess: authenticated,
      );
    } catch (e) {
      setState(() {
        _statusMessage = 'Authentication error: $e';
      });
      _showSnackBar('Error: $e', isSuccess: false);
    }
  }

  void _showSnackBar(String message, {bool isSuccess = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
      ),
    );
  }

  String _getBiometricName(BiometricType type) {
    switch (type) {
      case BiometricType.face:
        return 'Face ID';
      case BiometricType.fingerprint:
        return 'Fingerprint';
      case BiometricType.iris:
        return 'Iris';
      case BiometricType.strong:
        return 'Strong';
      case BiometricType.weak:
        return 'Weak';
    }
  }

  IconData _getBiometricIcon(BiometricType type) {
    switch (type) {
      case BiometricType.face:
        return Icons.face;
      case BiometricType.fingerprint:
        return Icons.fingerprint;
      case BiometricType.iris:
        return Icons.remove_red_eye;
      default:
        return Icons.security;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Biometrics')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Status card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Biometric Status',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        _isAvailable ? Icons.check_circle : Icons.error,
                        color: _isAvailable ? Colors.green : Colors.orange,
                      ),
                    ],
                  ),
                  const Divider(),
                  Text(_statusMessage),
                  const SizedBox(height: 8),
                  _buildStatusRow('Available', _isAvailable),
                  _buildStatusRow('Authenticated', _isAuthenticated),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Available biometrics
          if (_availableBiometrics.isNotEmpty) ...[
            const Text(
              'Available Methods',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableBiometrics.map((type) {
                return Chip(
                  avatar: Icon(_getBiometricIcon(type), size: 18),
                  label: Text(_getBiometricName(type)),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],

          // Authentication button
          ElevatedButton.icon(
            onPressed: _isAvailable ? _authenticate : null,
            icon: const Icon(Icons.fingerprint),
            label: const Text('Authenticate with Biometrics'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
            ),
          ),

          const SizedBox(height: 16),

          // Refresh button
          OutlinedButton.icon(
            onPressed: _checkBiometrics,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh Status'),
          ),

          const SizedBox(height: 24),

          // Info card
          Card(
            color: const Color(0xFFE3F2FD),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        'Testing Tips',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    '- On iOS Simulator: Use Features > Face ID > Enrolled\n'
                    '- Then use Features > Face ID > Matching Face to simulate success\n'
                    '- On real device: Use your actual biometrics',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, bool value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label),
          const Spacer(),
          Icon(
            value ? Icons.check : Icons.close,
            color: value ? Colors.green : Colors.grey,
            size: 20,
          ),
        ],
      ),
    );
  }
}
