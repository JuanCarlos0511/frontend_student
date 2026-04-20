/// Chat detail screen — message bubbles with real-time updates.
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:uni_social_student/core/theme/app_theme.dart';
import 'package:uni_social_student/features/chat/data/models/chat_models.dart';
import 'package:uni_social_student/features/home/presentation/screens/home_screen.dart';
import 'package:uni_social_student/features/chat/logic/chat_provider.dart';

class ChatDetailScreen extends StatefulWidget {
  final int roomId;
  final String otherName;
  final String? otherPhoto;
  final int? referencedProductId;
  final String? referencedProductTitle;
  final String? referencedProductDescription;
  final String? referencedProductImageUrl;
  final double? referencedProductPrice;

  const ChatDetailScreen({
    super.key,
    required this.roomId,
    required this.otherName,
    this.otherPhoto,
    this.referencedProductId,
    this.referencedProductTitle,
    this.referencedProductDescription,
    this.referencedProductImageUrl,
    this.referencedProductPrice,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final _messageCtrl = TextEditingController();
  final _scrollController = ScrollController();
  late ChatProvider _chatProvider;
  
  int? _activeReferencedProductId;
  String? _activeReferencedProductTitle;
  String? _activeReferencedProductDescription;
  String? _activeReferencedProductImageUrl;
  double? _activeReferencedProductPrice;

  @override
  void initState() {
    super.initState();
    _chatProvider = context.read<ChatProvider>();
    _activeReferencedProductId = widget.referencedProductId;
    _activeReferencedProductTitle = widget.referencedProductTitle;
    _activeReferencedProductDescription = widget.referencedProductDescription;
    _activeReferencedProductImageUrl = widget.referencedProductImageUrl;
    _activeReferencedProductPrice = widget.referencedProductPrice;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _chatProvider.loadMessages(widget.roomId);
    });
  }

