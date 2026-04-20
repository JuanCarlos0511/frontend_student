/// Chat list screen — shows all conversations.
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:uni_social_student/core/theme/app_theme.dart';
import 'package:uni_social_student/features/chat/data/models/chat_models.dart';
import 'package:uni_social_student/features/chat/logic/chat_provider.dart';
import 'package:uni_social_student/features/chat/presentation/screens/chat_detail_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ChatProvider>();
      provider.initSocket();
      provider.loadRooms();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mensajes')),
      body: Consumer<ChatProvider>(
        builder: (context, provider, _) {
          if (provider.isLoadingRooms && provider.rooms.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryRed),
            );
          }

          if (provider.rooms.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.chat_bubble_outline_rounded,
                      size: 64, color: AppTheme.mediumGrey),
                  SizedBox(height: 12),
                  Text('No tienes conversaciones',
                      style: TextStyle(
                          fontSize: 16,
                          color: AppTheme.mediumGrey,
                          fontWeight: FontWeight.w600)),
                  SizedBox(height: 4),
                  Text(
                      'Contacta a un vendedor desde el Marketplace.',
                      style: TextStyle(color: AppTheme.mediumGrey)),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: AppTheme.primaryRed,
            onRefresh: () => provider.loadRooms(),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: provider.rooms.length,
              separatorBuilder: (_, __) =>
                  Divider(height: 1, color: Colors.grey.shade200, indent: 80),
              itemBuilder: (context, index) {
                return _ChatRoomTile(room: provider.rooms[index]);
              },
            ),
          );
        },
      ),
    );
  }
}

class _ChatRoomTile extends StatelessWidget {
  final ChatRoomModel room;

  const _ChatRoomTile({required this.room});

  String _timeAgo(DateTime? dt) {
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'ahora';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: ClipOval(
        child: Container(
          width: 52,
          height: 52,
          color: AppTheme.lightGrey,
          child: room.otherPhoto != null && room.otherPhoto!.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: room.otherPhoto!,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => const Icon(
                    Icons.person_rounded,
                    color: AppTheme.mediumGrey,
                  ),
                )
              : const Icon(
                  Icons.person_rounded,
                  color: AppTheme.mediumGrey,
                ),
        ),
      ),
      title: Text(
        room.otherName ?? 'Usuario',
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 15,
          color: AppTheme.darkText,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (room.productTitle != null)
            Text(
              room.productTitle!,
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.primaryRed,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          Text(
            room.lastMessage ?? 'Sin mensajes',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, color: AppTheme.mediumGrey),
          ),
        ],
      ),
      trailing: Text(
        _timeAgo(room.lastMessageAt ?? room.createdAt),
        style: const TextStyle(fontSize: 11, color: AppTheme.mediumGrey),
      ),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ChatDetailScreen(
              roomId: room.id,
              otherName: room.otherName ?? 'Usuario',
              otherPhoto: room.otherPhoto,
            ),
          ),
        );
      },
    );
  }
}
