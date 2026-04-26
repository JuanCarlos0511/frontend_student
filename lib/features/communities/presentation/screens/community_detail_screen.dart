import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';

import 'package:provider/provider.dart';
import 'package:uni_social_student/core/theme/app_theme.dart';
import 'package:uni_social_student/features/communities/data/models/community_models.dart';
import 'package:uni_social_student/features/communities/logic/community_provider.dart';
import 'package:uni_social_student/features/profile/logic/profile_provider.dart';

class CommunityDetailScreen extends StatefulWidget {
  final int communityId;

  const CommunityDetailScreen({super.key, required this.communityId});

  @override
  State<CommunityDetailScreen> createState() => _CommunityDetailScreenState();
}

class _CommunityDetailScreenState extends State<CommunityDetailScreen> {
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<CommunityProvider>();
      p.loadCommunityDetail(widget.communityId);
      p.loadPosts(widget.communityId);
    });
  }

  
  void _showMembersSheet(BuildContext context, CommunityProvider provider, int communityId) {
    provider.loadMembers(communityId);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          builder: (ctx, scrollController) {
            return Consumer<CommunityProvider>(
              builder: (ctx, p, _) {
                return Column(
                  children: [
                    const SizedBox(height: 8),
                    Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
                    const SizedBox(height: 16),
                    const Text('Integrantes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Expanded(
                      child: p.isLoadingMembers
                          ? const Center(child: CircularProgressIndicator())
                          : ListView.builder(
                              controller: scrollController,
                              itemCount: p.members.length,
                              itemBuilder: (ctx, index) {
                                final m = p.members[index];
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundImage: m.profilePhotoPath != null ? CachedNetworkImageProvider(m.profilePhotoPath!) : null,
                                    child: m.profilePhotoPath == null ? const Icon(Icons.person) : null,
                                  ),
                                  title: Text(m.fullName),
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  void _showMembersOptions(BuildContext context, CommunityModel community) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.people_outline),
                title: const Text('Ver Integrantes'),
                onTap: () {
                  Navigator.pop(ctx);
                  _showMembersSheet(context, context.read<CommunityProvider>(), community.id);
                },
              ),
              if (community.creatorId == context.read<CommunityProvider>().currentStudentId) ...[
                ListTile(
                  leading: const Icon(Icons.admin_panel_settings_outlined),
                  title: const Text('Ajustes de comunidad (Gestión de Moderadores)'),
                  onTap: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gestión de moderadores próximamente')));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: AppTheme.errorRed),
                  title: const Text('Eliminar Comunidad', style: TextStyle(color: AppTheme.errorRed)),
                  onTap: () {
                    Navigator.pop(ctx);
                    _deleteCommunity(context.read<CommunityProvider>());
                  },
                ),
              ] else if (community.isMember == true) ...[
                ListTile(
                  leading: const Icon(Icons.exit_to_app, color: AppTheme.errorRed),
                  title: const Text('Salir de la comunidad', style: TextStyle(color: AppTheme.errorRed)),
                  onTap: () {
                    Navigator.pop(ctx);
                    context.read<CommunityProvider>().leaveCommunity(community.id);
                  },
                ),
              ],
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Future<void> _deleteCommunity(CommunityProvider provider) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Comunidad'),
        content: const Text('¿Estás seguro de que deseas eliminar este grupo de forma permanente?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar', style: TextStyle(color: AppTheme.mediumGrey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar', style: TextStyle(color: AppTheme.errorRed)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final success = await provider.deleteCommunity(widget.communityId);
      if (success && mounted) {
        final messenger = ScaffoldMessenger.of(context);
        Navigator.pop(context);
        messenger.showSnackBar(
          const SnackBar(content: Text('Comunidad eliminada.'), backgroundColor: AppTheme.successGreen),
        );
      }
    }
  }

  Future<void> _showCreatePostSheet(BuildContext ctx) async {
    final provider = ctx.read<CommunityProvider>();
    if (provider.activeCommunity?.isMember != true) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(content: Text('Debes unirte a la comunidad para publicar.'), backgroundColor: AppTheme.errorRed),
      );
      return;
    }

    final contentController = TextEditingController();
    String? selectedImagePath; // Ruta del nuevo archivo elegido
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
            final bool showPreview = hasNewImage;

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
                        const Expanded(
                          child: Text(
                            'Nueva publicación',
                            style: TextStyle(
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
                            child: Image.file(
                              File(selectedImagePath!),
                              width: double.infinity,
                              height: 220,
                              fit: BoxFit.cover,
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
                          });
                        }
                      },
                      icon: const Icon(Icons.image_outlined),
                      label: Text(showPreview ? 'Cambiar imagen' : 'Adjuntar imagen'),
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
                                    content: Text('El contenido no puede estar vacío.'),
                                    backgroundColor: AppTheme.errorRed,
                                  ),
                                );
                                return;
                              }

                              setModalState(() => isSubmitting = true);

                              final success = await provider.createPost(
                                communityId: widget.communityId,
                                content: content,
                                imagePath: selectedImagePath,
                              );

                              if (!context.mounted) return;
                              setModalState(() => isSubmitting = false);

                              if (success) {
                                final messenger = ScaffoldMessenger.of(context);
                                Navigator.pop(context);
                                messenger.showSnackBar(
                                  const SnackBar(
                                    content: Text('Publicación creada.'),
                                    backgroundColor: AppTheme.successGreen,
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Error al crear publicación.'),
                                    backgroundColor: AppTheme.errorRed,
                                  ),
                                );
                              }
                            },
                      child: isSubmitting
                          ? const SizedBox(
                              width: 20, 
                              height: 20, 
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.white)
                            )
                          : const Text('Publicar'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9), // Light background to match the mockup
      body: Consumer<CommunityProvider>(
        builder: (context, provider, _) {
          final c = provider.activeCommunity;
          if (c == null) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primaryRed));
          }

          final bgImage = (c.coverImage != null && c.coverImage!.isNotEmpty) ? c.coverImage! : 'https://via.placeholder.com/800x400.png?text=Community';

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                backgroundColor: AppTheme.primaryRed,
                systemOverlayStyle: SystemUiOverlayStyle.light,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.black.withAlpha(80),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                actions: [
                  if (c.creatorId == context.read<CommunityProvider>().currentStudentId)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircleAvatar(
                        backgroundColor: Colors.black.withAlpha(80),
                        child: IconButton(
                          icon: const Icon(Icons.more_vert, color: Colors.white, size: 20),
                          onPressed: () => _showMembersOptions(context, c),
                        ),
                      ),
                    ),
                ],
                
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(40),
                  child: Transform.translate(
                    offset: const Offset(0, 20),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 10, offset: const Offset(0, 5)),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            GestureDetector(onTap: () => setState(() => _selectedTab = 0), child: _buildTabItem(Icons.dynamic_feed, 'Feed', _selectedTab == 0 ? AppTheme.primaryRed : Colors.black54, _selectedTab == 0)),
                            const VerticalDivider(width: 1, indent: 15, endIndent: 15, color: Colors.black12),
                            GestureDetector(onTap: () => setState(() => _selectedTab = 1), child: _buildTabItem(Icons.photo_library_outlined, 'Galería', _selectedTab == 1 ? AppTheme.primaryRed : Colors.black54, _selectedTab == 1)),
                            const VerticalDivider(width: 1, indent: 15, endIndent: 15, color: Colors.black12),
                            GestureDetector(onTap: () => setState(() => _selectedTab = 2), child: _buildTabItem(Icons.folder_open_outlined, 'Recursos', _selectedTab == 2 ? AppTheme.primaryRed : Colors.black54, _selectedTab == 2)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl: bgImage,
                        fit: BoxFit.cover,
                      ),
                      // Gradient overlay for text readability
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.transparent, Colors.black87],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 50,
                        left: 20,
                        right: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(color: AppTheme.primaryRed, borderRadius: BorderRadius.circular(4)),
                                  child: const Text('COMUNIDAD', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(color: Colors.white.withAlpha(50), borderRadius: BorderRadius.circular(4)),
                                  child: Text(c.category, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              c.name,
                              style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.people, color: Colors.white70, size: 14),
                                const SizedBox(width: 4),
                                Text('${c.membersCount} Miembros', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                                const Text(''),
                                Container(),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Share something card
              SliverToBoxAdapter(
                child: Transform.translate(
                  offset: const Offset(0, 0),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16, top: 40),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Consumer<ProfileProvider>(
                            builder: (ctx, profileProvider, _) {
                              final photoUrl = profileProvider.profilePhotoUrl;
                              return CircleAvatar(
                                radius: 18,
                                backgroundColor: Colors.grey.shade200,
                                backgroundImage: photoUrl != null
                                    ? CachedNetworkImageProvider(photoUrl)
                                    : null,
                                child: photoUrl == null
                                    ? const Icon(Icons.person, color: Colors.grey)
                                    : null,
                              );
                            },
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                _showCreatePostSheet(context);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF0F0F0),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text('Comparte algo con el grupo...', style: TextStyle(color: Colors.black54, fontSize: 13)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
                            child: const Icon(Icons.image, color: AppTheme.primaryRed, size: 20),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Feed
              
              if (_selectedTab == 1)
                const SliverToBoxAdapter(child: Center(child: Padding(padding: EdgeInsets.all(40), child: Text('La galería está vacía', style: TextStyle(color: Colors.black54)))))
              else if (_selectedTab == 2)
                const SliverToBoxAdapter(child: Center(child: Padding(padding: EdgeInsets.all(40), child: Text('No hay recursos disponibles', style: TextStyle(color: Colors.black54)))))
              else if (provider.isLoadingPosts)
                const SliverToBoxAdapter(child: Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator())))
              else
                SliverList(


                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final p = provider.posts[index];
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor: Colors.grey.shade200,
                                    backgroundImage: p.profilePhotoPath != null ? CachedNetworkImageProvider(p.profilePhotoPath!) : null,
                                    child: p.profilePhotoPath == null ? const Icon(Icons.person, color: Colors.grey) : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(p.authorName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                        Text('Advanced • ${p.createdAt.hour}h ago', style: const TextStyle(color: Colors.black54, fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.more_horiz, color: Colors.black38),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(p.content, style: const TextStyle(fontSize: 14, height: 1.4)),
                              if (p.imageUrl != null && p.imageUrl!.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: CachedNetworkImage(imageUrl: p.imageUrl!, width: double.infinity, fit: BoxFit.cover),
                                ),
                              ],
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  const Icon(Icons.favorite_border, color: Colors.black54, size: 18),
                                  const SizedBox(width: 4),
                                  const Text('24', style: TextStyle(color: Colors.black54, fontSize: 12)),
                                  const SizedBox(width: 24),
                                  const Icon(Icons.chat_bubble_outline, color: Colors.black54, size: 18),
                                  const SizedBox(width: 4),
                                  const Text('5', style: TextStyle(color: Colors.black54, fontSize: 12)),
                                  const Spacer(),
                                  const Icon(Icons.share_outlined, color: Colors.black54, size: 18),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: provider.posts.length,
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCreatePostSheet(context);
        },
        backgroundColor: AppTheme.primaryRed,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildTabItem(IconData icon, String label, Color color, bool selected) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarStack() {
    return SizedBox(
      width: 70,
      height: 24,
      child: Stack(
        children: [
          Positioned(left: 0, child: CircleAvatar(radius: 12, backgroundColor: Colors.blue.shade100, child: const Icon(Icons.person, size: 16, color: Colors.white))),
          Positioned(left: 15, child: CircleAvatar(radius: 12, backgroundColor: Colors.purple.shade100, child: const Icon(Icons.person, size: 16, color: Colors.white))),
          Positioned(left: 30, child: CircleAvatar(radius: 12, backgroundColor: Colors.orange.shade100, child: const Icon(Icons.person, size: 16, color: Colors.white))),
          Positioned(left: 45, child: CircleAvatar(radius: 12, backgroundColor: Colors.grey.shade200, child: const Text('+12', style: TextStyle(color: Colors.black54, fontSize: 10)))),
        ],
      ),
    );
  }
}