  @override
  void dispose() {
    _chatProvider.leaveRoom();
    _messageCtrl.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _messageCtrl.text.trim();
    if (text.isEmpty) return;

    _messageCtrl.clear();
    final success =
        await context.read<ChatProvider>().sendMessage(
          widget.roomId,
          text,
          referencedProductId: _activeReferencedProductId,
        );

    if (success) {
      if (mounted) {
        setState(() {
          _activeReferencedProductId = null;
          _activeReferencedProductTitle = null;
          _activeReferencedProductDescription = null;
          _activeReferencedProductImageUrl = null;
          _activeReferencedProductPrice = null;
        });
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0.0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Row(
          children: [
            Stack(
              children: [
                ClipOval(
                  child: Container(
                    width: 40,
                    height: 40,
                    color: AppTheme.lightGrey,
                    child: widget.otherPhoto != null && widget.otherPhoto!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: widget.otherPhoto!,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) => const Icon(
                              Icons.person_rounded,
                              size: 20,
                              color: AppTheme.mediumGrey,
                            ),
                          )
                        : const Icon(
                            Icons.person_rounded,
                            size: 20,
                            color: AppTheme.mediumGrey,
                          ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E676),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.otherName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Text(
                    'En línea',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black54),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Messages ──
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, provider, _) {
                if (provider.isLoadingMessages) {
                  return const Center(
                    child:
                        CircularProgressIndicator(color: AppTheme.primaryRed),
                  );
                }

                if (provider.messages.isEmpty) {
                  return const Center(
                    child: Text('No hay mensajes aún.',
                        style: TextStyle(color: AppTheme.mediumGrey)),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true, // This places the newest messages at the bottom
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  itemCount: provider.messages.length,
                  itemBuilder: (context, index) {
                    final reverseIndex = provider.messages.length - 1 - index;
                    final msg = provider.messages[reverseIndex];
                    final isMe = msg.senderId == provider.currentStudentId;
                    return _MessageBubble(message: msg, isMe: isMe);
                  },
                );
              },
            ),
          ),
          // ── Input bar ──
          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 8,
              top: 8,
              bottom: MediaQuery.of(context).padding.bottom + 8,
            ),
            decoration: BoxDecoration(
              color: AppTheme.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(10),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_activeReferencedProductTitle != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 8, right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.lightGrey,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.mediumGrey.withAlpha(50)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_activeReferencedProductImageUrl != null && _activeReferencedProductImageUrl!.isNotEmpty) ...[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl: _activeReferencedProductImageUrl!,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                              errorWidget: (context, url, error) => Container(
                                width: 40,
                                height: 40,
                                color: AppTheme.mediumGrey,
                                child: const Icon(Icons.broken_image, size: 20, color: AppTheme.white),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                        ] else ...[
                          const Padding(
                            padding: EdgeInsets.only(top: 2),
                            child: Icon(Icons.shopping_bag_rounded, size: 24, color: AppTheme.primaryRed),
                          ),
                          const SizedBox(width: 12),
                        ],
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _activeReferencedProductTitle!,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.darkText,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (_activeReferencedProductDescription != null && _activeReferencedProductDescription!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text(
                                    _activeReferencedProductDescription!,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.mediumGrey,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 18, color: AppTheme.mediumGrey),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            setState(() {
                              _activeReferencedProductId = null;
                              _activeReferencedProductTitle = null;
                              _activeReferencedProductDescription = null;
                              _activeReferencedProductImageUrl = null;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF0F0F0),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.add, color: Colors.black54),
                        onPressed: () {},
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _messageCtrl,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          hintText: 'Escribe un mensaj...',
                          hintStyle: const TextStyle(color: Colors.black45, fontSize: 16),
                          filled: true,
                          fillColor: const Color(0xFFF5F6F8),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          suffixIcon: const Icon(Icons.sentiment_satisfied_alt, color: Colors.black54),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Consumer<ChatProvider>(
                      builder: (context, provider, _) {
                        return Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: provider.isSending ? AppTheme.mediumGrey : const Color(0xFFC00010),
                            shape: BoxShape.circle,
                          ),
                          child: provider.isSending
                              ? const Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.white),
                                  ),
                                )
                              : IconButton(
                                  padding: const EdgeInsets.only(left: 4),
                                  onPressed: _sendMessage,
                                  icon: const Icon(Icons.send_rounded,
                                      color: Colors.white, size: 22),
                                ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessageModel message;
  final bool isMe;

  const _MessageBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFFC00010) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isMe ? 20 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isMe ? 20 : 10),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.referencedProductTitle != null) ...[
              GestureDetector(
                onTap: () {
                  if (message.referencedProductId != null) {
                    Navigator.popUntil(context, (route) => route.isFirst);
                    HomeScreen.globalKey.currentState?.setTab(1, focusProductId: message.referencedProductId);
                  }
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  width: MediaQuery.of(context).size.width * 0.75,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                clipBehavior: Clip.hardEdge,
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        width: 90,
                        child: message.referencedProductImageUrl != null && message.referencedProductImageUrl!.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: message.referencedProductImageUrl!,
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) => Container(
                                  color: const Color(0xFFF0F0F0),
                                  child: const Icon(Icons.shopping_bag_rounded, size: 24, color: Colors.grey),
                                ),
                              )
                            : Container(
                                color: const Color(0xFFF0F0F0),
                                child: const Icon(Icons.storefront_rounded, size: 24, color: Colors.grey),
                              ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'MARKETPLACE',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFFC00010),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                message.referencedProductTitle!,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                  height: 1.2,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              if (message.referencedProductDescription != null && message.referencedProductDescription!.isNotEmpty)
                                Text(
                                  message.referencedProductDescription!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              if (message.referencedProductPrice != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  '\$${message.referencedProductPrice!.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFC00010),
                                  ),
                                ),
                              ]
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ),
            ],
            Text(
              message.message,
              style: TextStyle(
                fontSize: 15,
                color: isMe ? Colors.white : Colors.black87,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '${message.createdAt.hour.toString().padLeft(2, '0')}:${message.createdAt.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    fontSize: 11,
                    color: isMe ? Colors.white70 : Colors.black45,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.done_all, size: 14, color: Colors.white),
                ]
              ],
            ),
          ],
        ),
      ),
    );
  }
}
