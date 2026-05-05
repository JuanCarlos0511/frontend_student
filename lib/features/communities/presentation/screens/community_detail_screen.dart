import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';

import "package:uni_social_student/core/network/network_client.dart";
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

  void _showMembersSheet(
      BuildContext context, CommunityProvider provider, int communityId) {
    provider.loadMembers(communityId);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          builder: (ctx, scrollController) {
            return Consumer<CommunityProvider>(
              builder: (ctx, p, _) {
                return Column(
                  children: [
                    const SizedBox(height: 8),
                    Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2))),
                    const SizedBox(height: 16),
                    const Text('Integrantes',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
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
                                    backgroundImage: m.profilePhotoPath != null
                                        ? CachedNetworkImageProvider(
                                            m.profilePhotoPath!)
                                        : null,
                                    child: m.profilePhotoPath == null
                                        ? const Icon(Icons.person)
                                        : null,
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
                  _showMembersSheet(
                      context, context.read<CommunityProvider>(), community.id);
                },
              ),
              if (community.creatorId ==
                  context.read<CommunityProvider>().currentStudentId) ...[
                ListTile(
                  leading: const Icon(Icons.admin_panel_settings_outlined),
                  title: const Text('Ajustes de Privacidad'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _showSettingsDialog(context, community.id);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.group_add_outlined),
                  title: const Text('Solicitudes de unirse'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _showRequestsDialog(context, community.id);
                  },
                ),

                ListTile(
                  leading: const Icon(Icons.security_outlined),
                  title: const Text('Administrar Moderadores'),
                  onTap: () {
                    Navigator.pop(ctx);
                    showDialog(
                      context: context,
                      builder: (c) => _ModeratorSettingsDialog(communityId: community.id)
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_outline,
                      color: AppTheme.errorRed),
                  title: const Text('Eliminar Comunidad',
                      style: TextStyle(color: AppTheme.errorRed)),
                  onTap: () {
                    Navigator.pop(ctx);
                    _deleteCommunity(context.read<CommunityProvider>());
                  },
                ),
              ] else if (community.isMember == true) ...[
                ListTile(
                  leading:
                      const Icon(Icons.exit_to_app, color: AppTheme.errorRed),
                  title: const Text('Salir de la comunidad',
                      style: TextStyle(color: AppTheme.errorRed)),
                  onTap: () {
                    Navigator.pop(ctx);
                    context
                        .read<CommunityProvider>()
                        .leaveCommunity(community.id);
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

  void _attemptJoin(BuildContext context, int communityId) async {
    final prov = context.read<CommunityProvider>();
    try {
      final c = prov.activeCommunity!;
      if (c.privacyMode == 'private_questionnaire') {
        final qs = await prov.getQuestions(communityId);
        if (qs.isEmpty) {
          await prov.joinRequest(communityId, {});
          return;
        }

        if (!context.mounted) return;
        List<TextEditingController> ctrls =
            qs.map((_) => TextEditingController()).toList();
        showDialog(
            context: context,
            builder: (ctx) {
              return AlertDialog(
                title: const Text('Responder Cuestionario'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: qs.asMap().entries.map((e) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: TextField(
                          controller: ctrls[e.key],
                          decoration:
                              InputDecoration(labelText: e.value['question']),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                actions: [
                  TextButton(
                      child: const Text('Cancelar',
                          style: TextStyle(color: AppTheme.mediumGrey)),
                      onPressed: () => Navigator.pop(ctx)),
                  TextButton(
                      child: const Text('Enviar',
                          style: TextStyle(color: AppTheme.primaryRed)),
                      onPressed: () async {
                        Map<String, dynamic> answers = {};
                        for (int i = 0; i < qs.length; i++) {
                          answers[qs[i]['id'].toString()] = ctrls[i].text;
                        }
                        await prov.joinRequest(communityId, answers);
                        if (context.mounted) {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Solicitud enviada'),
                                  backgroundColor: AppTheme.successGreen));
                        }
                      }),
                ],
              );
            });
      } else {
        await prov.joinRequest(communityId, {});
        if (context.mounted) {
          String msg = c.privacyMode == 'public'
              ? 'Te has unido exitosamente'
              : 'Solicitud enviada';
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(msg), backgroundColor: AppTheme.successGreen));
        }
      }
    } catch (e) {
      if (context.mounted)
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Error al unirse'),
            backgroundColor: AppTheme.errorRed));
    }
  }

  void _showSettingsDialog(BuildContext context, int communityId) async {
    final prov = context.read<CommunityProvider>();
    try {
      final data = await prov.getSettings(communityId);
      final initialPrivacy = data['data']['privacyMode'];
      final rawQuestions = data['data']['questions'] as List;
      final initialQuestions =
          rawQuestions.map((q) => q['question'].toString()).toList();

      if (!context.mounted) return;
      showDialog(
          context: context,
          builder: (ctx) => _SettingsDialog(
                communityId: communityId,
                initialPrivacy: initialPrivacy,
                initialQuestions: initialQuestions,
              ));
    } catch (e) {
      if (context.mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _showRequestsDialog(BuildContext context, int communityId) async {
    final prov = context.read<CommunityProvider>();
    try {
      final reqs = await prov.getRequests(communityId);
      if (!context.mounted) return;
      showDialog(
        context: context,
        builder: (ctx) =>
            _RequestsDialog(requests: reqs, communityId: communityId),
      );
    } catch (e) {
      if (context.mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _deleteCommunity(CommunityProvider provider) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Comunidad'),
        content: const Text(
            '¿Estás seguro de que deseas eliminar este grupo de forma permanente?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar',
                style: TextStyle(color: AppTheme.mediumGrey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar',
                style: TextStyle(color: AppTheme.errorRed)),
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
          const SnackBar(
              content: Text('Comunidad eliminada.'),
              backgroundColor: AppTheme.successGreen),
        );
      }
    }
  }

  Future<void> _showCreatePostSheet(BuildContext ctx) async {
    final provider = ctx.read<CommunityProvider>();
    if (provider.activeCommunity?.isMember != true) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(
            content: Text('Debes unirte a la comunidad para publicar.'),
            backgroundColor: AppTheme.errorRed),
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
                      label: Text(
                          showPreview ? 'Cambiar imagen' : 'Adjuntar imagen'),
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
                                    content:
                                        Text('Error al crear publicación.'),
                                    backgroundColor: AppTheme.errorRed,
                                  ),
                                );
                              }
                            },
                      child: isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: AppTheme.white))
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
      bottomNavigationBar: Consumer<CommunityProvider>(
        builder: (context, provider, _) {
          final c = provider.activeCommunity;
          if (c != null && c.isCourse == true && c.creatorId == provider.currentStudentId) {
            final modules = c.courseModules;
            final isFinished = c.currentTopicIndex >= (modules.length - 1);
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isFinished ? Colors.grey : AppTheme.primaryRed,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: isFinished ? null : () async {
                       bool ok = await provider.advanceCourseTopic(c.id);
                       if (ok && context.mounted) {
                         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Avanzaste al siguiente tema'), backgroundColor: AppTheme.successGreen));
                       } else if (!ok && context.mounted) {
                         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al avanzar tema'), backgroundColor: AppTheme.errorRed));
                       }
                    },
                    child: Text(isFinished ? 'Curso finalizado' : 'Siguiente tema', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        }
      ),
      backgroundColor:
          const Color(0xFFF9F9F9), // Light background to match the mockup
      body: Consumer<CommunityProvider>(
        builder: (context, provider, _) {
          final c = provider.activeCommunity;
          if (c == null) {
            return const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryRed));
          }

          final bgImage = (c.coverImage != null && c.coverImage!.isNotEmpty)
              ? c.coverImage!
              : 'https://via.placeholder.com/800x400.png?text=Community';

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
                      icon: const Icon(Icons.arrow_back,
                          color: Colors.white, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                actions: [
                  if (c.creatorId ==
                      context.read<CommunityProvider>().currentStudentId)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircleAvatar(
                        backgroundColor: Colors.black.withAlpha(80),
                        child: IconButton(
                          icon: const Icon(Icons.more_vert,
                              color: Colors.white, size: 20),
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
                            BoxShadow(
                                color: Colors.black.withAlpha(10),
                                blurRadius: 10,
                                offset: const Offset(0, 5)),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                                child: InkWell(
                                    onTap: () =>
                                        setState(() => _selectedTab = 0),
                                    child: _buildTabItem(
                                        Icons.dynamic_feed,
                                        'Feed',
                                        _selectedTab == 0
                                            ? AppTheme.primaryRed
                                            : Colors.black54,
                                        _selectedTab == 0))),
                            const VerticalDivider(
                                width: 1,
                                indent: 15,
                                endIndent: 15,
                                color: Colors.black12),
                            Expanded(
                                child: InkWell(
                                    onTap: () =>
                                        setState(() => _selectedTab = 1),
                                    child: _buildTabItem(
                                        Icons.photo_library_outlined,
                                        'Galería',
                                        _selectedTab == 1
                                            ? AppTheme.primaryRed
                                            : Colors.black54,
                                        _selectedTab == 1))),
                            const VerticalDivider(
                                width: 1,
                                indent: 15,
                                endIndent: 15,
                                color: Colors.black12),
                            Expanded(
                                child: InkWell(
                                    onTap: () =>
                                        setState(() => _selectedTab = 2),
                                    child: _buildTabItem(
                                        Icons.folder_open_outlined,
                                        'Recursos',
                                        _selectedTab == 2
                                            ? AppTheme.primaryRed
                                            : Colors.black54,
                                        _selectedTab == 2))),
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
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                      color: AppTheme.primaryRed,
                                      borderRadius: BorderRadius.circular(4)),
                                  child: Text(c.isCourse ? 'CURSO' : 'COMUNIDAD',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold)),
                                ),
                                if (c.isCourse && c.courseModules.isNotEmpty) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                        color: Colors.blueAccent,
                                        borderRadius: BorderRadius.circular(4)),
                                    child: Text('Tema actual: ${c.courseModules.length > c.currentTopicIndex ? c.courseModules[c.currentTopicIndex] : "Finalizado"}',
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ],
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                      color: Colors.white.withAlpha(50),
                                      borderRadius: BorderRadius.circular(4)),
                                  child: Text(c.category,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              c.name,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.people,
                                    color: Colors.white70, size: 14),
                                const SizedBox(width: 4),
                                Text('${c.membersCount} Miembros',
                                    style: const TextStyle(
                                        color: Colors.white70, fontSize: 12)),
                                const SizedBox(width: 12),
                                if (c.isMember != true)
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.white,
                                        foregroundColor: AppTheme.primaryRed,
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 0),
                                        minimumSize: const Size(0, 24),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(6))),
                                    onPressed: () =>
                                        _attemptJoin(context, c.id),
                                    child: const Text('Unirme',
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold)),
                                  ),
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
                    padding:
                        const EdgeInsets.only(left: 16, right: 16, top: 40),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
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
                                    ? const Icon(Icons.person,
                                        color: Colors.grey)
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
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF0F0F0),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                    'Comparte algo con el grupo...',
                                    style: TextStyle(
                                        color: Colors.black54, fontSize: 13)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(8)),
                            child: const Icon(Icons.image,
                                color: AppTheme.primaryRed, size: 20),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Feed

              if (_selectedTab == 1)
                Builder(builder: (context) {
                  final galleryPosts = provider.posts
                      .where(
                          (p) => p.imageUrl != null && p.imageUrl!.isNotEmpty)
                      .toList();
                  if (galleryPosts.isEmpty) {
                    return const SliverToBoxAdapter(
                        child: Center(
                            child: Padding(
                                padding: EdgeInsets.all(40),
                                child: Text('La galería está vacía',
                                    style: TextStyle(color: Colors.black54)))));
                  }
                  return SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 2,
                            mainAxisSpacing: 2),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final p = galleryPosts[index];
                      return GestureDetector(
                        onTap: () => _openImageFullScreen(context, p),
                        child: CachedNetworkImage(
                            imageUrl: p.imageUrl!, fit: BoxFit.cover),
                      );
                    }, childCount: galleryPosts.length),
                  );
                })
              else if (_selectedTab == 2)
                _ResourcesTabSliver(
                  communityId: widget.communityId,
                  currentStudentId: provider.currentStudentId ?? -1,
                  communityCreatorId: provider.activeCommunity?.creatorId ?? -1,
                )
              else if (provider.isLoadingPosts)
                const SliverToBoxAdapter(
                    child: Center(
                        child: Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator())))
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final p = provider.posts[index];
                      return _CommunityPostCard(
                        key: ValueKey(p.id),
                        post: p,
                        communityId: widget.communityId,
                        isModOrCreator: (provider.activeCommunity?.creatorId ==
                            provider.currentStudentId),
                        currentStudentId: provider.currentStudentId ?? 0,
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

  void _openImageFullScreen(BuildContext context, dynamic p) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (ctx) => Scaffold(
                backgroundColor: Colors.black,
                appBar: AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    iconTheme: const IconThemeData(color: Colors.white)),
                extendBodyBehindAppBar: true,
                body: Stack(children: [
                  Positioned.fill(
                    child: InteractiveViewer(
                      child: CachedNetworkImage(
                          imageUrl: p.imageUrl!, fit: BoxFit.contain),
                    ),
                  ),
                  Positioned(
                      bottom: 40,
                      left: 16,
                      right: 16,
                      child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16)),
                          child: Row(children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.grey.shade200,
                              backgroundImage: p.profilePhotoPath != null
                                  ? CachedNetworkImageProvider(
                                      p.profilePhotoPath!)
                                  : null,
                              child: p.profilePhotoPath == null
                                  ? const Icon(Icons.person, color: Colors.grey)
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                                child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(p.authorName,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14)),
                                if (p.content.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Text(p.content,
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.black87)),
                                  ),
                              ],
                            ))
                          ])))
                ]))));
  }

  // modified tab builder
  Widget _buildTabItem(
      IconData icon, String label, Color color, bool selected) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
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
      ),
    );
  }

  Widget _buildAvatarStack() {
    return SizedBox(
      width: 70,
      height: 24,
      child: Stack(
        children: [
          Positioned(
              left: 0,
              child: CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.blue.shade100,
                  child:
                      const Icon(Icons.person, size: 16, color: Colors.white))),
          Positioned(
              left: 15,
              child: CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.purple.shade100,
                  child:
                      const Icon(Icons.person, size: 16, color: Colors.white))),
          Positioned(
              left: 30,
              child: CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.orange.shade100,
                  child:
                      const Icon(Icons.person, size: 16, color: Colors.white))),
          Positioned(
              left: 45,
              child: CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.grey.shade200,
                  child: const Text('+12',
                      style: TextStyle(color: Colors.black54, fontSize: 10)))),
        ],
      ),
    );
  }
}

