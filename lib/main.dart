// lib/main.dart - Đã sửa lỗi
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/movie_detail_screen.dart';
import 'screens/booking_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/user_detail_screen.dart';
import 'screens/my_tickets_screen.dart';
import 'screens/admin/admin_dashboard.dart';
import 'providers/auth_provider.dart';
import 'providers/movie_provider.dart';
import 'providers/booking_provider.dart';
import 'providers/ticket_provider.dart';
import 'utils/app_theme.dart';
import 'screens/settings_screen.dart';
import 'screens/help_screen.dart';
import 'providers/theme_provider.dart';
// import 'screens/my_reviews_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MovieProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => TicketProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),

      ],
      child: MaterialApp(
        title: 'Cinema Ticket App',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: SplashScreen(),
        routes: {
          '/login': (context) => LoginScreen(),
          '/home': (context) => HomeScreen(),
          '/profile': (context) => ProfileScreen(),
          '/user-detail': (context) => UserDetailScreen(),
          '/tickets': (context) => MyTicketsScreen(),
          '/admin_dashboard': (context) => AdminDashboard(),
          '/settings': (context) => SettingsScreen(),
          '/help': (context) => HelpScreen(),
          // '/my-reviews': (context) => MyReviewsScreen(),
        },
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/movie-detail':
              final movieId = settings.arguments as String;
              return MaterialPageRoute(
                builder: (context) => MovieDetailScreen(movieId: movieId),
              );
            case '/booking':
            //Chỉ cần movieId, bỏ showtimeId
              final movieId = settings.arguments as String;
              return MaterialPageRoute(
                builder: (context) => BookingScreen(
                  movieId: movieId,
                ),
              );
            default:
              return MaterialPageRoute(
                builder: (context) => HomeScreen(),
              );
          }
        },
      ),
    );
  }
}