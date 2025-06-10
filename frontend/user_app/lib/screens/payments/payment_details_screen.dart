import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gomechanic_user/providers/payment_provider.dart';
import 'package:intl/intl.dart';

class PaymentDetailsScreen extends StatefulWidget {
  final String paymentId;

  const PaymentDetailsScreen({
    Key? key,
    required this.paymentId,
  }) : super(key: key);

  @override
  State<PaymentDetailsScreen> createState() => _PaymentDetailsScreenState();
}

class _PaymentDetailsScreenState extends State<PaymentDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPaymentDetails();
    });
  }

  Future<void> _loadPaymentDetails() async {
    await context.read<PaymentProvider>().getPaymentDetails(widget.paymentId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Details'),
      ),
      body: Consumer<PaymentProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return FutureBuilder<Map<String, dynamic>?>(
            future: provider.getPaymentDetails(widget.paymentId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              }

              final payment = snapshot.data;
              if (payment == null) {
                return const Center(
                  child: Text('Payment details not found'),
                );
              }

              final date = DateTime.parse(payment['created_at']);
              final currency = payment['currency'] ?? 'INR';
              final amount = payment['amount'] as double;
              final status = payment['status'] as String;
              final paymentMethod = payment['payment_method'] as String;

              final currencyFormat = NumberFormat.currency(
                symbol: currency == 'USD' ? '\$' : '₹',
                decimalDigits: 2,
              );

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Payment Information',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 16),
                            _buildInfoRow(
                              context,
                              'Payment ID',
                              '#${payment['id']}',
                            ),
                            const Divider(),
                            _buildInfoRow(
                              context,
                              'Amount',
                              currencyFormat.format(amount),
                            ),
                            const Divider(),
                            _buildInfoRow(
                              context,
                              'Status',
                              status.toUpperCase(),
                              valueColor: status == 'completed'
                                  ? Colors.green
                                  : status == 'failed'
                                      ? Colors.red
                                      : Colors.orange,
                            ),
                            const Divider(),
                            _buildInfoRow(
                              context,
                              'Payment Method',
                              paymentMethod.toUpperCase(),
                            ),
                            const Divider(),
                            _buildInfoRow(
                              context,
                              'Date',
                              DateFormat('MMM dd, yyyy - hh:mm a').format(date),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (payment['booking'] != null) ...[
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Booking Information',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 16),
                              _buildInfoRow(
                                context,
                                'Booking ID',
                                '#${payment['booking']['id']}',
                              ),
                              const Divider(),
                              _buildInfoRow(
                                context,
                                'Service',
                                payment['booking']['service']['name'],
                              ),
                              const Divider(),
                              _buildInfoRow(
                                context,
                                'Vehicle',
                                '${payment['booking']['vehicle']['make']} ${payment['booking']['vehicle']['model']}',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: valueColor,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}
