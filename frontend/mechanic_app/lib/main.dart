import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:gomechanic_mechanic/config/theme.dart';
import 'package:gomechanic_mechanic/providers/auth_provider.dart';
import 'package:gomechanic_mechanic/providers/job_provider.dart';
import 'package:gomechanic_mechanic/providers/notification_provider.dart';
import 'package:gomechanic_mechanic/providers/earnings_provider.dart';
import 'package:gomechanic_mechanic/screens/auth/login_screen.dart';
import 'package:gomechanic_mechanic/screens/home/home_screen.dart';
import 'package:gomechanic_mechanic/screens/jobs/active_jobs_screen.dart';
import 'package:gomechanic_mechanic/screens/jobs/completed_jobs_screen.dart';
import 'package:gomechanic_mechanic/screens/profile/profile_screen.dart';
import 'package:gomechanic_mechanic/screens/earnings/earnings_screen.dart';
import 'package:gomechanic_mechanic/services/api_service.dart';
import 'package:gomechanic_mechanic/services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final storageService = StorageService();
  final apiService = ApiServiceImpl(http.Client());

  runApp(MyApp(
    storageService: storageService,
    apiService: apiService,
  ));
}

class MyApp extends StatelessWidget {
  final StorageService storageService;
  final ApiService apiService;

  const MyApp({
    Key? key,
    required this.storageService,
    required this.apiService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(apiService, storageService),
        ),
        ChangeNotifierProvider(
          create: (_) => JobProvider(apiService),
        ),
        ChangeNotifierProvider(
          create: (_) => NotificationProvider(apiService),
        ),
        ChangeNotifierProvider(
          create: (_) => EarningsProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'GoMechanic Mechanic',
        theme: AppTheme.lightTheme,
        home: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            return FutureBuilder<bool>(
              future: authProvider.checkAuth(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                return snapshot.data == true
                    ? const MainScreen()
                    : const LoginScreen();
              },
            );
          },
        ),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const ActiveJobsScreen(),
    const CompletedJobsScreen(),
    const EarningsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work),
            label: 'Active',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle),
            label: 'Completed',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money),
            label: 'Earnings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
