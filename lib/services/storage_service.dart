import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/azure_vm.dart';

class StorageService {
  static const String _storageKey = 'azure_vms';

  // Save the entire list of servers to the phone's memory
  static Future<void> saveServers(List<AzureVM> servers) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    
    // Convert our list of VM objects into a list of JSON strings
    List<String> jsonList = servers.map((vm) => jsonEncode(vm.toMap())).toList();
    
    await prefs.setStringList(_storageKey, jsonList);
  }

  // Load the list of servers from the phone's memory
  static Future<List<AzureVM>> loadServers() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String>? jsonList = prefs.getStringList(_storageKey);

    if (jsonList == null) {
      return []; // Return an empty list if no servers are saved yet
    }

    // Convert the JSON strings back into our Dart AzureVM objects
    return jsonList.map((item) => AzureVM.fromMap(jsonDecode(item))).toList();
  }
}