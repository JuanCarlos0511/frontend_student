import 'package:provider/provider.dart';
import 'package:uni_social_student/features/auth_login/logic/login_provider.dart';
import 'package:uni_social_student/features/reports/presentation/screens/reports_feed_screen.dart';
import 'package:flutter/material.dart';
import 'package:uni_social_student/core/theme/app_theme.dart';
import 'package:uni_social_student/features/feed/presentation/screens/feed_screen.dart';
import 'package:uni_social_student/features/market/presentation/screens/market_screen.dart';
import 'package:uni_social_student/features/profile/presentation/screens/profile_screen.dart';
import 'package:uni_social_student/features/bus/presentation/screens/bus_screen.dart';
import 'package:uni_social_student/features/communities/presentation/screens/community_discover_screen.dart';
import 'package:uni_social_student/features/chat/presentation/screens/chat_list_screen.dart';

class HomeScreen extends StatefulWidget {
  static final GlobalKey<HomeScreenState> globalKey = GlobalKey<HomeScreenState>();
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  int? _focusProductId;

  void setTab(int index, {int? focusProductId}) {
    setState(() {
      _currentIndex = index;
      _focusProductId = focusProductId;
    });
  }

  List<String> _getTabLabels(bool isMod) {
    final list = ['Feed', 'Market', 'Bus', 'Comunidades', 'Chats', 'Perfil'];
    if (isMod) list.add('Reportes');
    return list;
  }

  List<IconData> _getTabIcons(bool isMod) {
    final list = [
      Icons.dynamic_feed_rounded,
      Icons.storefront_rounded,
      Icons.directions_bus_rounded,
      Icons.groups_rounded,
      Icons.chat_bubble_rounded,
      Icons.person_rounded,
    ];
    if (isMod) list.add(Icons.report_rounded);
    return list;
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return const FeedScreen();
      case 1:
        return MarketScreen(prioritizeProductId: _focusProductId);
      case 2:
        return const BusScreen();
      case 3:
        return const CommunityDiscoverScreen();
      case 4:
        return const ChatListScreen();
      case 5:
        return const ProfileScreen();
      case 6:
        return const ReportsFeedScreen();
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMod = context.watch<LoginProvider>().isModerator;
    final labels = _getTabLabels(isMod);
    final icons = _getTabIcons(isMod);

    // Safety check for index out of bounds when role changes
    if (_currentIndex >= labels.length) {
      _currentIndex = 0;
    }

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
          labels.length,
          (i) => NavigationDestination(
            icon: Icon(icons[i], color: AppTheme.mediumGrey),
            selectedIcon: Icon(icons[i], color: AppTheme.primaryRed),
            label: labels[i],
          ),
        ),
      ),
    );
  }
}
