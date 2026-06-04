import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/azure_vm.dart';

class AzureApiService {
  // 1. Get OAuth2 Access Token from Microsoft Entra ID
  static Future<String?> _getAccessToken(AzureVM vm) async {
    final url = Uri.parse('https://login.microsoftonline.com/${vm.tenantId}/oauth2/v2.0/token');
    
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'grant_type': 'client_credentials',
          'client_id': vm.clientId,
          'client_secret': vm.clientSecret,
          'scope': 'https://management.azure.com/.default',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['access_token'];
      } else {
        print('Auth Error: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Auth Exception: $e');
      return null;
    }
  }

  // 2. Fetch current VM status (Running vs Deallocated)
  static Future<String> getVMStatus(AzureVM vm) async {
    final token = await _getAccessToken(vm);
    if (token == null) return 'Auth Error';

    final url = Uri.parse(
      'https://management.azure.com/subscriptions/${vm.subscriptionId}/resourceGroups/${vm.resourceGroup}/providers/Microsoft.Compute/virtualMachines/${vm.name}/instanceView?api-version=2021-07-01'
    );

    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final statuses = data['statuses'] as List;
        
        // Look through statuses for the PowerState
        for (var status in statuses) {
          final code = status['code'] as String;
          if (code.startsWith('PowerState/')) {
            // Returns clean string like "running" or "deallocated"
            return code.replaceFirst('PowerState/', ''); 
          }
        }
        return 'Unknown';
      } else {
        return 'API Error (${response.statusCode})';
      }
    } catch (e) {
      return 'Offline/Error';
    }
  }

  // 3. Send Control Commands (Start or Deallocate)
  // action variable must be either 'start' or 'deallocate'
  static Future<bool> runVMAction(AzureVM vm, String action) async {
    final token = await _getAccessToken(vm);
    if (token == null) return false;

    final url = Uri.parse(
      'https://management.azure.com/subscriptions/${vm.subscriptionId}/resourceGroups/${vm.resourceGroup}/providers/Microsoft.Compute/virtualMachines/${vm.name}/$action?api-version=2021-07-01'
    );

    try {
      final response = await http.post(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      // Azure answers with 202 (Accepted) for asynchronous start/stop actions
      return response.statusCode == 202 || response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}