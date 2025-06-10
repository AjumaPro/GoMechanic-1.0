import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gomechanic_user/providers/vehicle_provider.dart';
import 'package:gomechanic_user/widgets/custom_button.dart';

class ServiceSelectionScreen extends StatefulWidget {
  const ServiceSelectionScreen({Key? key}) : super(key: key);

  @override
  State<ServiceSelectionScreen> createState() => _ServiceSelectionScreenState();
}

class _ServiceSelectionScreenState extends State<ServiceSelectionScreen> {
  String? _selectedService;
  String? _selectedVehicleId;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _services = [
    {
      'id': 'general_service',
      'title': 'General Service',
      'description': 'Complete check-up and maintenance of your vehicle',
      'icon': Icons.build,
      'color': Colors.blue,
    },
    {
      'id': 'repair',
      'title': 'Repair',
      'description': 'Fix any issues with your vehicle',
      'icon': Icons.handyman,
      'color': Colors.orange,
    },
    {
      'id': 'inspection',
      'title': 'Inspection',
      'description': 'Thorough inspection of your vehicle',
      'icon': Icons.search,
      'color': Colors.green,
    },
    {
      'id': 'emergency',
      'title': 'Emergency Service',
      'description': 'Immediate assistance for breakdowns',
      'icon': Icons.emergency,
      'color': Colors.red,
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadVehicles();
    });
  }

  Future<void> _loadVehicles() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      await context.read<VehicleProvider>().loadVehicles();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _proceedToDateTimeSelection() {
    if (_selectedService == null || _selectedVehicleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both a service and a vehicle'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.of(context).pushNamed(
      '/bookings/date-time',
      arguments: {
        'serviceId': _selectedService,
        'vehicleId': _selectedVehicleId,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Service'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Choose a Service',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ..._services.map((service) => Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: service['color'],
                            child: Icon(
                              service['icon'],
                              color: Colors.white,
                            ),
                          ),
                          title: Text(service['title']),
                          subtitle: Text(service['description']),
                          selected: _selectedService == service['id'],
                          onTap: () {
                            setState(() {
                              _selectedService = service['id'];
                            });
                          },
                        ),
                      )),
                  const SizedBox(height: 32),
                  const Text(
                    'Select Vehicle',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Consumer<VehicleProvider>(
                    builder: (context, provider, child) {
                      if (provider.vehicles.isEmpty) {
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                const Text(
                                  'No vehicles added yet',
                                  style: TextStyle(fontSize: 16),
                                ),
                                const SizedBox(height: 16),
                                CustomButton(
                                  onPressed: () {
                                    Navigator.of(context)
                                        .pushNamed('/vehicles/add');
                                  },
                                  child: const Text('Add Vehicle'),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return Column(
                        children: provider.vehicles.map((vehicle) {
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: ListTile(
                              title: Text(
                                '${vehicle['make']} ${vehicle['model']}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                '${vehicle['year']} • ${vehicle['license_plate']}',
                              ),
                              selected: _selectedVehicleId == vehicle['id'],
                              onTap: () {
                                setState(() {
                                  _selectedVehicleId = vehicle['id'];
                                });
                              },
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  CustomButton(
                    onPressed: _proceedToDateTimeSelection,
                    child: const Text('Continue'),
                  ),
                ],
              ),
            ),
    );
  }
}
