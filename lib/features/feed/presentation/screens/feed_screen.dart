
/// Feed screen – shows list of posts with CRUD functionality.
import 'dart:io';
import 'package:flutter/material.dart';
import "package:uni_social_student/features/reports/presentation/screens/report_form_screen.dart";
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:uni_social_student/features/profile/logic/profile_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:uni_social_student/core/theme/app_theme.dart';
import 'package:uni_social_student/features/auth_login/logic/login_provider.dart';
import 'package:uni_social_student/features/feed/data/models/post_model.dart';
import 'package:uni_social_student/features/feed/logic/feed_provider.dart';
import 'package:uni_social_student/features/feed/presentation/screens/post_detail_screen.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<FeedProvider>().loadPosts();
    });
  }

  Future<void> _refreshPosts() async {
    await context.read<FeedProvider>().loadPosts();
  }

  void _showCreatePostDialog() {
    _showPostDialog(context);
  }

  void _showEditPostDialog(PostModel post) {
    _showPostDialog(context, existingPost: post);
  }

  void _showPostDialog(BuildContext ctx, {PostModel? existingPost}) {
    final contentController =
        TextEditingController(text: existingPost?.content ?? '');
    String? selectedImagePath; // Ruta del nuevo archivo elegido
    // URL de la imagen existente (para modo edición)
    String? existingImageUrl = existingPost?.imageUrl;
    bool isSubmitting = false;

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final bool hasNewImage = selectedImagePath != null;
            final bool hasExistingImage =
                !hasNewImage && existingImageUrl != null;
            final bool showPreview = hasNewImage || hasExistingImage;

            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 20,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Header ─────────────────────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            existingPost != null
                                ? 'Editar publicación'
                                : 'Nueva publicación',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.darkText,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ── Texto de la publicación ─────────────────────────
                    TextField(
                      controller: contentController,
                      maxLines: 5,
                      minLines: 3,
                      decoration: const InputDecoration(
                        hintText: '¿Qué quieres compartir?',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ── Vista previa de imagen ──────────────────────────
                    if (showPreview) ...[
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: hasNewImage
                                ? Image.file(
                                    File(selectedImagePath!),
                                    width: double.infinity,
                                    height: 220,
                                    fit: BoxFit.cover,
                                  )
                                : CachedNetworkImage(
                                    imageUrl: existingImageUrl!,
                                    width: double.infinity,
                                    height: 220,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      height: 220,
                                      color: AppTheme.lightGrey,
                                      child: const Center(
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) => Container(
                                      height: 220,
                                      color: AppTheme.lightGrey,
                                      child: const Center(
                                        child: Icon(Icons.broken_image_outlined,
                                            size: 48, color: AppTheme.mediumGrey),
                                      ),
                                    ),
                                  ),
                          ),
                          // Botón quitar imagen
                          Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: () {
                                setModalState(() {
                                  selectedImagePath = null;
                                  existingImageUrl = null;
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withAlpha(160),
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(5),
                                child: const Icon(Icons.close,
                                    color: Colors.white, size: 18),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],

                    // ── Botón adjuntar / cambiar imagen ────────────────
                    OutlinedButton.icon(
                      onPressed: () async {
                        final result = await FilePicker.platform.pickFiles(
                          type: FileType.image,
                          allowMultiple: false,
                        );
                        if (result != null && result.files.isNotEmpty) {
                          setModalState(() {
                            selectedImagePath = result.files.first.path;
                            existingImageUrl = null; // reemplaza la existente
                          });
                        }
                      },
                      icon: const Icon(Icons.image_outlined),
                      label:
                          Text(showPreview ? 'Cambiar imagen' : 'Adjuntar imagen'),
                    ),

                    const SizedBox(height: 16),

                    // ── Botón publicar / guardar ────────────────────────
                    ElevatedButton(
                      onPressed: isSubmitting
                          ? null
                          : () async {
                              final content = contentController.text.trim();
                              if (content.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'El contenido no puede estar vacío.'),
                                    backgroundColor: AppTheme.errorRed,
                                  ),
                                );
                                return;
                              }

                              setModalState(() => isSubmitting = true);

                              final feedProvider =
                                  context.read<FeedProvider>();
                              bool success;

                              if (existingPost != null) {
                                success = await feedProvider.updatePost(
                                  postId: existingPost.id,
                                  content: content,
                                  imagePath: selectedImagePath,
                                );
                              } else {
                                success = await feedProvider.createPost(
                                  content: content,
                                  imagePath: selectedImagePath,
                                );
                              }

                              setModalState(() => isSubmitting = false);

                              if (!context.mounted) return;

                              if (success) {
                                final messenger = ScaffoldMessenger.of(context);
                                Navigator.pop(context);
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Text(existingPost != null
                                        ? 'Publicación actualizada.'
                                        : 'Publicación creada.'),
                                    backgroundColor: AppTheme.successGreen,
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(feedProvider.message),
                                    backgroundColor: AppTheme.errorRed,
                                  ),
                                );
                              }
                            },
                      child: isSubmitting
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: AppTheme.white,
                              ),
                            )
                          : Text(
                              existingPost != null ? 'Guardar' : 'Publicar'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _confirmDelete(PostModel post) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar publicación'),
        content: const Text(
            '¿Estás seguro de que deseas eliminar esta publicación?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar',
                style: TextStyle(color: AppTheme.errorRed)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await context.read<FeedProvider>().deletePost(post.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                success ? 'Publicación eliminada.' : 'Error al eliminar.'),
            backgroundColor:
                success ? AppTheme.successGreen : AppTheme.errorRed,
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

  Widget _buildHeader(BuildContext context) {
    final loginProvider = context.watch<LoginProvider>();
    final profileProvider = context.watch<ProfileProvider>();
    final firstName = loginProvider.studentName?.split(' ').first ?? 'Alex';
    final photoUrl = profileProvider.profilePhotoUrl;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // Renglón de bienvenida

        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 24,
                backgroundColor: AppTheme.primaryRed,
                child: Text('U', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 12),
              Column(

                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Noticias del Campus', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.darkText)),
                  Text('Buenos Días, $firstName', style: TextStyle(fontSize: 14, color: AppTheme.mediumGrey)),
                ],
              ),
            ],
          ),
        ),

        // Caja de entrada "Qué está pasando"
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: _showCreatePostDialog,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppTheme.lightGrey,
                        backgroundImage: photoUrl != null ? CachedNetworkImageProvider(photoUrl) : null,
                        child: photoUrl == null ? const Icon(Icons.person, color: AppTheme.mediumGrey) : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppTheme.lightGrey.withAlpha(100),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            '¿Qué está pasando en el campus?',
                            style: TextStyle(color: AppTheme.mediumGrey, fontSize: 14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.image_outlined, color: AppTheme.primaryRed),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    final loginProvider = context.watch<LoginProvider>();
    final currentStudentId = loginProvider.studentId;

    return Scaffold(
      body: Consumer<FeedProvider>(
        builder: (context, feed, _) {
          if (feed.isLoading && feed.posts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (feed.status == FeedStatus.error && feed.posts.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline,
                      size: 64,
                      color: AppTheme.primaryRed.withAlpha(180)),
                  const SizedBox(height: 16),
                  Text(feed.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppTheme.mediumGrey)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshPosts,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }



          return RefreshIndicator(
            onRefresh: _refreshPosts,
            color: AppTheme.primaryRed,
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 80), // extra padding for FAB
              itemCount: feed.posts.isEmpty ? 2 : feed.posts.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildHeader(context);
                }

                if (feed.posts.isEmpty) {
                  return SizedBox(
                    height: 300,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.dynamic_feed_outlined, size: 72, color: AppTheme.primaryRed.withAlpha(180)),
                          const SizedBox(height: 20),
                          const Text(
                            'No hay publicaciones aún.\n¡Sé el primero en publicar!',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.darkText, height: 1.5),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final post = feed.posts[index - 1];
                final isOwner = post.studentId == currentStudentId;

                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header: avatar + nombre + tiempo + menú
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor:
                                  AppTheme.primaryRed.withAlpha(30),
                              backgroundImage: post.studentPhotoUrl != null
                                  ? NetworkImage(post.studentPhotoUrl!)
                                  : null,
                              child: post.studentPhotoUrl == null
                                  ? Text(
                                      post.studentName.isNotEmpty
                                          ? post.studentName[0].toUpperCase()
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
                                    post.studentName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                  Text(
                                    _timeAgo(post.createdAt),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.mediumGrey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isOwner)
                              PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert,
                                    color: AppTheme.mediumGrey),
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    _showEditPostDialog(post);
                                  } else if (value == 'delete') {
                                    _confirmDelete(post);
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit_outlined, size: 20),
                                        SizedBox(width: 8),
                                        Text('Editar'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete_outline, color: AppTheme.primaryRed, size: 20),
                                        SizedBox(width: 8),
                                        Text('Eliminar', style: TextStyle(color: AppTheme.primaryRed)),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            else
                              PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert, color: AppTheme.mediumGrey),
                                onSelected: (value) {
                                  if (value == 'report') {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => ReportFormScreen(
                                          targetId: post.studentId.toString(),
                                          targetType: 'post',
                                          targetItemId: post.id,
                                        ),
                                      ),
                                    );
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'report',
                                    child: Row(
                                      children: [
                                        Icon(Icons.report_outlined, size: 20, color: AppTheme.primaryRed),
                                        SizedBox(width: 8),
                                        Text('Reportar', style: TextStyle(color: AppTheme.primaryRed)),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Contenido
                        Text(
                          post.content,
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.4,
                          ),
                        ),

                        // Imagen del post
                        if (post.imageUrl != null) ...[
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              imageUrl: post.imageUrl!,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                height: 200,
                                color: AppTheme.lightGrey,
                                child: const Center(
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                height: 200,
                                color: AppTheme.lightGrey,
                                child: const Center(
                                  child: Icon(Icons.broken_image_outlined,
                                      size: 48, color: AppTheme.mediumGrey),
                                ),
                              ),
                            ),
                          ),
                        ],
                        
                        const SizedBox(height: 12),
                        const Divider(height: 1),
                        const SizedBox(height: 8),
                        
                        // ── Barra de acciones (Comentarios) ───────────────
                        Row(
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PostDetailScreen(post: post),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.forum_outlined,
                                      size: 20,
                                      color: AppTheme.mediumGrey,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      post.replyCount > 0
                                          ? '${post.replyCount} comentarios'
                                          : 'Comentar',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: AppTheme.mediumGrey,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreatePostDialog,
        backgroundColor: AppTheme.primaryRed,
        child: const Icon(Icons.add, color: AppTheme.white),
      ),
    );
  }
}