class _SettingsDialog extends StatefulWidget {
  final int communityId;
  final String initialPrivacy;
  final List<String> initialQuestions;

  const _SettingsDialog(
      {Key? key,
      required this.communityId,
      required this.initialPrivacy,
      required this.initialQuestions})
      : super(key: key);

  @override
  _SettingsDialogState createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<_SettingsDialog> {
  late String _privacyMode;
  late List<TextEditingController> _qControllers;

  @override
  void initState() {
    super.initState();
    _privacyMode = widget.initialPrivacy;
    _qControllers = widget.initialQuestions
        .map((q) => TextEditingController(text: q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ajustes de Privacidad',
          style: TextStyle(fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Modo de privacidad:'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _privacyMode,
                  items: const [
                    DropdownMenuItem(value: 'public', child: Text('Pública')),
                    DropdownMenuItem(
                        value: 'private_simple',
                        child: Text('Privada (Solicitud)')),
                    DropdownMenuItem(
                        value: 'private_questionnaire',
                        child: Text('Privada (Cuestionario)')),
                  ],
                  onChanged: (v) {
                    if (v != null) setState(() => _privacyMode = v);
                  },
                ),
              ),
            ),
            if (_privacyMode == 'private_questionnaire') ...[
              const SizedBox(height: 16),
              const Text('Preguntas para unirse:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ..._qControllers.asMap().entries.map((entry) {
                int idx = entry.key;
                var currentCtrl = entry.value;
                return Row(
                  children: [
                    Expanded(
                        child: TextField(
                            controller: currentCtrl,
                            decoration: InputDecoration(
                                hintText: 'Pregunta ${idx + 1}',
                                isDense: true))),
                    IconButton(
                        icon: const Icon(Icons.remove_circle,
                            color: AppTheme.errorRed),
                        onPressed: () =>
                            setState(() => _qControllers.removeAt(idx)))
                  ],
                );
              }).toList(),
              TextButton.icon(
                  icon: const Icon(Icons.add_circle_outline,
                      color: AppTheme.primaryRed),
                  label: const Text('Añadir Pregunta',
                      style: TextStyle(color: AppTheme.primaryRed)),
                  onPressed: () => setState(
                      () => _qControllers.add(TextEditingController()))),
            ]
          ],
        ),
      ),
      actions: [
        TextButton(
            child: const Text('Cancelar',
                style: TextStyle(color: AppTheme.mediumGrey)),
            onPressed: () => Navigator.pop(context)),
        TextButton(
            child: const Text('Guardar',
                style: TextStyle(
                    color: AppTheme.primaryRed, fontWeight: FontWeight.bold)),
            onPressed: () async {
              final questions = _qControllers
                  .map((c) => c.text)
                  .where((t) => t.isNotEmpty)
                  .toList();
              await Provider.of<CommunityProvider>(context, listen: false)
                  .updateSettings(widget.communityId, _privacyMode, questions);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Ajustes guardados'),
                    backgroundColor: AppTheme.successGreen));
              }
            }),
      ],
    );
  }
}

