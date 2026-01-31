import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  // ================= PRODUCT =================

  Stream<QuerySnapshot> getProducts() {
    return _db.collection('products').orderBy('createdAt').snapshots();
  }

  Future<void> addProduct({
    required String name,
    required String category,
    required int price,
    required int stock,
    required String image,
  }) {
    return _db.collection('products').add({
      'name': name,
      'category': category,
      'price': price,
      'stock': stock,
      'image': image,
      'createdAt': Timestamp.now(),
    });
  }

  Future<void> updateProduct(String id, Map<String, dynamic> data) {
    return _db.collection('products').doc(id).update(data);
  }

  Future<void> deleteProduct(String id) {
    return _db.collection('products').doc(id).delete();
  }

  // ================= TRANSACTION =================

  Future<void> saveTransaction({
    String? buyerName,
    required int totalPrice,
    required List<Map<String, dynamic>> items,
  }) async {
    final transactionRef = await _db.collection('transactions').add({
      'buyerName': buyerName?.isEmpty ?? true 
      ? '-' 
      : buyerName,
      'totalPrice': totalPrice,
      'date': Timestamp.now(),
    });

    for (var item in items) {
      await transactionRef.collection('items').add({
        'name': item['name'],
        'price': item['price'],
        'qty': item['count'],
      });
    }
  }
}
