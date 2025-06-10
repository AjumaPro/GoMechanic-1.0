import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gomechanic_user/providers/vehicle_provider.dart';
import 'package:gomechanic_user/widgets/custom_text_field.dart';
import 'package:gomechanic_user/widgets/custom_button.dart';

class EditVehicleScreen extends StatefulWidget {
  final String vehicleId;

  const EditVehicleScreen({
    Key? key,
    required this.vehicleId,
  }) : super(key: key);

  @override
  State<EditVehicleScreen> createState() => _EditVehicleScreenState();
}

class _EditVehicleScreenState extends State<EditVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _licensePlateController = TextEditingController();
  final _colorController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadVehicleData();
    });
  }

  @override
  void dispose() {
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _licensePlateController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  Future<void> _loadVehicleData() async {
    setState(() => _isLoading = true);
    try {
      final vehicle =
          await context.read<VehicleProvider>().getVehicle(widget.vehicleId);
      if (vehicle != null && mounted) {
        _makeController.text = vehicle['make'] ?? '';
        _modelController.text = vehicle['model'] ?? '';
        _yearController.text = vehicle['year']?.toString() ?? '';
        _licensePlateController.text = vehicle['license_plate'] ?? '';
        _colorController.text = vehicle['color'] ?? '';
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
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update vehicle. Please try again.'),
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
        title: const Text('Edit Vehicle'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomTextField(
                  controller: _makeController,
                  label: 'Make',
                  textCapitalization: TextCapitalization.words,
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
                  textCapitalization: TextCapitalization.words,
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
                  textCapitalization: TextCapitalization.characters,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the license plate number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _colorController,
                  label: 'Color',
                  textCapitalization: TextCapitalization.words,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the vehicle color';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                CustomButton(
                  onPressed: _isLoading ? null : _updateVehicle,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Update Vehicle'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
