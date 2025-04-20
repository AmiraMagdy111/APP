import 'package:flutter/material.dart';
import '../core/services/api_service.dart';
import '../core/theme.dart';
import '../models/fire_alert.dart';
import 'create_alert_screen.dart';

class AlertsListScreen extends StatefulWidget {
  const AlertsListScreen({super.key});

  @override
  State<AlertsListScreen> createState() => _AlertsListScreenState();
}

class _AlertsListScreenState extends State<AlertsListScreen> {
  final _apiService = ApiService();
  List<FireAlert> _alerts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

  Future<void> _loadAlerts() async {
    try {
      final alerts = await _apiService.getFireAlerts();
      setState(() {
        _alerts = alerts.map((json) => FireAlert.fromJson(json)).toList();
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading alerts: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fire Alerts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateAlertScreen(),
                ),
              ).then((_) => _loadAlerts());
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadAlerts,
              child: _alerts.isEmpty
                  ? const Center(
                      child: Text('No fire alerts available'),
                    )
                  : ListView.builder(
                      itemCount: _alerts.length,
                      itemBuilder: (context, index) {
                        final alert = _alerts[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: ListTile(
                            leading: Icon(
                              Icons.warning_amber_rounded,
                              color: _getSeverityColor(alert.severity),
                            ),
                            title: Text(
                              alert.location,
                              style: AppTheme.subheadingStyle,
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(alert.description),
                                const SizedBox(height: 4),
                                Text(
                                  'Severity: ${alert.severity.toUpperCase()}',
                                  style: TextStyle(
                                    color: _getSeverityColor(alert.severity),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Status: ${alert.status}',
                                  style: TextStyle(
                                    color: alert.status == 'active'
                                        ? Colors.red
                                        : Colors.green,
                                  ),
                                ),
                              ],
                            ),
                            trailing: Text(
                              _formatDate(alert.timestamp),
                              style: AppTheme.bodyStyle.copyWith(
                                fontSize: 12,
                              ),
                            ),
                            onTap: () {
                              // TODO: Navigate to alert details screen
                            },
                          ),
                        );
                      },
                    ),
            ),
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'low':
        return Colors.orange;
      case 'medium':
        return Colors.deepOrange;
      case 'high':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }
}
