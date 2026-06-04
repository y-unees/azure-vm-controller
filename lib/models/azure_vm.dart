class AzureVM {
  final String id;
  final String name;
  final String subscriptionId;
  final String resourceGroup;
  final String tenantId;
  final String clientId;
  final String clientSecret;
  String status; // e.g., "Running", "Deallocated", or "Loading..."

  AzureVM({
    required this.id,
    required this.name,
    required this.subscriptionId,
    required this.resourceGroup,
    required this.tenantId,
    required this.clientId,
    required this.clientSecret,
    this.status = 'Unknown',
  });

  // Convert a VM object into a Map to save it to local storage easily
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'subscriptionId': subscriptionId,
      'resourceGroup': resourceGroup,
      'tenantId': tenantId,
      'clientId': clientId,
      'clientSecret': clientSecret,
    };
  }

  // Convert a saved Map back into a VM object
  factory AzureVM.fromMap(Map<String, dynamic> map) {
    return AzureVM(
      id: map['id'],
      name: map['name'],
      subscriptionId: map['subscriptionId'],
      resourceGroup: map['resourceGroup'],
      tenantId: map['tenantId'],
      clientId: map['clientId'],
      clientSecret: map['clientSecret'],
    );
  }
}