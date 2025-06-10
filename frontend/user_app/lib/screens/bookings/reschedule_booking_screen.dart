import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gomechanic_user/providers/booking_provider.dart';
import 'package:gomechanic_user/widgets/custom_button.dart';
import 'package:intl/intl.dart';

class RescheduleBookingScreen extends StatefulWidget {
  final String bookingId;
  final DateTime currentScheduledAt;

  const RescheduleBookingScreen({
    Key? key,
    required this.bookingId,
    required this.currentScheduledAt,
  }) : super(key: key);

  @override
  State<RescheduleBookingScreen> createState() =>
      _RescheduleBookingScreenState();
}

class _RescheduleBookingScreenState extends State<RescheduleBookingScreen> {
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  bool _isLoading = false;

  // Business hours: 9 AM to 6 PM
  final TimeOfDay _businessStart = const TimeOfDay(hour: 9, minute: 0);
  final TimeOfDay _businessEnd = const TimeOfDay(hour: 18, minute: 0);

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.currentScheduledAt;
    _selectedTime = TimeOfDay(
      hour: widget.currentScheduledAt.hour,
      minute: widget.currentScheduledAt.minute,
    );
  }

  List<TimeOfDay> get _availableTimeSlots {
    final slots = <TimeOfDay>[];
    var currentTime = _businessStart;

    while (currentTime.hour < _businessEnd.hour ||
        (currentTime.hour == _businessEnd.hour &&
            currentTime.minute <= _businessEnd.minute)) {
      slots.add(currentTime);
      currentTime = TimeOfDay(
        hour: currentTime.hour + (currentTime.minute + 30) ~/ 60,
        minute: (currentTime.minute + 30) % 60,
      );
    }

    return slots;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      selectableDayPredicate: (DateTime date) {
        // Disable weekends
        return date.weekday != DateTime.saturday &&
            date.weekday != DateTime.sunday;
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        // Reset time when date changes
        _selectedTime = _businessStart;
      });
    }
  }

  void _selectTime(TimeOfDay time) {
    setState(() {
      _selectedTime = time;
    });
  }

  Future<void> _rescheduleBooking() async {
    setState(() => _isLoading = true);

    try {
      final scheduledAt = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final success = await context
          .read<BookingProvider>()
          .rescheduleBooking(widget.bookingId, scheduledAt);

      if (!mounted) return;

      if (success) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking rescheduled successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to reschedule booking. Please try again.'),
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
        title: const Text('Reschedule Booking'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Current Schedule',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      DateFormat('EEEE, MMMM d, y')
                          .format(widget.currentScheduledAt),
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      DateFormat('h:mm a').format(widget.currentScheduledAt),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Select New Date',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                title: Text(
                  DateFormat('EEEE, MMMM d, y').format(_selectedDate),
                  style: const TextStyle(fontSize: 18),
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Select New Time',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'Available Time Slots',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _availableTimeSlots.map((time) {
                        final isSelected = time.hour == _selectedTime.hour &&
                            time.minute == _selectedTime.minute;
                        return ChoiceChip(
                          label: Text(time.format(context)),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              _selectTime(time);
                            }
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            CustomButton(
              onPressed: _isLoading ? null : _rescheduleBooking,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Reschedule Booking'),
            ),
          ],
        ),
      ),
    );
  }
}
