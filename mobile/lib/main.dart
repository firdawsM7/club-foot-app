import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/users/users_screen.dart';
import 'screens/equipes/equipes_screen.dart';
import 'screens/joueurs/joueurs_screen.dart';
import 'screens/entrainements/entrainements_screen.dart';
import 'screens/matchs/matchs_screen.dart';
import 'screens/cotisations/cotisations_screen.dart';
import 'screens/calendar/calendar_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/admin/dashboard_screen.dart';
import 'providers/dashboard_provider.dart';
import 'providers/document_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/player_provider.dart';
import 'providers/alert_provider.dart';
import 'screens/admin/documents/documents_list_screen.dart';
import 'screens/messages_screen.dart';
import 'providers/theme_provider.dart';
import 'providers/training_provider.dart';
import 'providers/match_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => DocumentProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => PlayerProvider()),
        ChangeNotifierProvider(create: (_) => AlertProvider()),
        ChangeNotifierProvider(create: (_) => TrainingProvider()),
        ChangeNotifierProvider(create: (_) => MatchProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'MAS de Fès',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            initialRoute: '/login',
            routes: {
              '/login': (context) => const LoginScreen(),
              '/register': (context) => const RegisterScreen(),
              '/home': (context) => const HomeScreen(),
              '/users': (context) => const UsersScreen(),
              '/equipes': (context) => const EquipesScreen(),
              '/joueurs': (context) => const JoueursScreen(),
              '/entrainements': (context) => const EntrainementsScreen(),
              '/matchs': (context) => const MatchsScreen(),
              '/cotisations': (context) => const CotisationsScreen(),
              '/calendar': (context) => const CalendarScreen(),
              '/profile': (context) => const ProfileScreen(),
              '/admin/dashboard': (context) => const AdminDashboardScreen(),
              '/admin/documents': (context) => const DocumentsListScreen(),
              '/messages': (context) => const MessagesScreen(),
            },
          );
        },
      ),
    );
  }
}
