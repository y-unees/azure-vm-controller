import 'package:flutter/material.dart';
import '../models/azure_vm.dart';
import '../services/storage_service.dart';
import 'add_server_screen.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<AzureVM> _servers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedServers();
  }

  // Fetch the servers from local phone storage
  Future<void> _loadSavedServers() async {
    setState(() => _isLoading = true);
    List<AzureVM> saved = await StorageService.loadServers();
    setState(() {
      _servers = saved;
      _isLoading = false;
    });
  }

  // Delete a server if you ever need to remove it
  Future<void> _deleteServer(int index) async {
    setState(() {
      _servers.removeAt(index);
    });
    await StorageService.saveServers(_servers);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Azure Servers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSavedServers, // Manual refresh button
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _servers.isEmpty
              ? const Center(
                  child: Text(
                    'No servers added yet.\nTap the + button to add one!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: _servers.length,
                  itemBuilder: (context, index) {
                    final vm = _servers[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      elevation: 3,
                      child: ListTile(
                        leading: const Icon(Icons.dns, color: Colors.blue, size: 36),
                        title: Text(
                          vm.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        subtitle: Text('RG: ${vm.resourceGroup}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () => _deleteServer(index),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailScreen(vm: vm),
                            ),
                          ).then((_) => _loadSavedServers()); // Refresh status when returning home
                        },
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Open the Add Server screen and wait to see if a new server was saved
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddServerScreen()),
          );
          
          // If a new server was added, refresh the dashboard list
          if (result == true) {
            _loadSavedServers();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}