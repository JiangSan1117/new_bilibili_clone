// lib/utils/firebase_diagnostics.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseDiagnostics {
  static Future<Map<String, dynamic>> runDiagnostics() async {
    Map<String, dynamic> results = {
      'firebase_initialized': false,
      'auth_available': false,
      'project_id': '',
      'auth_domain': '',
      'errors': <String>[],
    };

    try {
      // 檢查 Firebase 是否已初始化
      if (Firebase.apps.isNotEmpty) {
        results['firebase_initialized'] = true;
        
        // 獲取項目信息
        final app = Firebase.app();
        results['project_id'] = app.options.projectId ?? 'Unknown';
        results['auth_domain'] = app.options.authDomain ?? 'Unknown';
        
        // 檢查 Auth 是否可用
        try {
          final auth = FirebaseAuth.instance;
          results['auth_available'] = true;
          
          // 測試 Auth 狀態
          final currentUser = auth.currentUser;
          results['current_user'] = currentUser?.email ?? 'No user';
          
        } catch (e) {
          results['errors'].add('Auth not available: ${e.toString()}');
        }
      } else {
        results['errors'].add('Firebase not initialized');
      }
    } catch (e) {
      results['errors'].add('Firebase initialization error: ${e.toString()}');
    }

    return results;
  }

  static Widget buildDiagnosticsWidget(Map<String, dynamic> diagnostics) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Firebase 診斷結果',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          _buildStatusRow('Firebase 初始化', diagnostics['firebase_initialized']),
          _buildStatusRow('Auth 可用', diagnostics['auth_available']),
          _buildInfoRow('項目 ID', diagnostics['project_id']),
          _buildInfoRow('Auth 域名', diagnostics['auth_domain']),
          
          if (diagnostics['errors'].isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text(
              '錯誤信息:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            ...diagnostics['errors'].map<Widget>((error) => Padding(
              padding: const EdgeInsets.only(left: 8, top: 4),
              child: Text(
                '• $error',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.red,
                ),
              ),
            )),
          ],
        ],
      ),
    );
  }

  static Widget _buildStatusRow(String label, bool status) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            status ? Icons.check_circle : Icons.error,
            color: status ? Colors.green : Colors.red,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text('$label: ${status ? '正常' : '錯誤'}'),
        ],
      ),
    );
  }

  static Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          const Icon(Icons.info, color: Colors.blue, size: 16),
          const SizedBox(width: 8),
          Text('$label: $value'),
        ],
      ),
    );
  }
}