class _RequestsDialog extends StatefulWidget {
  final List<dynamic> requests;
  final int communityId;

  const _RequestsDialog(
      {Key? key, required this.requests, required this.communityId})
      : super(key: key);

  @override
  _RequestsDialogState createState() => _RequestsDialogState();
}

class _RequestsDialogState extends State<_RequestsDialog> {
  late List<dynamic> _reqs;

  @override
  void initState() {
    super.initState();
    _reqs = List.from(widget.requests);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Solicitudes Pendientes',
          style: TextStyle(fontWeight: FontWeight.bold)),
      contentPadding: const EdgeInsets.only(top: 16),
      content: SizedBox(
        width: double.maxFinite,
        child: _reqs.isEmpty
            ? const Padding(
                padding: EdgeInsets.all(20),
                child: Text('No hay solicitudes pendientes.',
                    textAlign: TextAlign.center))
            : ListView.separated(
                shrinkWrap: true,
                itemCount: _reqs.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (ctx, i) {
                  final r = _reqs[i];
                  final name = '${r['first_name']} ${r['last_name']}';
                  final answers = r['answers'] as Map<String, dynamic>? ?? {};
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.grey.shade200,
                              backgroundImage: r['profile_photo_path'] != null
                                  ? CachedNetworkImageProvider(
                                      r['profile_photo_path'])
                                  : null,
                              child: r['profile_photo_path'] == null
                                  ? const Icon(Icons.person,
                                      size: 16, color: Colors.grey)
                                  : null,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                                child: Text(name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13))),
                            InkWell(
                                child: const Icon(Icons.check_circle,
                                    color: AppTheme.successGreen, size: 28),
                                onTap: () async {
                                  await Provider.of<CommunityProvider>(context,
                                          listen: false)
                                      .respondRequest(widget.communityId,
                                          r['id'], 'accept');
                                  setState(() => _reqs.removeAt(i));
                                }),
                            const SizedBox(width: 12),
                            InkWell(
                                child: const Icon(Icons.cancel,
                                    color: AppTheme.errorRed, size: 28),
                                onTap: () async {
                                  await Provider.of<CommunityProvider>(context,
                                          listen: false)
                                      .respondRequest(widget.communityId,
                                          r['id'], 'reject');
                                  setState(() => _reqs.removeAt(i));
                                }),
                          ],
                        ),
                        if (answers.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: answers.entries
                                    .map((e) => Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 4),
                                          child: Text('● R: ${e.value}',
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.black87)),
                                        ))
                                    .toList(),
                              ))
                        ]
                      ],
                    ),
                  );
                }),
      ),
      actions: [
        TextButton(
            child: const Text('Cerrar'),
            onPressed: () => Navigator.pop(context)),
      ],
    );
  }
}

