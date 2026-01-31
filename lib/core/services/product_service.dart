import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/product_model.dart';
import '../../models/transaction_model.dart';

class ProductService {
  // Singleton
  static final ProductService _instance = ProductService._internal();
  factory ProductService() => _instance;
  ProductService._internal();

  // ============================
  // DATA PRODUK
  // ============================

  final List<ProductModel> _products = [];

  List<ProductModel> get products => _products;

  /// 🔥 AMBIL DATA DARI FIRESTORE
  Future<void> fetchProducts() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('products').get();

    _products.clear();

    for (var doc in snapshot.docs) {
      _products.add(
        ProductModel.fromFirestore(
          doc.id,
          doc.data(),
        ),
      );
    }
  }

  // CRUD LOKAL (opsional, untuk admin UI)
  void addProduct(ProductModel product) {
    _products.add(product);
  }

  void updateProduct(int index, ProductModel product) {
    _products[index] = product;
  }

  void deleteProduct(int index) {
    _products.removeAt(index);
  }

  // ============================
  // RIWAYAT TRANSAKSI
  // ============================

  final List<TransactionModel> _salesHistory = [];

  List<TransactionModel> get salesHistory => _salesHistory;

  void addTransaction(TransactionModel transaction) {
    _salesHistory.add(transaction);

    for (var item in transaction.items) {
      final productIndex =
          _products.indexWhere((p) => p.id == item['id']);

      if (productIndex != -1) {
        _products[productIndex].stock -= item['count'] as int;
      }
    }
  }

  int getTotalRevenue() {
    return _salesHistory.fold(0, (sum, item) => sum + item.totalPrice);
  }

  List<TransactionModel> getDailySales(DateTime date) {
    return _salesHistory.where((tx) =>
        tx.date.day == date.day &&
        tx.date.month == date.month &&
        tx.date.year == date.year).toList();
  }
}
