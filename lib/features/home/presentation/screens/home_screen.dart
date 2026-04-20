import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uni_social_student/core/theme/app_theme.dart';
import 'package:uni_social_student/features/auth_login/logic/login_provider.dart';
import 'package:uni_social_student/features/auth_login/presentation/screens/login_screen.dart';
import 'package:uni_social_student/features/feed/presentation/screens/feed_screen.dart';
import 'package:uni_social_student/features/market/presentation/screens/market_screen.dart';
import 'package:uni_social_student/features/profile/presentation/screens/profile_screen.dart';
import 'package:uni_social_student/features/bus/presentation/screens/bus_screen.dart';
import 'package:uni_social_student/features/communities/presentation/screens/community_discover_screen.dart';
import 'package:uni_social_student/features/chat/presentation/screens/chat_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  static const _tabLabels = [
    'Feed',
    'Market',
    'Bus',
    'Comunidades',
    'Perfil',
  ];

  static const _tabIcons = [
    Icons.dynamic_feed_rounded,
    Icons.storefront_rounded,
    Icons.directions_bus_rounded,
    Icons.groups_rounded,
    Icons.person_rounded,
  ];

  static const _tabPlaceholderIcons = [
    Icons.dynamic_feed_outlined,
    Icons.storefront_outlined,
    Icons.directions_bus_outlined,
    Icons.groups_outlined,
    Icons.person_outline_rounded,
  ];

  static const _tabPlaceholderTexts = [
    '',
    '',
    '',
    '',
    '',
  ];

  Future<void> _logout() async {
    await context.read<LoginProvider>().logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return const FeedScreen();
      case 1:
        return const MarketScreen();
      case 2:
        return const BusScreen();
      case 3:
        return const CommunityDiscoverScreen();
      case 4:
        return const ProfileScreen();
      default:
        // Placeholder para las otras tabs
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_tabPlaceholderIcons[_currentIndex],
                  size: 72, color: AppTheme.primaryRed.withAlpha(180)),
              const SizedBox(height: 20),
              Text(
                _tabPlaceholderTexts[_currentIndex],
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.darkText,
                  height: 1.5,
                ),
              ),
            ],
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: [2, 3].contains(_currentIndex)
          ? null
          : AppBar(
              title: Text(_tabLabels[_currentIndex]),
              actions: [
                IconButton(
                  icon: const Icon(Icons.chat_bubble_outline_rounded),
                  tooltip: 'Mensajes',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ChatListScreen()),
                    );
                  },
                ),
                if (_currentIndex != 4) // Don't show logout on profile tab (it has its own)
                  IconButton(
                    icon: const Icon(Icons.logout_rounded),
                    tooltip: 'Cerrar sesión',
                    onPressed: _logout,
                  ),
              ],
            ),
      body: _buildBody(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        indicatorColor: AppTheme.primaryRed.withAlpha(30),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide, // Ocultar textos
        destinations: List.generate(
          _tabLabels.length,
          (i) => NavigationDestination(
            icon: Icon(_tabIcons[i], color: AppTheme.mediumGrey),
            selectedIcon: Icon(_tabIcons[i], color: AppTheme.primaryRed),
            label: _tabLabels[i],
          ),
        ),
      ),
    );
  }
}
