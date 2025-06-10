class Job {
  final String id;
  final String serviceType;
  final String customerName;
  final String location;
  final String status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? notes;

  Job({
    required this.id,
    required this.serviceType,
    required this.customerName,
    required this.location,
    required this.status,
    required this.createdAt,
    this.completedAt,
    this.notes,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'] as String,
      serviceType: json['service_type'] as String,
      customerName: json['customer_name'] as String,
      location: json['location'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'service_type': serviceType,
      'customer_name': customerName,
      'location': location,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'notes': notes,
    };
  }
}