class _CommunityPostCard extends StatefulWidget {
  final CommunityPostModel post;
  final int communityId;
  final bool isModOrCreator;
  final int currentStudentId;

  const _CommunityPostCard({
    Key? key,
    required this.post,
    required this.communityId,
    required this.isModOrCreator,
    required this.currentStudentId,
  }) : super(key: key);

  @override
  State<_CommunityPostCard> createState() => _CommunityPostCardState();
}

class _CommunityPostCardState extends State<_CommunityPostCard> {
  int _likesCount = 0;
  int _commentsCount = 0;
  bool _isLikedByMe = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final prov = context.read<CommunityProvider>();
    final stats = await prov.getPostDetails(widget.communityId, widget.post.id);
    if (mounted) {
      setState(() {
        _likesCount = stats['likesCount'] ?? 0;
        _commentsCount = stats['commentsCount'] ?? 0;
        _isLikedByMe = stats['isLikedByMe'] ?? false;
        _isLoading = false;
      });
    }
  }

  void _toggleLike() async {
    // Optimistic toggle
    setState(() {
      _isLikedByMe = !_isLikedByMe;
      _likesCount += _isLikedByMe ? 1 : -1;
    });

    final prov = context.read<CommunityProvider>();
    final newStatus = await prov.toggleLike(widget.communityId, widget.post.id);

    // Revert if failed
    if (mounted && newStatus != _isLikedByMe) {
      setState(() {
        _isLikedByMe = newStatus;
        _likesCount += _isLikedByMe ? 1 : -1;
      });
    }
  }

  String _formatTimeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 0) return 'Hace ${diff.inDays} d';
    if (diff.inHours > 0) return 'Hace ${diff.inHours} h';
    if (diff.inMinutes > 0) return 'Hace ${diff.inMinutes} m';
    return 'Hace un momento';
  }

  void _showEditPostDialog() {
    final TextEditingController editController =
        TextEditingController(text: widget.post.content);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editar publicación'),
        content: TextField(
          controller: editController,
          maxLines: 5,
          minLines: 3,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              final newContent = editController.text.trim();
              if (newContent.isNotEmpty) {
                final prov = context.read<CommunityProvider>();
                final success = await prov.editPost(
                    widget.communityId, widget.post.id, newContent);
                if (mounted && success) {
                  Navigator.pop(ctx);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Publicación editada'),
                        backgroundColor: AppTheme.successGreen));
                  }
                }
              }
            },
            child: const Text('Guardar',
                style: TextStyle(color: AppTheme.primaryRed)),
          ),
        ],
      ),
    );
  }

  void _showPostOptions() {
    showModalBottomSheet(
        context: context,
        builder: (ctx) => SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.post.studentId == widget.currentStudentId)
                    ListTile(
                      leading: const Icon(Icons.edit_outlined),
                      title: const Text('Editar'),
                      onTap: () {
                        Navigator.pop(ctx);
                        _showEditPostDialog();
                      },
                    ),
                  ListTile(
                    leading: const Icon(Icons.delete_outline,
                        color: AppTheme.errorRed),
                    title: const Text('Eliminar',
                        style: TextStyle(color: AppTheme.errorRed)),
                    onTap: () async {
                      Navigator.pop(ctx);
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx2) => AlertDialog(
                          title: const Text('Eliminar publicación'),
                          content: const Text(
                              '¿Estás seguro de eliminar este post?'),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(ctx2, false),
                                child: const Text('Cancelar',
                                    style: TextStyle(color: Colors.grey))),
                            TextButton(
                                onPressed: () => Navigator.pop(ctx2, true),
                                child: const Text('Eliminar',
                                    style:
                                        TextStyle(color: AppTheme.errorRed))),
                          ],
                        ),
                      );
                      if (confirm == true && mounted) {
                        final prov = context.read<CommunityProvider>();
                        final success = await prov.deletePost(
                            widget.communityId, widget.post.id);
                        if (mounted && success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Publicación eliminada'),
                                  backgroundColor: AppTheme.successGreen));
                        }
                      }
                    },
                  ),
                ],
              ),
            ));
  }

  void _showComments() {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (ctx) => _CommentsBottomSheet(
              communityId: widget.communityId,
              postId: widget.post.id,
              onCommentAdded: () {
                setState(() {
                  _commentsCount++;
                });
              },
            ));
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.post;
    final canEdit =
        (p.studentId == widget.currentStudentId) || widget.isModOrCreator;

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
                  backgroundImage: p.profilePhotoPath != null
                      ? CachedNetworkImageProvider(p.profilePhotoPath!)
                      : null,
                  child: p.profilePhotoPath == null
                      ? const Icon(Icons.person, color: Colors.grey)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.authorName,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14)),
                      Text(_formatTimeAgo(p.createdAt),
                          style: const TextStyle(
                              color: Colors.black54, fontSize: 12)),
                    ],
                  ),
                ),
                if (canEdit)
                  InkWell(
                      onTap: _showPostOptions,
                      child: const Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Icon(Icons.more_horiz, color: Colors.black38),
                      )),
              ],
            ),
            const SizedBox(height: 12),
            Text(p.content, style: const TextStyle(fontSize: 14, height: 1.4)),
            if (p.imageUrl != null && p.imageUrl!.isNotEmpty) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                    imageUrl: p.imageUrl!,
                    width: double.infinity,
                    fit: BoxFit.cover),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                InkWell(
                  onTap: _toggleLike,
                  child: Row(
                    children: [
                      Icon(
                          _isLikedByMe ? Icons.favorite : Icons.favorite_border,
                          color: _isLikedByMe
                              ? AppTheme.primaryRed
                              : Colors.black54,
                          size: 20),
                      const SizedBox(width: 4),
                      Text('$_likesCount',
                          style: TextStyle(
                              color: _isLikedByMe
                                  ? AppTheme.primaryRed
                                  : Colors.black54,
                              fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                InkWell(
                  onTap: _showComments,
                  child: Row(
                    children: [
                      const Icon(Icons.chat_bubble_outline,
                          color: Colors.black54, size: 18),
                      const SizedBox(width: 4),
                      Text('$_commentsCount',
                          style: const TextStyle(
                              color: Colors.black54, fontSize: 12)),
                    ],
                  ),
                ),
                const Spacer(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CommentsBottomSheet extends StatefulWidget {
  final int communityId;
  final int postId;
  final VoidCallback onCommentAdded;

  const _CommentsBottomSheet(
      {Key? key,
      required this.communityId,
      required this.postId,
      required this.onCommentAdded})
      : super(key: key);

  @override
  State<_CommentsBottomSheet> createState() => _CommentsBottomSheetState();
}

class _CommentsBottomSheetState extends State<_CommentsBottomSheet> {
  final TextEditingController _ctrl = TextEditingController();
  List<dynamic> _comments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  Future<void> _loadComments() async {
    final prov = context.read<CommunityProvider>();
    final comments = await prov.getComments(widget.communityId, widget.postId);
    if (mounted) {
      setState(() {
        _comments = comments;
        _isLoading = false;
      });
    }
  }

  void _postComment() async {
    final t = _ctrl.text.trim();
    if (t.isEmpty) return;
    FocusScope.of(context).unfocus();
    _ctrl.clear();

    final prov = context.read<CommunityProvider>();
    final ok = await prov.addComment(widget.communityId, widget.postId, t);
    if (ok) {
      widget.onCommentAdded();
      _loadComments();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2))),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Comentarios',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const Divider(height: 1),
            Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: _comments.length,
                        itemBuilder: (ctx, i) {
                          final c = _comments[i];
                          return ListTile(
                            leading: CircleAvatar(
                              radius: 16,
                              backgroundImage: c['profile_photo_path'] != null
                                  ? CachedNetworkImageProvider(
                                      c['profile_photo_path'])
                                  : null,
                              child: c['profile_photo_path'] == null
                                  ? const Icon(Icons.person, size: 16)
                                  : null,
                            ),
                            title: Text('${c['first_name']} ${c['last_name']}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 13)),
                            subtitle: Text(c['content'],
                                style: const TextStyle(color: Colors.black87)),
                          );
                        })),
            const Divider(height: 1),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                      child: TextField(
                    controller: _ctrl,
                    decoration: const InputDecoration(
                        hintText: 'Añadir un comentario...',
                        border: InputBorder.none),
                  )),
                  IconButton(
                    icon: const Icon(Icons.send, color: AppTheme.primaryRed),
                    onPressed: _postComment,
                  )
                ],
              ),
            ),
          ],
        ));
  }
}

