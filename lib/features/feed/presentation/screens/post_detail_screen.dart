import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:uni_social_student/core/theme/app_theme.dart';
import 'package:uni_social_student/features/auth_login/logic/login_provider.dart';
import 'package:uni_social_student/features/feed/data/models/post_model.dart';
import 'package:uni_social_student/features/feed/logic/feed_provider.dart';

class PostDetailScreen extends StatefulWidget {
  final PostModel post;

  const PostDetailScreen({super.key, required this.post});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final _replyController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<FeedProvider>().loadReplies(widget.post.id);
    });
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  Future<void> _submitReply() async {
    final content = _replyController.text.trim();
    if (content.isEmpty) return;

    setState(() => _isSubmitting = true);

    final success = await context.read<FeedProvider>().createReply(
          postId: widget.post.id,
          content: content,
        );

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        _replyController.clear();
        FocusScope.of(context).unfocus(); // Ocultar teclado
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.read<FeedProvider>().message),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  String _timeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inDays > 0) return 'hace ${diff.inDays}d';
    if (diff.inHours > 0) return 'hace ${diff.inHours}h';
    if (diff.inMinutes > 0) return 'hace ${diff.inMinutes}m';
    return 'ahora';
  }

  Future<void> _confirmDeleteReply(int replyId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar respuesta'),
        content: const Text('¿Estás seguro de que deseas eliminar esta respuesta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: AppTheme.errorRed)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await context.read<FeedProvider>().deleteReply(widget.post.id, replyId);
      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.read<FeedProvider>().message),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  void _showEditReplyDialog(int replyId, String currentContent) {
    final editController = TextEditingController(text: currentContent);
    bool isSubmittingDialog = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Editar respuesta',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.darkText,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: editController,
                    maxLines: 4,
                    minLines: 2,
                    decoration: const InputDecoration(
                      hintText: 'Escribe tu respuesta...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: isSubmittingDialog
                        ? null
                        : () async {
                            final content = editController.text.trim();
                            if (content.isEmpty) return;
                            setModalState(() => isSubmittingDialog = true);

                            final success = await context.read<FeedProvider>().updateReply(
                                  postId: widget.post.id,
                                  replyId: replyId,
                                  content: content,
                                );

                            setModalState(() => isSubmittingDialog = false);
                            if (ctx.mounted) {
                              if (success) {
                                Navigator.pop(ctx);
                              } else {
                                ScaffoldMessenger.of(ctx).showSnackBar(
                                  SnackBar(
                                    content: Text(context.read<FeedProvider>().message),
                                    backgroundColor: AppTheme.errorRed,
                                  ),
                                );
                              }
                            }
                          },
                    child: isSubmittingDialog
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2.5, color: AppTheme.white),
                          )
                        : const Text('Guardar'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPostHeader() {
    return Card(
      margin: const EdgeInsets.all(0),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppTheme.primaryRed.withAlpha(30),
                  backgroundImage: widget.post.studentPhotoUrl != null
                      ? NetworkImage(widget.post.studentPhotoUrl!)
                      : null,
                  child: widget.post.studentPhotoUrl == null
                      ? Text(
                          widget.post.studentName.isNotEmpty
                              ? widget.post.studentName[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: AppTheme.primaryRed,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.post.studentName,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                      Text(
                        _timeAgo(widget.post.createdAt),
                        style: const TextStyle(fontSize: 12, color: AppTheme.mediumGrey),
                      ),
                    ],
                  ),
                ),
                // Badge de cantidad de respuestas
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryRed.withAlpha(20),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.forum_outlined, size: 16, color: AppTheme.primaryRed),
                      const SizedBox(width: 4),
                      Consumer<FeedProvider>(
                        builder: (context, feedProvider, _) {
                          // Actualiza el contador si han llegado más respuestas en el feed principal
                          final repliesMap = feedProvider.replies[widget.post.id];
                          final count = repliesMap?.length ?? widget.post.replyCount;
                          return Text(
                            '$count',
                            style: const TextStyle(
                              color: AppTheme.primaryRed,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              widget.post.content,
              style: const TextStyle(fontSize: 16, height: 1.4),
            ),
            if (widget.post.imageUrl != null) ...[
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: widget.post.imageUrl!,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => Container(
                    height: 200,
                    color: AppTheme.lightGrey,
                    child: const Center(
                      child: Icon(Icons.image_not_supported_outlined,
                          size: 48, color: AppTheme.mediumGrey),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentStudentId = context.watch<LoginProvider>().studentId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Comentarios'),
        backgroundColor: AppTheme.white,
        foregroundColor: AppTheme.darkText,
        elevation: 1,
      ),
      backgroundColor: AppTheme.lightGrey.withAlpha(150),
      body: Column(
        children: [
          Expanded(
            child: Consumer<FeedProvider>(
              builder: (context, feedProvider, _) {
                final replies = feedProvider.replies[widget.post.id] ?? [];
                final isLoading = feedProvider.isLoadingReplies;

                return CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: _buildPostHeader(),
                    ),
                    if (isLoading && replies.isEmpty)
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (replies.isEmpty)
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Center(
                            child: Text(
                              'Aún no hay respuestas.\n¡Sé el primero en comentar!',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppTheme.mediumGrey, fontSize: 16),
                            ),
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.only(top: 8, bottom: 16),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final reply = replies[index];
                              final isOwner = reply.studentId == currentStudentId;

                              return Container(
                                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppTheme.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withAlpha(5),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundColor: AppTheme.primaryRed.withAlpha(30),
                                      backgroundImage: reply.studentPhotoUrl != null
                                          ? NetworkImage(reply.studentPhotoUrl!)
                                          : null,
                                      child: reply.studentPhotoUrl == null
                                          ? Text(
                                              reply.studentName.isNotEmpty
                                                  ? reply.studentName[0].toUpperCase()
                                                  : '?',
                                              style: const TextStyle(
                                                color: AppTheme.primaryRed,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            )
                                          : null,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  reply.studentName,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 14,
                                                    color: AppTheme.darkText,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              Text(
                                                _timeAgo(reply.createdAt),
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  color: AppTheme.mediumGrey,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            reply.content,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              height: 1.3,
                                              color: AppTheme.darkText,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (isOwner)
                                      PopupMenuButton<String>(
                                        icon: const Icon(Icons.more_vert, size: 20, color: AppTheme.mediumGrey),
                                        padding: EdgeInsets.zero,
                                        onSelected: (value) {
                                          if (value == 'edit') {
                                            _showEditReplyDialog(reply.id, reply.content);
                                          } else if (value == 'delete') {
                                            _confirmDeleteReply(reply.id);
                                          }
                                        },
                                        itemBuilder: (context) => [
                                          const PopupMenuItem(
                                            value: 'edit',
                                            child: Row(
                                              children: [
                                                Icon(Icons.edit_outlined, size: 18),
                                                SizedBox(width: 8),
                                                Text('Editar'),
                                              ],
                                            ),
                                          ),
                                          const PopupMenuItem(
                                            value: 'delete',
                                            child: Row(
                                              children: [
                                                Icon(Icons.delete_outline, size: 18, color: AppTheme.errorRed),
                                                SizedBox(width: 8),
                                                Text('Eliminar', style: TextStyle(color: AppTheme.errorRed)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              );
                            },
                            childCount: replies.length,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          
          // ── Input inferior para nueva respuesta ───────────────────────
          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 12,
              bottom: MediaQuery.of(context).padding.bottom + 12,
            ),
            decoration: BoxDecoration(
              color: AppTheme.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(10),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: _replyController,
                    minLines: 1,
                    maxLines: 4,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: 'Añadir un comentario...',
                      hintStyle: const TextStyle(color: AppTheme.mediumGrey, fontSize: 14),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      filled: true,
                      fillColor: AppTheme.lightGrey.withAlpha(150),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: _isSubmitting ? AppTheme.lightGrey : AppTheme.primaryRed,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2.5, color: AppTheme.primaryRed),
                          )
                        : const Icon(Icons.send_rounded, color: AppTheme.white, size: 20),
                    onPressed: _isSubmitting ? null : _submitReply,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
