/// Add product screen — form to create a new marketplace listing.
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:uni_social_student/core/theme/app_theme.dart';
import 'package:uni_social_student/features/market/data/models/market_product_model.dart';
import 'package:uni_social_student/features/market/logic/market_provider.dart';

class AddProductScreen extends StatefulWidget {
  final MarketProductModel? productToEdit;
  const AddProductScreen({super.key, this.productToEdit});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _scheduleCtrl = TextEditingController();
  String _selectedCategory = 'Libros y Apuntes';
  String? _imagePath;

  bool get _isEditing => widget.productToEdit != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final p = widget.productToEdit!;
      _titleCtrl.text = p.title;
      _priceCtrl.text = p.price.toString();
      _descriptionCtrl.text = p.description ?? '';
      _locationCtrl.text = p.location ?? '';
      _scheduleCtrl.text = p.schedule ?? '';
      _selectedCategory = p.category;
      if (p.imageUrl != null) {
        _imagePath = p.imageUrl;
      }
    }
  }

  static const _categoryOptions = [
    'Libros y Apuntes',
    'Electrónica',
    'Ropa',
    'Deportes',
    'Muebles',
    'Otros',
  ];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _priceCtrl.dispose();
    _descriptionCtrl.dispose();
    _locationCtrl.dispose();
    _scheduleCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );
    if (pickedFile != null) {
      setState(() => _imagePath = pickedFile.path);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<MarketProvider>();
    final double price = double.tryParse(_priceCtrl.text.trim()) ?? 0.0;
    bool success = false;

    if (_isEditing) {
      success = await provider.updateProduct(
        productId: widget.productToEdit!.id,
        title: _titleCtrl.text.trim(),
        description: _descriptionCtrl.text.trim(),
        price: price,
        category: _selectedCategory,
        location: _locationCtrl.text.trim(),
        schedule: _scheduleCtrl.text.trim(),
        imagePath: _imagePath,
      );
    } else {
      success = await provider.createProduct(
        title: _titleCtrl.text.trim(),
        description: _descriptionCtrl.text.trim(),
        price: price,
        category: _selectedCategory,
        location: _locationCtrl.text.trim(),
        schedule: _scheduleCtrl.text.trim(),
        imagePath: _imagePath,
      );
    }

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? '¡Publicación actualizada!' : '¡Producto publicado exitosamente!'),
          backgroundColor: AppTheme.successGreen,
        ),
      );
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage.isNotEmpty
              ? provider.errorMessage
              : (_isEditing ? 'Error al actualizar la publicación' : 'Error al publicar el producto')),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Publicación' : 'Vender Producto'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Vender Producto',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.darkText,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Completa los detalles para que otros estudiantes encuentren tu artículo.',
                style: TextStyle(fontSize: 14, color: AppTheme.mediumGrey),
              ),
              const SizedBox(height: 24),

              // ── Image picker ──
              const Text('AÑADIR FOTOS',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.mediumGrey,
                      letterSpacing: 1)),
              const SizedBox(height: 10),
              _buildImagePicker(),
              const SizedBox(height: 24),

              // ── Title ──
              _label('TÍTULO DEL PRODUCTO'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(
                  hintText: 'Ej: Libro de Cálculo Stewart 7ma Ed',
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Ingresa un título' : null,
              ),
              const SizedBox(height: 20),

              // ── Price ──
              _label('PRECIO'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _priceCtrl,
                decoration: const InputDecoration(
                  hintText: '\$ 0.00',
                  prefixText: '\$ ',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Ingresa un precio';
                  if (double.tryParse(v.trim()) == null) {
                    return 'Ingresa un número válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // ── Category ──
              _label('CATEGORÍA'),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                isExpanded: true,
                decoration: const InputDecoration(),
                items: _categoryOptions
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _selectedCategory = v);
                },
              ),
              const SizedBox(height: 20),

              // ── Description ──
              _label('DESCRIPCIÓN LIBRE'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _descriptionCtrl,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText:
                      'Describe el estado del producto, si es negociable, etc...',
                ),
              ),
              const SizedBox(height: 28),

              // ── Logistics section ──
              Row(
                children: [
                  Icon(Icons.local_shipping_outlined,
                      color: AppTheme.primaryRed, size: 22),
                  const SizedBox(width: 8),
                  const Text(
                    'Logística de Entrega',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.darkText,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.lightGrey,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('LUGAR DE ENCUENTRO EN EL CAMPUS'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _locationCtrl,
                      decoration: const InputDecoration(
                        hintText: 'Ej: Cafetería Central, Biblioteca N',
                        prefixIcon: Icon(Icons.location_on_outlined,
                            color: AppTheme.mediumGrey, size: 20),
                        fillColor: AppTheme.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _label('HORARIOS DISPONIBLES'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _scheduleCtrl,
                      decoration: const InputDecoration(
                        hintText: 'Ej: Lunes a Viernes de 10:00 a 14:00',
                        prefixIcon: Icon(Icons.access_time,
                            color: AppTheme.mediumGrey, size: 20),
                        fillColor: AppTheme.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // ── Submit button ──
              Consumer<MarketProvider>(
                builder: (context, mp, _) {
                  return SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: mp.isCreating ? null : _submit,
                      icon: mp.isCreating
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: AppTheme.white))
                          : const Icon(Icons.send_rounded),
                      label: Text(mp.isCreating
                          ? 'Publicando...'
                          : 'Publicar Producto'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryRed,
                        foregroundColor: AppTheme.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'Al publicar, confirmas que tu producto cumple con las\nnormas de convivencia del campus.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: AppTheme.mediumGrey),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Row(
      children: [
        // Main image slot
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: AppTheme.lightGrey,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: _imagePath != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(_imagePath!),
                      fit: BoxFit.cover,
                      width: 90,
                      height: 90,
                    ),
                  )
                : const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt_outlined,
                          color: AppTheme.mediumGrey, size: 28),
                      SizedBox(height: 4),
                      Text('PRINCIPAL',
                          style: TextStyle(
                              fontSize: 9,
                              color: AppTheme.mediumGrey,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
          ),
        ),
        const SizedBox(width: 10),
        // Placeholder slots
        for (int i = 0; i < 2; i++) ...[
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: AppTheme.lightGrey,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: const Center(
              child: Icon(Icons.camera_alt_outlined,
                  color: AppTheme.mediumGrey, size: 28),
            ),
          ),
          if (i < 1) const SizedBox(width: 10),
        ],
      ],
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppTheme.mediumGrey,
        letterSpacing: 0.5,
      ),
    );
  }
}
