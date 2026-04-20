import re

with open('lib/features/communities/presentation/screens/community_detail_screen.dart', 'r') as f:
    text = f.read()

create_post_sheet = '''
  Future<void> _showCreatePostSheet(BuildContext context) async {
    final provider = context.read<CommunityProvider>();
    if (provider.activeCommunity?.isMember != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes unirte a la comunidad para publicar.'), backgroundColor: AppTheme.errorRed),
      );
      return;
    }

    final contentCtrl = TextEditingController();
    File? imageFile;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Nueva Publicación', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.darkText)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: contentCtrl,
                    maxLines: 4,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(hintText: '¿Qué quieres compartir con la comunidad?'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: () async {
                          final picker = ImagePicker();
                          final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
                          if (picked != null) setModalState(() => imageFile = File(picked.path));
                        },
                        icon: const Icon(Icons.image_outlined),
                        label: const Text('Adjuntar Imagen'),
                        style: OutlinedButton.styleFrom(minimumSize: const Size(0, 40)),
                      ),
                      const SizedBox(width: 12),
                      if (imageFile != null) const Icon(Icons.check_circle_outline, color: AppTheme.successGreen),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Consumer<CommunityProvider>(
                    builder: (context, p, _) {
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: p.isCreating ? null : () async {
                            if (contentCtrl.text.trim().isEmpty) return;
                            final success = await p.createPost(
                              communityId: widget.communityId,
                              content: contentCtrl.text.trim(),
                              imagePath: imageFile?.path,
                            );
                            if (success && ctx.mounted) Navigator.pop(ctx);
                            else if (ctx.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(p.errorMessage), backgroundColor: AppTheme.errorRed));
                          },
                          child: p.isCreating ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: AppTheme.white, strokeWidth: 2)) : const Text('Publicar'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
'''

# insert after _deleteCommunity
del_community_end = text.find('Widget build(BuildContext context)')
text = text[:del_community_end] + create_post_sheet + text[del_community_end:]

# replace // show create post modal to _showCreatePostSheet(context)
text = text.replace('// show create post modal', '_showCreatePostSheet(context);')
text = text.replace('// Open create post sheet...', '_showCreatePostSheet(context);')

with open('lib/features/communities/presentation/screens/community_detail_screen.dart', 'w') as f:
    f.write(text)
