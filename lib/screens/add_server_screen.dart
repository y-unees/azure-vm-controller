import 'package:flutter/material.dart';
import '../models/azure_vm.dart';
import '../services/storage_service.dart';

class AddServerScreen extends StatefulWidget {
  const AddServerScreen({super.key});

  @override
  State<AddServerScreen> createState() => _AddServerScreenState();
}

class _AddServerScreenState extends State<AddServerScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers to grab the text from our input boxes
  final _nameController = TextEditingController();
  final _subIdController = TextEditingController();
  final _rgController = TextEditingController();
  final _tenantController = TextEditingController();
  final _clientController = TextEditingController();
  final _secretController = TextEditingController();

  @override
  void dispose() {
    // Clean up controllers when the screen is closed
    _nameController.dispose();
    _subIdController.dispose();
    _rgController.dispose();
    _tenantController.dispose();
    _clientController.dispose();
    _secretController.dispose();
    super.dispose();
  }

  Future<void> _saveForm() async {
    if (_formKey.currentState!.validate()) {
      // 1. Load existing servers first so we don't overwrite them
      List<AzureVM> currentServers = await StorageService.loadServers();

      // 2. Create a new VM object from the input data
      AzureVM newVM = AzureVM(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // Unique ID
        name: _nameController.text.trim(),
        subscriptionId: _subIdController.text.trim(),
        resourceGroup: _rgController.text.trim(),
        tenantId: _tenantController.text.trim(),
        clientId: _clientController.text.trim(),
        clientSecret: _secretController.text.trim(),
      );

      // 3. Add to list and save
      currentServers.add(newVM);
      await StorageService.saveServers(currentServers);

      // 4. Go back to the main dashboard screen
      if (mounted) {
        Navigator.pop(context, true); 
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Azure Server')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'VM Name (Exact name in Azure)'),
                validator: (val) => val!.isEmpty ? 'Please enter the VM name' : null,
              ),
              TextFormField(
                controller: _subIdController,
                decoration: const InputDecoration(labelText: 'Subscription ID'),
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _rgController,
                decoration: const InputDecoration(labelText: 'Resource Group Name'),
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _tenantController,
                decoration: const InputDecoration(labelText: 'Tenant ID'),
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _clientController,
                decoration: const InputDecoration(labelText: 'Client (Application) ID'),
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _secretController,
                decoration: const InputDecoration(labelText: 'Client Secret Value'),
                obscureText: true, // Hides the password/secret text
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _saveForm,
                style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                child: const Text('Save Server', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}