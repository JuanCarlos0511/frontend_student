/// Marketplace screen — displays product listing with category filter.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:uni_social_student/shared/widgets/animated_search_bar.dart';
import 'package:uni_social_student/core/theme/app_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:uni_social_student/features/market/data/models/market_product_model.dart';
import 'package:uni_social_student/features/market/logic/market_provider.dart';
import 'package:uni_social_student/features/market/presentation/screens/add_product_screen.dart';
import 'package:uni_social_student/features/auth_login/logic/login_provider.dart';
import 'package:uni_social_student/features/chat/logic/chat_provider.dart';
import 'package:uni_social_student/features/chat/presentation/screens/chat_detail_screen.dart';

class MarketScreen extends StatefulWidget {
  final int? prioritizeProductId;
  const MarketScreen({super.key, this.prioritizeProductId});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
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
      context.read<MarketProvider>().loadProducts(prioritizeId: widget.prioritizeProductId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MarketProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 4),
                child: Text(
                  'Marketplace',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.darkText,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Encuentra lo que necesitas para tu semestre.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.mediumGrey,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              AnimatedSearchBar(
                hintText: 'Buscar en el marketplace...',
                onChanged: (val) {
                  if (_debounce?.isActive ?? false) _debounce!.cancel();
                  _debounce = Timer(const Duration(milliseconds: 500), () {
                    context.read<MarketProvider>().setSearchQuery(val);
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
                  itemCount: MarketProvider.categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final cat = MarketProvider.categories[index];
                    final isSelected =
                        (provider.selectedCategory ?? 'Todos') == cat;
                    return ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      onSelected: (_) => provider.setCategory(cat),
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
              // ── Product list ──
              Expanded(
                child: _buildProductList(provider),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              final created = await Navigator.of(context).push<bool>(
                MaterialPageRoute(builder: (_) => const AddProductScreen()),
              );
              if (created == true && mounted) {
                context.read<MarketProvider>().loadProducts();
              }
            },
            backgroundColor: AppTheme.primaryRed,
            child: const Icon(Icons.add, color: AppTheme.white),
          ),
        );
      },
    );
  }

  Widget _buildProductList(MarketProvider provider) {
    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryRed),
      );
    }

    if (provider.errorMessage.isNotEmpty) {
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
              onPressed: () => provider.loadProducts(),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (provider.products.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.storefront_outlined,
                size: 64, color: AppTheme.mediumGrey),
            SizedBox(height: 12),
            Text('No hay productos aún',
                style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.mediumGrey,
                    fontWeight: FontWeight.w600)),
            SizedBox(height: 4),
            Text('¡Sé el primero en publicar!',
                style: TextStyle(color: AppTheme.mediumGrey)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppTheme.primaryRed,
      onRefresh: () => provider.loadProducts(),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
        itemCount: provider.products.length,
        itemBuilder: (context, index) {
          return _ProductCard(product: provider.products[index]);
        },
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final MarketProductModel product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final currentUserId = context.watch<LoginProvider>().studentId;
    final isOwner = currentUserId == product.studentId;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Image ──
          if (product.imageUrl != null && product.imageUrl!.isNotEmpty)
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: CachedNetworkImage(
                imageUrl: product.imageUrl!,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => Container(
                  height: 180,
                  color: AppTheme.lightGrey,
                  child: const Center(
                    child: Icon(Icons.image_not_supported_outlined,
                        size: 48, color: AppTheme.mediumGrey),
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Title + Price ──
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        product.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.darkText,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primaryRed,
                      ),
                    ),
                    if (isOwner)
                      PopupMenuButton<String>(
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.more_vert, color: AppTheme.mediumGrey),
                        onSelected: (value) async {
                          if (value == 'edit') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AddProductScreen(productToEdit: product),
                              ),
                            );
                          } else if (value == 'delete') {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Eliminar publicación'),
                                content: const Text('¿Estás seguro de eliminar este producto?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: const Text('Cancelar', style: TextStyle(color: AppTheme.mediumGrey)),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: const Text('Eliminar', style: TextStyle(color: AppTheme.primaryRed)),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true && context.mounted) {
                              final provider = context.read<MarketProvider>();
                              final success = await provider.deleteProduct(product.id);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(success ? 'Producto eliminado' : provider.errorMessage),
                                    backgroundColor: success ? AppTheme.successGreen : AppTheme.errorRed,
                                  ),
                                );
                              }
                            }
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
                                Icon(Icons.delete_outline, size: 20, color: AppTheme.primaryRed),
                                SizedBox(width: 8),
                                Text('Eliminar', style: TextStyle(color: AppTheme.primaryRed)),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                // ── Description ──
                if (product.description != null &&
                    product.description!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    product.description!,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.mediumGrey,
                      height: 1.4,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                // ── Schedule ──
                if (product.schedule != null && product.schedule!.isNotEmpty)
                  _infoRow(Icons.access_time, 'Hora: ${product.schedule!}',
                      AppTheme.primaryRed),
                // ── Location ──
                if (product.location != null && product.location!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: _infoRow(
                        Icons.location_on_outlined,
                        'Lugar: ${product.location!}',
                        AppTheme.primaryRed),
                  ),
                const SizedBox(height: 12),
                // ── Contactar button ──
                if (!isOwner)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _contactSeller(context),
                      icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                      label: const Text('Contactar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryRed,
                      foregroundColor: AppTheme.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _contactSeller(BuildContext context) async {
    final chatProvider = context.read<ChatProvider>();
    final room = await chatProvider.findOrCreateRoom(
      sellerId: product.studentId,
      productId: product.id,
      productName: product.title,
    );

    if (room != null && context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ChatDetailScreen(
            roomId: room.id,
            otherName: product.sellerName,
            otherPhoto: product.profilePhotoPath,
            referencedProductId: product.id,
            referencedProductTitle: product.title,
            referencedProductDescription: product.description,
            referencedProductImageUrl: product.imageUrl,
            referencedProductPrice: product.price,
          ),
        ),
      );
    } else if (context.mounted && chatProvider.errorMessage.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(chatProvider.errorMessage)),
      );
    }
  }

  Widget _infoRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
