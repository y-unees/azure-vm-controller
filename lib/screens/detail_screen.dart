import 'package:flutter/material.dart';
import '../models/azure_vm.dart';
import '../services/azure_api_service.dart';

class DetailScreen extends StatefulWidget {
  final AzureVM vm;
  const DetailScreen({super.key, required this.vm});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  String _status = 'Loading...';
  bool _isActionLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchStatus();
  }

  Future<void> _fetchStatus() async {
    setState(() => _status = 'Loading...');
    String currentStatus = await AzureApiService.getVMStatus(widget.vm);
    setState(() => _status = currentStatus);
  }

  Future<void> _triggerAction(String action) async {
    setState(() => _isActionLoading = true);
    
    bool success = await AzureApiService.runVMAction(widget.vm, action);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(success ? 'Command sent successfully!' : 'Failed to send command.')),
      );
    }

    // Wait a couple seconds for Azure to process, then update status
    await Future.delayed(const Duration(seconds: 3));
    _fetchStatus();
    setState(() => _isActionLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    // Determine color of status badge
    Color statusColor = Colors.grey;
    if (_status == 'running') statusColor = Colors.green;
    if (_status == 'deallocated') statusColor = Colors.redAccent;
    if (_status.contains('Error') || _status.contains('Offline')) statusColor = Colors.orangeAccent;

    // Strict condition checking:
    // Buttons are hard-locked if loading, executing an action, or if an error occurred.
    final bool isError = _status.contains('Error') || _status.contains('Offline') || _status == 'Unknown';
    final bool isDisabled = _status == 'Loading...' || _isActionLoading || isError;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.vm.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isActionLoading ? null : _fetchStatus, 
            tooltip: 'Refresh Status',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_queue, size: 80, color: Colors.blue),
              const SizedBox(height: 20),
              Text(widget.vm.name, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              Text('Resource Group: ${widget.vm.resourceGroup}', style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 40),
              
              // Status Card Indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor, width: 2),
                ),
                child: Text(
                  _status.toUpperCase(),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: statusColor),
                ),
              ),
              const SizedBox(height: 60),

              // Action Buttons
              if (_isActionLoading)
                const CircularProgressIndicator()
              else ...[
                ElevatedButton.icon(
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('START SERVER'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(220, 50),
                  ),
                  // Active ONLY if NOT disabled AND explicitly deallocated
                  onPressed: (isDisabled || _status != 'deallocated') 
                      ? null 
                      : () => _triggerAction('start'),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.stop),
                  label: const Text('STOP (DEALLOCATE)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(220, 50),
                  ),
                  // Active ONLY if NOT disabled AND explicitly running
                  onPressed: (isDisabled || _status != 'running') 
                      ? null 
                      : () => _triggerAction('deallocate'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}