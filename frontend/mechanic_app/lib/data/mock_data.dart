class MockData {
  static final List<Map<String, dynamic>> completedJobs = [
    {
      'id': '1',
      'service_type': 'General Service',
      'customer_name': 'John Doe',
      'address': '123 Main St, City',
      'vehicle': {
        'make': 'Honda',
        'model': 'City',
        'year': '2020',
      },
      'status': 'completed',
      'completed_at': '2024-03-15T10:30:00Z',
      'notes': 'Regular maintenance completed successfully',
      'amount': 2500.00,
    },
    {
      'id': '2',
      'service_type': 'AC Repair',
      'customer_name': 'Jane Smith',
      'address': '456 Park Ave, Town',
      'vehicle': {
        'make': 'Toyota',
        'model': 'Innova',
        'year': '2021',
      },
      'status': 'completed',
      'completed_at': '2024-03-14T15:45:00Z',
      'notes': 'AC compressor replaced',
      'amount': 3500.00,
    },
  ];

  static final List<Map<String, dynamic>> activeJobs = [
    {
      'id': '3',
      'service_type': 'Brake Service',
      'customer_name': 'Mike Johnson',
      'address': '789 Oak St, Village',
      'vehicle': {
        'make': 'Hyundai',
        'model': 'Creta',
        'year': '2019',
      },
      'status': 'in_progress',
      'scheduled_at': '2024-03-16T09:00:00Z',
      'notes': 'Brake pads need replacement',
      'amount': 1800.00,
    },
  ];
}
