import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gomechanic_user/config/theme.dart';
import 'package:gomechanic_user/screens/onboarding/onboarding_screen.dart';
import 'package:gomechanic_user/providers/auth_provider.dart';
import 'package:gomechanic_user/providers/booking_provider.dart';
import 'package:gomechanic_user/providers/vehicle_provider.dart';
import 'package:gomechanic_user/providers/chat_provider.dart';
import 'package:gomechanic_user/providers/payment_provider.dart';
import 'package:gomechanic_user/providers/sample_data_provider.dart';
import 'package:gomechanic_user/screens/home/home_screen.dart';
import 'package:gomechanic_user/screens/payments/payment_history_screen.dart';
import 'package:gomechanic_user/screens/payments/payment_details_screen.dart';
import 'package:gomechanic_user/screens/services/service_selection_screen.dart';
import 'package:gomechanic_user/screens/vehicles/vehicle_selection_screen.dart';
import 'package:gomechanic_user/screens/vehicles/add_vehicle_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => VehicleProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
        ChangeNotifierProvider(create: (_) => SampleDataProvider()),
      ],
      child: MaterialApp(
        title: 'GoMechanic',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: const OnboardingScreen(),
      ),
    );
  }
}
