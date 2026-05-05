/// Community discover screen — list of communities with category filter.
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:uni_social_student/shared/widgets/animated_search_bar.dart';
import 'package:uni_social_student/core/theme/app_theme.dart';
import 'package:uni_social_student/features/communities/data/models/community_models.dart';
import 'package:uni_social_student/features/communities/logic/community_provider.dart';
import 'package:uni_social_student/features/communities/presentation/screens/community_detail_screen.dart';

class CommunityDiscoverScreen extends StatefulWidget {
  const CommunityDiscoverScreen({super.key});

  @override
  State<CommunityDiscoverScreen> createState() =>
      _CommunityDiscoverScreenState();
}

class _CommunityDiscoverScreenState extends State<CommunityDiscoverScreen> {
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CommunityProvider>().loadCommunities();
    });
  }


  void _showCreateDialog() {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String selectedCategory = 'Académicas';
    File? coverFile;
    bool isCourse = false;
    List<String> topics = [];
    final topicCtrl = TextEditingController();

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
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppTheme.mediumGrey.withAlpha(80),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Crear Comunidad',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.darkText,
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () async {
                        final picker = ImagePicker();
                        final picked = await picker.pickImage(
                          source: ImageSource.gallery,
                          maxWidth: 800,
                          maxHeight: 400,
                          imageQuality: 80,
                        );
                        if (picked != null) {
                          setModalState(() => coverFile = File(picked.path));
                        }
                      },
                      child: Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppTheme.lightGrey,
                          borderRadius: BorderRadius.circular(12),
                          image: coverFile != null
                              ? DecorationImage(
                                  image: FileImage(coverFile!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: coverFile == null
                            ? const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_photo_alternate_outlined,
                                      color: AppTheme.mediumGrey, size: 36),
                                  SizedBox(height: 8),
                                  Text('Agregar Portada (Opcional)',
                                      style: TextStyle(
                                          color: AppTheme.mediumGrey,
                                          fontSize: 12)),
                                ],
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(hintText: 'Nombre del grupo'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      decoration: const InputDecoration(hintText: 'Categoría'),
                      items: CommunityProvider.categories
                          .where((c) => c != 'Todas')
                          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (val) => setModalState(() => selectedCategory = val!),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(
                          hintText: 'Descripción (Opcional)'),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      title: const Text('Modo Curso', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text('Define una lista de temas de progreso.'),
                      value: isCourse,
                      activeColor: AppTheme.primaryRed,
                      onChanged: (val) => setModalState(() => isCourse = val),
                    ),
                    if (isCourse) ...[
                      const SizedBox(height: 12),
                      const Text('Temas del Curso', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: topicCtrl,
                              decoration: const InputDecoration(hintText: 'Nombre del tema'),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle, color: AppTheme.primaryRed),
                            onPressed: () {
                              if (topicCtrl.text.trim().isNotEmpty) {
                                setModalState(() {
                                  topics.add(topicCtrl.text.trim());
                                  topicCtrl.clear();
                                });
                              }
                            },
                          )
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (topics.isNotEmpty)
                        Container(
                          constraints: const BoxConstraints(maxHeight: 150),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: topics.length,
                            itemBuilder: (ctx, i) {
                              return ListTile(
                                leading: CircleAvatar(radius: 12, child: Text('${i+1}', style: const TextStyle(fontSize: 12))),
                                title: Text(topics[i]),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete, color: AppTheme.errorRed, size: 18),
                                  onPressed: () {
                                    setModalState(() {
                                      topics.removeAt(i);
                                    });
                                  }
                                ),
                              );
                            }
                          )
                        )
                    ],
                    const SizedBox(height: 24),
                    Consumer<CommunityProvider>(
                      builder: (context, provider, _) {
                        return SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: provider.isCreating
                                ? null
                                : () async {
                                    if (nameCtrl.text.trim().isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text('Escribe un nombre.'),
                                            backgroundColor: AppTheme.errorRed),
                                      );
                                      return;
                                    }
                                    final success =
                                        await provider.createCommunity(
                                      name: nameCtrl.text.trim(),
                                      category: selectedCategory,
                                      description: descCtrl.text.trim(),
                                      coverImagePath: coverFile?.path,
                                      isCourse: isCourse,
                                      courseModules: topics,
                                    );
                                    if (success && context.mounted) {
                                      Navigator.pop(ctx);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text('Comunidad creada.'),
                                            backgroundColor:
                                                AppTheme.successGreen),
                                      );
                                    } else if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                            content: Text(provider.errorMessage),
                                            backgroundColor: AppTheme.errorRed),
                                      );
                                    }
                                  },
                            child: provider.isCreating
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                        color: AppTheme.white, strokeWidth: 2))
                                : const Text('Crear Grupo'),
                          ),
                        );
                      },
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
      body: Consumer<CommunityProvider>(
        builder: (context, provider, _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedSearchBar(
                hintText: 'Buscar comunidades...',
                onChanged: (val) {
                  if (_debounce?.isActive ?? false) _debounce!.cancel();
                  _debounce = Timer(const Duration(milliseconds: 500), () {
                    context.read<CommunityProvider>().setSearchQuery(val);
                  });
                },
              ),
              const SizedBox(height: 8),
              // ── Category chips ──
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: CommunityProvider.categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final cat = CommunityProvider.categories[index];
                    final isSelected =
                        (provider.selectedCategory ?? 'Todas') == cat;
                    return ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      onSelected: (_) =>
                          provider.setCategory(cat == 'Todas' ? null : cat),
                      selectedColor: AppTheme.primaryRed,
                      backgroundColor: AppTheme.lightGrey,
                      labelStyle: TextStyle(
                        color: isSelected ? AppTheme.white : AppTheme.darkText,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      side: BorderSide.none,
                      showCheckmark: false,
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              // ── Communities List ──
              Expanded(
                child: _buildList(provider),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateDialog,
        backgroundColor: AppTheme.primaryRed,
        child: const Icon(Icons.add, color: AppTheme.white),
      ),
    );
  }

  Widget _buildList(CommunityProvider provider) {
    if (provider.isLoading && provider.communities.isEmpty) {
      return const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryRed));
    }

    if (provider.communities.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.groups_outlined, size: 64, color: AppTheme.mediumGrey),
            SizedBox(height: 12),
            Text('No hay comunidades aún',
                style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.mediumGrey,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppTheme.primaryRed,
      onRefresh: () => provider.loadCommunities(),
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
          mainAxisSpacing: 16,
          mainAxisExtent: 230, // Mantener altura aproximada de las tarjetas pero ocupando todo el ancho
        ),
        itemCount: provider.communities.length,
        itemBuilder: (context, index) {
          final comm = provider.communities[index];
          return _CommunityCard(community: comm);
        },
      ),
    );
  }
}

class _CommunityCard extends StatelessWidget {
  final CommunityModel community;

  const _CommunityCard({required this.community});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CommunityDetailScreen(communityId: community.id),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(12),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Cover Image ──
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: community.coverImage != null &&
                        community.coverImage!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: community.coverImage!,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => Container(
                          color: AppTheme.lightGrey,
                          child: const Icon(Icons.groups,
                              color: AppTheme.mediumGrey),
                        ),
                      )
                    : Container(
                        color: AppTheme.lightGrey,
                        child: const Icon(Icons.groups,
                            size: 40, color: AppTheme.mediumGrey),
                      ),
              ),
            ),
            // ── Info ──
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            community.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.darkText,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${community.membersCount} miembro${community.membersCount == 1 ? '' : 's'}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.mediumGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.lightGrey,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        community.category,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryRed,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