class _ModeratorSettingsDialog extends StatefulWidget {
  final int communityId;
  const _ModeratorSettingsDialog({required this.communityId});

  @override
  State<_ModeratorSettingsDialog> createState() => _ModeratorSettingsDialogState();
}

class _ModeratorSettingsDialogState extends State<_ModeratorSettingsDialog> {
  bool _isLoading = true;
  List<dynamic> _moderators = [];
  List<dynamic> _members = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prov = context.read<CommunityProvider>();
    final mods = await prov.getModerators(widget.communityId);
    
    // We already have community members locally or need to fetch?
    // wait, getMembers exists in backend but not in provider? 
    // actually getCommunityMembers is not standard, so let's just fetch them if missing.
    // Ah, wait! The user joins, there's getMembers method probably?
    final res = await NetworkClient.instance.get('/communities/${widget.communityId}/members');
    final mems = res.data['success'] ? res.data['data'] as List<dynamic> : [];

    if (mounted) {
      setState(() {
        _moderators = mods;
        _members = mems;
        _isLoading = false;
      });
    }
  }

  bool _isMod(int studentId) {
    return _moderators.any((m) => m['student_id'] == studentId);
  }

  Future<void> _toggleMod(int studentId, bool isAlreadyMod) async {
    final prov = context.read<CommunityProvider>();
    bool success;
    if (isAlreadyMod) {
      success = await prov.removeModerator(widget.communityId, studentId);
    } else {
      success = await prov.addModerator(widget.communityId, studentId);
    }
    if (success) _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Administrar Moderadores'),
      content: SizedBox(
        width: double.maxFinite,
        height: 350,
        child: _isLoading 
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: _members.length,
                itemBuilder: (ctx, i) {
                  final m = _members[i];
                  final sid = m['student_id'] ?? m['id'];
                  final creatorId = context.read<CommunityProvider>().activeCommunity?.creatorId;
                  
                  if (sid == creatorId) return const SizedBox.shrink();

                  final isMod = _isMod(sid);
                  return ListTile(
                    title: Text('${m['first_name']} ${m['last_name']}'),
                    trailing: isMod 
                        ? IconButton(icon: const Icon(Icons.remove_circle, color: AppTheme.errorRed), onPressed: () => _toggleMod(sid, true))
                        : IconButton(icon: const Icon(Icons.add_circle, color: AppTheme.successGreen), onPressed: () => _toggleMod(sid, false)),
                  );
                }
              ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar')),
      ],
    );
  }
}

