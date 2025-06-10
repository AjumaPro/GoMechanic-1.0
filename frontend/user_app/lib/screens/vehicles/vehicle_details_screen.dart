import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gomechanic_user/providers/vehicle_provider.dart';
import 'package:gomechanic_user/widgets/custom_text_field.dart';
import 'package:gomechanic_user/widgets/custom_button.dart';

class VehicleDetailsScreen extends StatefulWidget {
  final String vehicleId;

  const VehicleDetailsScreen({
    Key? key,
    required this.vehicleId,
  }) : super(key: key);

  @override
  State<VehicleDetailsScreen> createState() => _VehicleDetailsScreenState();
}

class _VehicleDetailsScreenState extends State<VehicleDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _licensePlateController = TextEditingController();
  bool _isLoading = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadVehicleDetails();
  }

  @override
  void dispose() {
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _licensePlateController.dispose();
    super.dispose();
  }

  Future<void> _loadVehicleDetails() async {
    setState(() => _isLoading = true);
    try {
      final vehicle =
          await context.read<VehicleProvider>().getVehicle(widget.vehicleId);
      if (vehicle != null && mounted) {
        _makeController.text = vehicle['make'] ?? '';
        _modelController.text = vehicle['model'] ?? '';
        _yearController.text = vehicle['year']?.toString() ?? '';
        _licensePlateController.text = vehicle['license_plate'] ?? '';
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateVehicle() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final success = await context.read<VehicleProvider>().updateVehicle(
            widget.vehicleId,
            make: _makeController.text.trim(),
            model: _modelController.text.trim(),
            year: int.parse(_yearController.text.trim()),
            licensePlate: _licensePlateController.text.trim(),
          );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vehicle updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() => _isEditing = false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update vehicle'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicle Details'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() => _isEditing = true);
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      child: Icon(
                        Icons.directions_car,
                        size: 50,
                      ),
                    ),
                    const SizedBox(height: 32),
                    CustomTextField(
                      controller: _makeController,
                      label: 'Make',
                      enabled: _isEditing,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the vehicle make';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _modelController,
                      label: 'Model',
                      enabled: _isEditing,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the vehicle model';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _yearController,
                      label: 'Year',
                      enabled: _isEditing,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the vehicle year';
                        }
                        final year = int.tryParse(value);
                        if (year == null ||
                            year < 1900 ||
                            year > DateTime.now().year) {
                          return 'Please enter a valid year';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _licensePlateController,
                      label: 'License Plate',
                      enabled: _isEditing,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the license plate number';
                        }
                        return null;
                      },
                    ),
                    if (_isEditing) ...[
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Expanded(
                            child: CustomButton(
                              onPressed: _isLoading
                                  ? null
                                  : () {
                                      setState(() => _isEditing = false);
                                      _loadVehicleDetails();
                                    },
                              isOutlined: true,
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CustomButton(
                              onPressed: _isLoading ? null : _updateVehicle,
                              child: _isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white)
                                  : const Text('Save Changes'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }
}
