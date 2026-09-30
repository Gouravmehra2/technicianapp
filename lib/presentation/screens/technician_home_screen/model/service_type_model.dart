class ServiceTypeResponse {
  final bool success;
  final List<ServiceType> serviceTypes;

  const ServiceTypeResponse({
    required this.success,
    required this.serviceTypes,
  });

  factory ServiceTypeResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final rawTypes = data is Map<String, dynamic> ? data['serviceTypes'] : null;
    return ServiceTypeResponse(
      success: json['success'] == true,
      serviceTypes: rawTypes is List
          ? rawTypes
                .whereType<Map<String, dynamic>>()
                .map(ServiceType.fromJson)
                .toList()
          : const [],
    );
  }
}

class ServiceType {
  final String id;
  final String name;
  final bool isActive;

  const ServiceType({
    required this.id,
    required this.name,
    required this.isActive,
  });

  factory ServiceType.fromJson(Map<String, dynamic> json) {
    return ServiceType(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unnamed service',
      isActive: json['isActive'] != false,
    );
  }
}
