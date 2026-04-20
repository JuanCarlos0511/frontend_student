import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uni_social_student/core/theme/app_theme.dart';
import 'package:uni_social_student/features/auth_login/logic/login_provider.dart';
import 'package:uni_social_student/features/auth_login/presentation/screens/login_screen.dart';
import 'package:uni_social_student/features/auth_registration/logic/registration_provider.dart';
import 'package:uni_social_student/features/feed/logic/feed_provider.dart';
import 'package:uni_social_student/features/home/presentation/screens/home_screen.dart';
import 'package:uni_social_student/features/market/logic/market_provider.dart';
import 'package:uni_social_student/features/profile/logic/profile_provider.dart';
import 'package:uni_social_student/features/bus/logic/bus_provider.dart';
import 'package:uni_social_student/features/chat/logic/chat_provider.dart';
import 'package:uni_social_student/features/moderator/logic/moderator_provider.dart';
import 'package:uni_social_student/features/communities/logic/community_provider.dart';

void main() {
  runApp(const UniSocialApp());
}

/// Aplicación principal de la Red Social Universitaria para estudiantes.
class UniSocialApp extends StatelessWidget {
  const UniSocialApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginProvider()),
        ChangeNotifierProvider(create: (_) => RegistrationProvider()),
        ChangeNotifierProvider(create: (_) => FeedProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => MarketProvider()),
        ChangeNotifierProvider(create: (_) => BusProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => ModeratorProvider()),
        ChangeNotifierProvider(create: (_) => CommunityProvider()),
      ],
      child: MaterialApp(
        title: 'Red Social Universitaria',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const _AuthGate(),
      ),
    );
  }
}

/// Widget that checks for saved auth token and routes accordingly.
class _AuthGate extends StatefulWidget {
  const _AuthGate();

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  late Future<bool> _autoLoginFuture;

  @override
  void initState() {
    super.initState();
    _autoLoginFuture = context.read<LoginProvider>().tryAutoLogin();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _autoLoginFuture,
      builder: (context, snapshot) {
        // Mostrar splash mientras se verifica el token
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.school_rounded,
                      size: 80, color: AppTheme.primaryRed),
                  SizedBox(height: 16),
                  CircularProgressIndicator(color: AppTheme.primaryRed),
                ],
              ),
            ),
          );
        }

        // Si tiene token válido → Home, si no → Login
        if (snapshot.data == true) {
          return const HomeScreen();
        }
        return const LoginScreen();
      },
    );
  }
}
