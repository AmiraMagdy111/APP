import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme.dart';
import '../utils/navigation_service.dart';

class PermissionRequestScreen extends StatefulWidget {
  const PermissionRequestScreen({super.key});

  @override
  State<PermissionRequestScreen> createState() =>
      _PermissionRequestScreenState();
}

class _PermissionRequestScreenState extends State<PermissionRequestScreen> {
  bool _isLoading = false;

  Future<void> _requestPermissions() async {
    setState(() => _isLoading = true);

    try {
      // Request notification permission
      final notificationStatus = await Permission.notification.request();

      // Request location permission (if needed)
      final locationStatus = await Permission.location.request();

      if (notificationStatus.isGranted) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('permissions_granted', true);

        if (mounted) {
          NavigationService.navigateTo('/auth');
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('Please grant notification permissions to continue'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error requesting permissions: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.notifications_active,
                size: 120,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(height: 32),
              Text(
                'Enable Notifications',
                style: AppTheme.headingStyle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'We need your permission to send you important fire alerts and emergency notifications.',
                style: AppTheme.bodyStyle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Why we need these permissions:',
                        style: AppTheme.subheadingStyle,
                      ),
                      SizedBox(height: 8),
                      _PermissionItem(
                        icon: Icons.warning_amber_rounded,
                        text: 'Receive instant fire alerts',
                      ),
                      _PermissionItem(
                        icon: Icons.directions_run,
                        text: 'Get evacuation instructions',
                      ),
                      _PermissionItem(
                        icon: Icons.phone,
                        text: 'Emergency contact information',
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _isLoading ? null : _requestPermissions,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Enable Notifications'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PermissionItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _PermissionItem({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppTheme.primaryColor,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: AppTheme.bodyStyle,
            ),
          ),
        ],
      ),
    );
  }
}
