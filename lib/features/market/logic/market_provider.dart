/// State management for the marketplace.
import 'package:flutter/material.dart';
import 'package:uni_social_student/features/market/data/models/market_product_model.dart';
import 'package:uni_social_student/features/market/data/repositories/market_repository.dart';

class MarketProvider extends ChangeNotifier {
  final MarketRepository _repository;

  MarketProvider({MarketRepository? repository})
      : _repository = repository ?? MarketRepository();

  List<MarketProductModel> _products = [];
  bool _isLoading = false;
  bool _isCreating = false;
  String _errorMessage = '';
  String? _selectedCategory;

  List<MarketProductModel> get products => _products;
  bool get isLoading => _isLoading;
  bool get isCreating => _isCreating;
  String get errorMessage => _errorMessage;
  String? get selectedCategory => _selectedCategory;

  static const List<String> categories = [
    'Todos',
    'Libros y Apuntes',
    'Electrónica',
    'Ropa',
    'Deportes',
    'Muebles',
    'Otros',
  ];

  /// Carga los productos del marketplace.
  Future<void> loadProducts() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    final categoryParam =
        (_selectedCategory == null || _selectedCategory == 'Todos')
            ? null
            : _selectedCategory;

    final response = await _repository.fetchProducts(category: categoryParam);

    if (response.success && response.data != null) {
      final list = response.data as List;
      _products = list
          .map((json) =>
              MarketProductModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      _errorMessage = response.message;
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Filtra productos por categoría.
  void setCategory(String? category) {
    _selectedCategory = category;
    loadProducts();
  }

  /// Crea un nuevo producto.
  Future<bool> createProduct({
    required String title,
    required String description,
    required double price,
    required String category,
    String? location,
    String? schedule,
    String? imagePath,
  }) async {
    _isCreating = true;
    _errorMessage = '';
    notifyListeners();

    final response = await _repository.createProduct(
      title: title,
      description: description,
      price: price,
      category: category,
      location: location,
      schedule: schedule,
      imagePath: imagePath,
    );

    _isCreating = false;

    if (response.success) {
      // Recargar la lista
      await loadProducts();
      return true;
    } else {
      _errorMessage = response.message;
      notifyListeners();
      return false;
    }
  }

  /// Actualiza un producto existente.
  Future<bool> updateProduct({
    required int productId,
    required String title,
    required String description,
    required double price,
    required String category,
    String? location,
    String? schedule,
    String? imagePath,
  }) async {
    _isCreating = true;
    _errorMessage = '';
    notifyListeners();

    final response = await _repository.updateProduct(
      productId: productId,
      title: title,
      description: description,
      price: price,
      category: category,
      location: location,
      schedule: schedule,
      imagePath: imagePath,
    );

    _isCreating = false;

    if (response.success) {
      // Recargar la lista
      await loadProducts();
      return true;
    } else {
      _errorMessage = response.message;
      notifyListeners();
      return false;
    }
  }

  /// Elimina un producto.
  Future<bool> deleteProduct(int productId) async {
    final response = await _repository.deleteProduct(productId);
    if (response.success) {
      _products.removeWhere((p) => p.id == productId);
      notifyListeners();
      return true;
    }
    _errorMessage = response.message;
    notifyListeners();
    return false;
  }
}
