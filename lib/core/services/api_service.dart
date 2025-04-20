import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class ApiService {
  static const String _baseUrl =
      'https://us-central1-firstproj.cloudfunctions.net';
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Map<String, String>> _getHeaders() async {
    final token = await _auth.currentUser?.getIdToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Fire Alert API Calls
  Future<Map<String, dynamic>> createFireAlert({
    required String location,
    required String severity,
    required String description,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/createFireAlert'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'location': location,
          'severity': severity,
          'description': description,
          'reporterId': _auth.currentUser?.uid,
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create fire alert');
      }
    } catch (e) {
      throw Exception('Error creating fire alert: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getFireAlerts() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/getFireAlerts'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to get fire alerts');
      }
    } catch (e) {
      throw Exception('Error getting fire alerts: $e');
    }
  }

  // User Location API Calls
  Future<void> updateUserLocation({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/updateUserLocation'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'userId': _auth.currentUser?.uid,
          'latitude': latitude,
          'longitude': longitude,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update location');
      }
    } catch (e) {
      throw Exception('Error updating location: $e');
    }
  }

  // Emergency Contacts API Calls
  Future<void> addEmergencyContact({
    required String name,
    required String phone,
    required String relationship,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/addEmergencyContact'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'userId': _auth.currentUser?.uid,
          'contact': {
            'name': name,
            'phone': phone,
            'relationship': relationship,
          },
        }),
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to add emergency contact');
      }
    } catch (e) {
      throw Exception('Error adding emergency contact: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getEmergencyContacts() async {
    try {
      final response = await http.get(
        Uri.parse(
            '$_baseUrl/getEmergencyContacts?userId=${_auth.currentUser?.uid}'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to get emergency contacts');
      }
    } catch (e) {
      throw Exception('Error getting emergency contacts: $e');
    }
  }
}
