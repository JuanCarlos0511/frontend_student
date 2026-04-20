/// Profile screen — displays user info with editable profile photo.
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:uni_social_student/core/theme/app_theme.dart';
import 'package:uni_social_student/features/auth_login/logic/login_provider.dart';
import 'package:uni_social_student/features/auth_login/presentation/screens/login_screen.dart';
import 'package:uni_social_student/features/profile/logic/profile_provider.dart';
import 'package:uni_social_student/features/moderator/logic/moderator_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().loadProfile();
    });
  }

  Future<void> _pickAndUpdatePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (pickedFile == null) return;
    if (!mounted) return;

    final success =
        await context.read<ProfileProvider>().updateProfilePhoto(pickedFile.path);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success
            ? 'Foto de perfil actualizada'
            : 'Error al actualizar la foto'),
        backgroundColor: success ? AppTheme.successGreen : AppTheme.errorRed,
      ),
    );
  }

  Future<void> _logout() async {
    await context.read<LoginProvider>().logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  void _showModeratorSheet() {
    final argsCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
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
              const Row(
                children: [
                  Icon(Icons.shield_outlined,
                      color: AppTheme.primaryRed, size: 24),
                  SizedBox(width: 10),
                  Text(
                    'Solicitud de Moderador',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.darkText,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                '¿Por qué quieres ser moderador de seguridad? Escribe tus argumentos.',
                style: TextStyle(fontSize: 13, color: AppTheme.mediumGrey),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: argsCtrl,
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText:
                      'Explica tu motivación, experiencia o por qué serías un buen moderador...',
                  filled: true,
                  fillColor: AppTheme.lightGrey,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Consumer<ModeratorProvider>(
                builder: (ctx2, modProvider, _) {
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: modProvider.isSubmitting
                          ? null
                          : () async {
                              if (argsCtrl.text.trim().isEmpty) {
                                ScaffoldMessenger.of(ctx2).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Escribe tus argumentos primero.'),
                                    backgroundColor: AppTheme.errorRed,
                                  ),
                                );
                                return;
                              }
                              final success = await modProvider
                                  .submitApplication(argsCtrl.text.trim());
                              if (!ctx2.mounted) return;
                              Navigator.of(ctx2).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(success
                                      ? '¡Solicitud enviada exitosamente!'
                                      : modProvider.errorMessage.isNotEmpty
                                          ? modProvider.errorMessage
                                          : 'Error al enviar.'),
                                  backgroundColor: success
                                      ? AppTheme.successGreen
                                      : AppTheme.errorRed,
                                ),
                              );
                            },
                      icon: modProvider.isSubmitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: AppTheme.white))
                          : const Icon(Icons.send_rounded),
                      label: Text(modProvider.isSubmitting
                          ? 'Enviando...'
                          : 'Enviar Postulación'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryRed,
                        foregroundColor: AppTheme.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.profile == null) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.primaryRed),
          );
        }

        if (provider.errorMessage.isNotEmpty && provider.profile == null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline,
                    size: 48, color: AppTheme.mediumGrey),
                const SizedBox(height: 12),
                Text(provider.errorMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppTheme.mediumGrey)),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () => provider.loadProfile(),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          color: AppTheme.primaryRed,
          onRefresh: () => provider.loadProfile(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(height: 24),
                // ── Profile photo ──
                _buildProfilePhoto(provider),
                const SizedBox(height: 20),
                // ── Name ──
                Text(
                  provider.fullName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.darkText,
                  ),
                ),
                const SizedBox(height: 6),
                // ── Email ──
                Text(
                  provider.email,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.mediumGrey,
                  ),
                ),
                const SizedBox(height: 32),
                // ── Info cards ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _buildInfoSection(provider),
                ),
                const SizedBox(height: 32),
                // ── Moderator application ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.lightGrey,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.shield_outlined,
                          color: AppTheme.primaryRed),
                      title: const Text(
                        'Solicitud para moderador de seguridad',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.darkText,
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded,
                          color: AppTheme.mediumGrey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onTap: () => _showModeratorSheet(),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // ── Logout ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _logout,
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text('Cerrar sesión'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primaryRed,
                        side: const BorderSide(color: AppTheme.primaryRed),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfilePhoto(ProfileProvider provider) {
    final photoUrl = provider.profilePhotoUrl;
    return Stack(
      alignment: Alignment.center,
      children: [
        // Ring
        Container(
          width: 130,
          height: 130,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.primaryRed, width: 3),
          ),
          child: ClipOval(
            child: photoUrl != null && photoUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: photoUrl,
                    fit: BoxFit.cover,
                    width: 124,
                    height: 124,
                    errorWidget: (context, url, error) => _defaultAvatar(),
                  )
                : _defaultAvatar(),
          ),
        ),
        // Edit button
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: provider.isUpdatingPhoto ? null : _pickAndUpdatePhoto,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppTheme.primaryRed,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.white, width: 2),
              ),
              child: provider.isUpdatingPhoto
                  ? const Padding(
                      padding: EdgeInsets.all(8),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.white,
                      ),
                    )
                  : const Icon(Icons.edit, size: 18, color: AppTheme.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _defaultAvatar() {
    return Container(
      width: 124,
      height: 124,
      color: AppTheme.lightGrey,
      child: const Icon(Icons.person_rounded,
          size: 64, color: AppTheme.mediumGrey),
    );
  }

  Widget _buildInfoSection(ProfileProvider provider) {
    final status = provider.profile?['status'] ?? 'unknown';
    final createdAt = provider.profile?['created_at'] ?? '';
    String formattedDate = '';
    if (createdAt.isNotEmpty) {
      try {
        final date = DateTime.parse(createdAt);
        formattedDate =
            '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
      } catch (_) {
        formattedDate = createdAt;
      }
    }

    return Column(
      children: [
        _infoTile(Icons.verified_user_outlined, 'Estado',
            status == 'approved' ? 'Aprobado' : status),
        if (formattedDate.isNotEmpty)
          _infoTile(Icons.calendar_today_outlined, 'Miembro desde', formattedDate),
      ],
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.lightGrey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryRed, size: 22),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 12, color: AppTheme.mediumGrey)),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.darkText)),
            ],
          ),
        ],
      ),
    );
  }
}
