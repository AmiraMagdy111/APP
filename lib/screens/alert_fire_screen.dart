import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class FireAlertScreen extends StatelessWidget {
  const FireAlertScreen({super.key});

  Future<void> _callEmergency() async {
    final Uri phoneNumber = Uri.parse('tel:998');
    if (await canLaunchUrl(phoneNumber)) {
      await launchUrl(phoneNumber);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تنبيه حريق'),
        backgroundColor: Colors.red,
        actions: [
          IconButton(
            icon: const Icon(Icons.phone),
            onPressed: _callEmergency,
            tooltip: 'اتصل بالدفاع المدني',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Card(
              color: Colors.red,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 64,
                      color: Colors.white,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'تنبيه حريق!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'إجراءات الطوارئ:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildEmergencyStep(
              '1. ابق هادئاً ولا تهلع',
              Icons.psychology,
            ),
            _buildEmergencyStep(
              '2. اتصل بالدفاع المدني فوراً',
              Icons.phone,
            ),
            _buildEmergencyStep(
              '3. اتبع إرشادات الإخلاء',
              Icons.directions_run,
            ),
            _buildEmergencyStep(
              '4. استخدم أقرب مخرج آمن',
              Icons.exit_to_app,
            ),
            _buildEmergencyStep(
              '5. لا تستخدم المصاعد',
              Icons.elevator,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _callEmergency,
              icon: const Icon(Icons.phone),
              label: const Text('اتصل بالدفاع المدني (998)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 16),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'معلومات إضافية:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• تأكد من معرفة موقع أقرب مخرج طوارئ\n'
                      '• تعرف على خطة الإخلاء في المبنى\n'
                      '• احتفظ بأرقام الطوارئ في متناول اليد\n'
                      '• لا تعود إلى المبنى حتى يتم الإعلان عن انتهاء الخطر',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyStep(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.red),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
