import 'package:flutter/material.dart';
import 'package:gomechanic_user/screens/bookings/bookings_screen.dart';

class TowingServicesScreen extends StatelessWidget {
  const TowingServicesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> towingOptions = [
      {
        'title': 'Standard Towing',
        'description': 'Basic towing service for small vehicles.',
        'price': 'GHS 100',
        'icon': Icons.local_shipping,
      },
      {
        'title': 'Premium Towing',
        'description': 'Advanced towing service for larger vehicles.',
        'price': 'GHS 200',
        'icon': Icons.directions_car,
      },
      {
        'title': 'Emergency Towing',
        'description': '24/7 emergency towing service.',
        'price': 'GHS 300',
        'icon': Icons.emergency,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Towing Services'),
      ),
      body: ListView.builder(
        itemCount: towingOptions.length,
        itemBuilder: (context, index) {
          final option = towingOptions[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              leading: Icon(option['icon']),
              title: Text(option['title']),
              subtitle: Text(option['description']),
              trailing: Text(
                option['price'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              onTap: () {
                _showBookingDialog(context, option);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showBookingDialog(context, towingOptions[0]);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showBookingDialog(BuildContext context, Map<String, dynamic> option) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();
    final TextEditingController addressController = TextEditingController();
    final TextEditingController vehicleModelController =
        TextEditingController();
    final TextEditingController vehicleNumberController =
        TextEditingController();
    final TextEditingController notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Book ${option['title']}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Price: ${option['price']}'),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
              ),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(labelText: 'Address'),
              ),
              TextField(
                controller: vehicleModelController,
                decoration: const InputDecoration(labelText: 'Vehicle Model'),
              ),
              TextField(
                controller: vehicleNumberController,
                decoration: const InputDecoration(labelText: 'Vehicle Number'),
              ),
              TextField(
                controller: notesController,
                decoration:
                    const InputDecoration(labelText: 'Additional Notes'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  final bookingData = {
                    'service': option['title'],
                    'price': option['price'],
                    'name': nameController.text,
                    'phone': phoneController.text,
                    'address': addressController.text,
                    'vehicleModel': vehicleModelController.text,
                    'vehicleNumber': vehicleNumberController.text,
                    'notes': notesController.text,
                  };
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          BookingsScreen(bookingData: bookingData),
                    ),
                  );
                },
                child: const Text('Proceed to Booking'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
