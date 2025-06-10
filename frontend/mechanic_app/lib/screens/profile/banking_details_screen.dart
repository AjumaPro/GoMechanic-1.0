import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gomechanic_mechanic/providers/auth_provider.dart';

class BankingDetailsScreen extends StatefulWidget {
  const BankingDetailsScreen({Key? key}) : super(key: key);

  @override
  State<BankingDetailsScreen> createState() => _BankingDetailsScreenState();
}

class _BankingDetailsScreenState extends State<BankingDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _accountNumberController = TextEditingController();
  final _accountNameController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _branchCodeController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final mechanic = context.read<AuthProvider>().mechanic;
    _accountNumberController.text = mechanic?.bankAccountNumber ?? '';
  }

  @override
  void dispose() {
    _accountNumberController.dispose();
    _accountNameController.dispose();
    _bankNameController.dispose();
    _branchCodeController.dispose();
    super.dispose();
  }

  Future<void> _updateBankingDetails() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await context.read<AuthProvider>().updateBankingDetails({
        'account_number': _accountNumberController.text,
        'account_name': _accountNameController.text,
        'bank_name': _bankNameController.text,
        'branch_code': _branchCodeController.text,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Banking details updated successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update banking details: $e')),
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
        title: const Text('Banking Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoCard(),
              const SizedBox(height: 24),
              _buildAccountNumberField(),
              const SizedBox(height: 16),
              _buildAccountNameField(),
              const SizedBox(height: 16),
              _buildBankNameField(),
              const SizedBox(height: 16),
              _buildBranchCodeField(),
              const SizedBox(height: 24),
              _buildUpdateButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Important Information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Please ensure that the banking details you provide are accurate. '
              'These details will be used for processing your payments.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your earnings will be automatically transferred to this account '
              'after each completed job.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountNumberField() {
    return TextFormField(
      controller: _accountNumberController,
      decoration: const InputDecoration(
        labelText: 'Account Number',
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your account number';
        }
        if (value.length < 10) {
          return 'Account number must be at least 10 digits';
        }
        return null;
      },
    );
  }

  Widget _buildAccountNameField() {
    return TextFormField(
      controller: _accountNameController,
      decoration: const InputDecoration(
        labelText: 'Account Holder Name',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter the account holder name';
        }
        return null;
      },
    );
  }

  Widget _buildBankNameField() {
    return TextFormField(
      controller: _bankNameController,
      decoration: const InputDecoration(
        labelText: 'Bank Name',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter the bank name';
        }
        return null;
      },
    );
  }

  Widget _buildBranchCodeField() {
    return TextFormField(
      controller: _branchCodeController,
      decoration: const InputDecoration(
        labelText: 'Branch Code',
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter the branch code';
        }
        return null;
      },
    );
  }

  Widget _buildUpdateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _updateBankingDetails,
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
            : const Text('Update Banking Details'),
      ),
    );
  }
}
