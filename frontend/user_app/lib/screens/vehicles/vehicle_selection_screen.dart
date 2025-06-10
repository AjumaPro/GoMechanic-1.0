import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gomechanic_user/providers/sample_data_provider.dart';
import 'package:gomechanic_user/screens/bookings/date_time_selection_screen.dart';
import 'package:gomechanic_user/widgets/custom_button.dart';

class VehicleSelectionScreen extends StatelessWidget {
  final String serviceId;

  const VehicleSelectionScreen({
    Key? key,
    required this.serviceId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Vehicle'),
      ),
      body: Consumer<SampleDataProvider>(
        builder: (context, sampleData, child) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sampleData.vehicles.length,
            itemBuilder: (context, index) {
              final vehicle = sampleData.vehicles[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => DateTimeSelectionScreen(
                          serviceId: serviceId,
                          vehicleId: vehicle['id'],
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${vehicle['brand']} ${vehicle['model']}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${vehicle['year']} • ${vehicle['color']}',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    vehicle['license_plate'],
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Icon(
                              Icons.directions_car,
                              size: 48,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        CustomButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => DateTimeSelectionScreen(
                                  serviceId: serviceId,
                                  vehicleId: vehicle['id'],
                                ),
                              ),
                            );
                          },
                          child: const Text('Select Vehicle'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to add vehicle screen
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
