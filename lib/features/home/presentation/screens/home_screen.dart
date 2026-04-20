import 'package:flutter/material.dart';
import 'package:uni_social_student/core/theme/app_theme.dart';
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
    'Chats',
    'Perfil',
  ];

  static const _tabIcons = [
    Icons.dynamic_feed_rounded,
    Icons.storefront_rounded,
    Icons.directions_bus_rounded,
    Icons.groups_rounded,
    Icons.chat_bubble_rounded,
    Icons.person_rounded,
  ];

  static const _tabPlaceholderIcons = [
    Icons.dynamic_feed_outlined,
    Icons.storefront_outlined,
    Icons.directions_bus_outlined,
    Icons.groups_outlined,
    Icons.chat_bubble_outline_rounded,
    Icons.person_outline_rounded,
  ];

  static const _tabPlaceholderTexts = [
    '',
    '',
    '',
    '',
    '',
    '',
  ];

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
        return const ChatListScreen();
      case 5:
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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: AppBar(
          backgroundColor: AppTheme.white,
          elevation: 0,
        ),
      ),
      body: _buildBody(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        indicatorColor: AppTheme.primaryRed.withAlpha(30),
        labelBehavior:
            NavigationDestinationLabelBehavior.alwaysHide, // Ocultar textos
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