class _ResourcesTabSliver extends StatefulWidget {
  final int communityId;
  final int currentStudentId;
  final int communityCreatorId;

  const _ResourcesTabSliver({
    required this.communityId,
    required this.currentStudentId,
    required this.communityCreatorId,
  });

  @override
  State<_ResourcesTabSliver> createState() => _ResourcesTabSliverState();
}

class _ResourcesTabSliverState extends State<_ResourcesTabSliver> {
  bool _isLoading = true;
  int? _currentFolderId;
  String? _currentFolderName;
  
  List<dynamic> _folders = [];
  List<dynamic> _files = [];

  @override
  void initState() {
    super.initState();
    _loadResources();
  }

  Future<void> _loadResources() async {
    setState(() => _isLoading = true);
    final prov = context.read<CommunityProvider>();
    
    if (_currentFolderId == null) {
      _folders = await prov.getFolders(widget.communityId);
    } else {
      _folders = [];
    }
    
    _files = await prov.getFiles(widget.communityId, folderId: _currentFolderId);
    
    if (mounted) setState(() => _isLoading = false);
  }

  void _createFolder() {
    final cur = TextEditingController();
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Crear Carpeta'),
        content: TextField(controller: cur, decoration: const InputDecoration(hintText: 'Nombre de la carpeta')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              if (cur.text.trim().isNotEmpty) {
                Navigator.pop(c);
                await context.read<CommunityProvider>().createFolder(widget.communityId, cur.text.trim());
                _loadResources();
              }
            }, 
            child: const Text('Crear')
          ),
        ],
      )
    );
  }

  void _editFolder(dynamic f) {
    final cur = TextEditingController(text: f['name']);
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Editar Carpeta'),
        content: TextField(controller: cur, decoration: const InputDecoration(hintText: 'Nombre')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              if (cur.text.trim().isNotEmpty) {
                Navigator.pop(c);
                await context.read<CommunityProvider>().updateFolder(widget.communityId, f['id'], cur.text.trim());
                _loadResources();
              }
            }, 
            child: const Text('Guardar')
          ),
        ],
      )
    );
  }

  void _uploadPdf() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() => _isLoading = true);
      await context.read<CommunityProvider>().uploadFile(widget.communityId, _currentFolderId, result.files.single.path!);
      _loadResources();
    }
  }

  void _deleteFolder(int folderId) async {
    await context.read<CommunityProvider>().deleteFolder(widget.communityId, folderId);
    _loadResources();
  }

  void _deleteFile(int fileId) async {
    await context.read<CommunityProvider>().deleteFile(widget.communityId, fileId);
    _loadResources();
  }

  bool _canEdit(int creatorId) {
    return creatorId == widget.currentStudentId || widget.communityCreatorId == widget.currentStudentId;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SliverToBoxAdapter(child: Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator())));
    }

    return SliverList(
      delegate: SliverChildListDelegate([
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              if (_currentFolderId != null) ...[
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    setState(() {
                      _currentFolderId = null;
                      _currentFolderName = null;
                    });
                    _loadResources();
                  },
                ),
                Expanded(child: Text(_currentFolderName ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
              ] else ...[
                const Expanded(child: Text('Recursos (Raíz)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
              ],
              if (_currentFolderId == null)
                IconButton(icon: const Icon(Icons.create_new_folder, color: AppTheme.primaryRed), onPressed: _createFolder, tooltip: 'Nueva Carpeta'),
              IconButton(icon: const Icon(Icons.upload_file, color: AppTheme.primaryRed), onPressed: _uploadPdf, tooltip: 'Subir PDF'),
            ],
          ),
        ),
        
        if (_folders.isEmpty && _files.isEmpty)
          const Padding(padding: EdgeInsets.all(40), child: Center(child: Text('Aún no hay recursos aquí.', style: TextStyle(color: Colors.black54)))),
        
        ..._folders.map((f) => ListTile(
          leading: const Icon(Icons.folder, color: Colors.blueAccent, size: 40),
          title: Text(f['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
          trailing: _canEdit(f['creator_id']) ? PopupMenuButton<String>(
            itemBuilder: (ctx) => [
              const PopupMenuItem(value: 'edit', child: Text('Editar')),
              const PopupMenuItem(value: 'delete', child: Text('Eliminar', style: TextStyle(color: AppTheme.errorRed))),
            ],
            onSelected: (val) {
              if (val == 'edit') _editFolder(f);
              if (val == 'delete') _deleteFolder(f['id']);
            },
          ) : null,
          onTap: () {
            setState(() {
              _currentFolderId = f['id'];
              _currentFolderName = f['name'];
            });
            _loadResources();
          },
        )).toList(),
        
        ..._files.map((file) => ListTile(
          leading: const Icon(Icons.picture_as_pdf, color: AppTheme.primaryRed, size: 40),
          title: Text(file['name'], maxLines: 1, overflow: TextOverflow.ellipsis),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_canEdit(file['creator_id'])) ...[
                IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteFile(file['id'])),
              ]
            ],
          ),
          onTap: () {
            
          },
        )).toList(),
        
        const SizedBox(height: 60),
      ]),
    );
  }
}

